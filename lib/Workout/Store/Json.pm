#
# Copyright (c) 2008 Rainer Clasen
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms described in the file LICENSE included in this
# distribution.
#

=head1 NAME

Workout::Store::Json - read/write GoldenCheetah json files

=head1 SYNOPSIS

  $src = Workout::Store::Json->read( "foo.json" );

  $iter = $src->iterate;
  while( $chunk = $iter->next ){
  	...
  }

  $src->write( "out.json" );


=head1 DESCRIPTION

Interface to read/write GoldenCheetah files. Inherits from Workout::Store and
implements do_read/_write methods.

=cut

package Workout::Store::Json;
use 5.008008;
use strict;
use warnings;
use base 'Workout::Store';
use Workout::Chunk;
use Carp;
use DateTime;
use JSON;
use Data::Dumper;


our $VERSION = '0.01';

sub filetypes {
	return "json";
}

our %defaults = (
	recint		=> 1,
);
__PACKAGE__->mk_accessors( keys %defaults );

# TODO: other tags: slope, ...
our %meta = (
	sport		=> undef,
	bike		=> undef,
	athletename	=> '',
	circum          => undef,
	zeropos         => undef,
	slope           => undef,
);

=head1 CONSTRUCTOR

=head2 new( [ \%arg ] )

creates an empty Store.

=cut

sub new {
	my( $class, $a ) = @_;

	$a||={};
	$a->{meta}||={};
	$class->SUPER::new({
		%defaults,
		%$a,
		meta	=> {
			%meta,
			%{$a->{meta}},
		},
		cap_block	=> 1,
	});
}

our $re_date = qr/^(\d+)\/(\d+)\/(\d+)\s+(\d+):(\d+):(\d+)\s+UTC$/;

sub do_read {
	my( $self, $fh, $fname ) = @_;

	binmode( $fh, ':encoding(utf8)' );
	local $/;

	my $text = <$fh>;
	$text =~ s/^\x{feff}//;

	my $j = JSON->new->decode( $text )
		or return;

	my $r = $j->{RIDE}
		or return;

	my $start_time = $r->{STARTTIME}
		or return;
	$start_time =~ /$re_date/
		or return;
	my $sdate = DateTime->new(
		time_zone	=> 'UTC',
		year		=> $1,
		month		=> $2,
		day		=> $3,
		hour		=> $4,
		minute		=> $5,
		second		=> $6,
	);
	my $start = $sdate->epoch;

	my $recint = $r->{RECINTSECS};
	$self->recint( $recint );

	if( my $t = $r->{TAGS} ){
		$self->meta_field('note', $t->{Notes} )
			if exists $t->{Notes};
		$self->meta_field('sport', $t->{Sport} )
			if exists $t->{Sport};

		if( exists $t->{"Athlete Name"} && $t->{"Athlete Name"} ){
			$self->meta_field('athletename', $t->{"Athlete Name"} );
		} elsif( exists $t->{Athlete} && $t->{Athlete} ){
			$self->meta_field('athletename', $t->{Athlete} );
		}

		$self->meta_field('device', $t->{"Device Info"} )
			if exists $t->{"Device Info"};
		$self->meta_field('bike', $t->{"Bike"} )
			if exists $t->{"Bike"};
		$self->meta_field('circum', $t->{"Wheel Circumference"} )
			if exists $t->{"Wheel Circumference"};
		$self->meta_field('slope', $t->{Slope} )
			if exists $t->{Slope};
		$self->meta_field('zeropos', $t->{"Zero Offset"} )
			if exists $t->{"Zero Offset"};

		$self->meta_field('wkdb_id', $t->{"WkdbExercise"} )
			if exists $t->{"WkdbExercise"};
		$self->meta_field('ttb_id', $t->{"TtbExercise"} )
			if exists $t->{"TtbExercise"};
		$self->meta_field('vhero_id', $t->{"VeloHeroExercise"} )
			if exists $t->{"VeloHeroExercise"};
		$self->meta_field('endure_id', $t->{"EndureId"} )
			if exists $t->{"EndureId"};

		# TODO: other tags as is
	}

	# TODO: read meta OVERRIDES

	my $dist = 0;

	my %io;
	foreach my $s ( @{$r->{SAMPLES}} ){
		my %c = (
			time	=> $start + $s->{SECS} + $recint,
			dur	=> $recint,
		);

		if( exists $s->{KM} && defined $s->{KM} ){
			$io{dist}++;
			$c{dist} = ( $s->{KM} - $dist ) * 1000;
			$dist = $s->{KM};

		} elsif( exists $s->{KPH} && defined $s->{KPH} ){
			$io{dist}++;
			$c{dist} = $s->{KPH} * $recint / 3.6;

		}

		if( exists $s->{WATTS} && defined $s->{WATTS} ){
			$io{work}++;
			$c{work} = $s->{WATTS} * $recint;
		}

		if( exists $s->{HR} && defined $s->{HR} ){
			$io{hr}++;
			$c{hr} = $s->{HR};
		}

		if( exists $s->{CAD} && defined $s->{CAD} ){
			$io{cad}++;
			$c{cad} = $s->{CAD};
		}

		if( exists $s->{ALT} && defined $s->{ALT} ){
			$io{ele}++;
			$c{ele} = $s->{ALT};
		}

		if( (exists $s->{LON} || exists $s->{LAT})
			&& (defined $s->{LON} || defined $s->{LAT} ) ){

			$io{lon}++;
			$io{lat}++;
			$c{lon} = $s->{LON};
			$c{lat} = $s->{LAT};
		}

		if( exists $s->{TEMP} && defined $s->{TEMP} ){
			$io{temp}++;
			$c{temp} = $s->{TEMP};
		}


		$self->chunk_add( Workout::Chunk->new( \%c ));
	}
	$self->fields_io( keys %io );

	foreach my $m ( @{$r->{INTERVALS}} ){
		$self->mark_new({
			start	=> $m->{START},
			end	=> $m->{STOP},
			meta	=> {
				note	=> $m->{NAME},
			},
		});
	}
}


my $re_protect = qr/(\\|\/|")/;

sub protect {
	my $s = shift;

	$s ||= "";

	$s =~ s/$re_protect/\\$1/g;
	$s =~ s/\t/\\n/g;
	$s =~ s/\n/\\n/g;
	$s =~ s/\r/\\r/g;
	$s =~ s/\f/\\f/g;

	"\"$s\"";
}

sub do_write {
	my( $self, $fh, $fname ) = @_;

	$self->chunk_last or croak "no data";

	binmode( $fh, ':encoding(utf8)' );

	my %io = map { $_ => 1 } $self->fields_io;

	my $recint = $self->recint;
	my $start = $self->time_start;
	my $sdate = DateTime->from_epoch(
		epoch	=> $start,
		time_zone	=> 'UTC',
	);


	print $fh "{\n\t\"RIDE\":{\n",
		"\t\t\"STARTTIME\":", &protect(
			$sdate->strftime('%Y/%m/%d %H:%M:%S UTC')), ",\n",
		"\t\t\"RECINTSECS\":", $recint, ",\n",
		"\t\t\"DEVICETYPE\":\"Workout file\",\n",
		"\t\t\"IDENTIFIER\":\"\",\n";

	# TODO: write meta OVERRIDES

	print $fh "\t\t\"TAGS\":{\n",
		"\t\t\t\"Athlete Name\":",
		&protect( $self->meta_field('athletename')),",\n";

	print $fh "\t\t\t\"Sport\":", &protect( $self->meta_field('sport')),",\n"
		if $self->meta_field('sport');

	print $fh "\t\t\t\"Device Info\":", &protect( $self->meta_field('device') ),",\n";

	print $fh "\t\t\t\"Bike\":",
		&protect( $self->meta_field('bike')),",\n"
		if $self->meta_field('bike');
	print $fh "\t\t\t\"Wheel Circumference\":",
		&protect( $self->meta_field('circum')),",\n"
		if $self->meta_field('circum');
	print $fh "\t\t\t\"Slope\":",
		&protect( $self->meta_field('slope')),",\n"
		if $self->meta_field('slope');
	print $fh "\t\t\t\"Zero Offset\":",
		&protect( $self->meta_field('zeropos')),",\n"
		if $self->meta_field('zeropos');

	print $fh "\t\t\t\"WkdbExercise\":",
		&protect( $self->meta_field('wkdb_id')),",\n"
		if $self->meta_field('wkdb_id');
	print $fh "\t\t\t\"TtbExercise\":",
		&protect( $self->meta_field('ttb_id')),",\n"
		if $self->meta_field('ttb_id');
	print $fh "\t\t\t\"VeloHeroExercise\":",
		&protect( $self->meta_field('vhero_id')),",\n"
		if $self->meta_field('vhero_id');
	print $fh "\t\t\t\"EndureId\":",
		&protect( $self->meta_field('endure_id')),",\n"
		if $self->meta_field('endure_id');

	# TODO: other tags as is

	print $fh "\t\t\t\"Notes\":", &protect( $self->meta_field('note')), "\n",
		"\t\t},\n";


	my $num = 0;

	if( my @marks = $self->marks ){
		print $fh "\t\t\"INTERVALS\":[\n";
		foreach my $mk ( @marks ){
			print $fh ",\n" if $num++;

			print $fh "\t\t\t{ ",
				"\"NAME\":", &protect( $mk->meta_field('note') || $num ), ",",
				"\"START\":", ($mk->start - $start), ",",
				"\"STOP\":", ($mk->end - $start ), "",
				" }";
		}
		print $fh "\n\t\t],\n";
	}

	my $it = $self->iterate;
	$num = 0;
	my $dist = 0;

	print $fh "\t\t\"SAMPLES\":[\n";
	while( my $ck = $it->next ){

		print $fh ",\n" if $num++;

		print $fh "\t\t\t{ ",
			"\"SECS\":", ($ck->time - $start);

		if( $io{dist} ){
			if( defined $ck->dist ){
				print $fh ", \"KPH\":", $ck->spd * 3.6;
				$dist += $ck->dist;
			}
			print $fh ", \"KM\":", $dist / 1000;
		}

		if( $io{work} && defined $ck->work ){
			print $fh ", \"WATTS\":", $ck->pwr;
			if( defined $ck->torque ){
				print $fh ", \"NM\":", $ck->torque;
			}
		}

		if( $io{hr} && defined $ck->hr ){
			print $fh ", \"HR\":", $ck->hr;
		}

		if( $io{cad} && defined $ck->cad ){
			print $fh ", \"CAD\":", $ck->cad;
		}

		if( $io{ele} && defined $ck->ele ){
			print $fh ", \"ALT\":", $ck->ele;
			#print $fh ", \"SLOPE\":", ;
		}

		if( ($io{lon} || $io{lat} )
			&& defined $ck->lon && defined $ck->lat ){

			print $fh ", \"LAT\":", $ck->lat;
			print $fh ", \"LON\":", $ck->lon;
		}

		if( $io{temp} && defined $ck->temp ){
			print $fh ", \"TEMP\":", $ck->temp;
			#print $fh ", \"NM\":", ;
		}

		#print $fh ", \"HEADWIND\":", ;

		print $fh " }";
	}
	print $fh "\n\t\t]\n";

	print $fh "\t}\n",
		"}\n";
}


1;
__END__

=head1 SEE ALSO

Workout::Store

=head1 AUTHOR

Rainer Clasen

=cut
