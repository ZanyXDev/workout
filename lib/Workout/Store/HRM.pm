#
# Copyright (c) 2008 Rainer Clasen
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms described in the file LICENSE included in this
# distribution.
#

# based on http://www.polar.fi/files/Polar_HRM_file%20format.pdf 

=head1 NAME

Workout::Store::HRM - read/write polar HRM files

=head1 SYNOPSIS

  use Workout::Store::HRM;

  $src = Workout::Store::HRM->read( "foo.hrm" );

  $iter = $src->iterate;
  while( $chunk = $iter->next ){
  	...
  }

  $src->write( "out.hrm" );


=head1 DESCRIPTION

Interface to read/write Polar HRM files. Inherits from Workout::Store and
implements do_read/_write methods.

HRM files are always written as DOS files with CRLF line endings and
windows-1252 encoding.

=cut

package Workout::Store::HRM;
use 5.008008;
use strict;
use warnings;
use base 'Workout::Store';
use Workout::Chunk;
use Workout::Constant qw/:all/;
use Carp;
use DateTime;

# TODO: verify read values are numbers

our $VERSION = '0.01';

sub filetypes {
	return "hrm";
}

our %defaults = (
	recint	=> 5,
);

our %meta = (
	sport		=> undef,
	device		=> 'Polar HRM',
	manufacturer	=> 'Polar',
	hr_rest		=> 50,
	hr_capacity	=> 180,
	vo2max		=> 50,
	weight		=> 75,
);

our %fields_supported = map { $_ => 1; } qw{
	hr
	cad
	dist
	ele
	work
};

# precompile pattern
our $re_fieldsep = qr/\t/;
our $re_stripnl = qr/[\r\n]+$/;
our $re_empty = qr/^\s*$/;
our $re_block = qr/^\[(\w+)\]/;
our $re_value = qr/^\s*(\S+)\s*=\s*(\S*)\s*$/;
our $re_date = qr/^(\d\d\d\d)(\d\d)(\d\d)$/;
our $re_time = qr/^(\d+):(\d+):((\d+)(\.\d+))?$/;
our $re_smode = qr/^(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)?$/;
our $re_lapsep = qr/\s+/;
our $re_laptime = qr/^(\d+):(\d+):((\d+)(\.\d+))?$/;
our $re_lapnote = qr/(\d+)\t(.*)/;

our %devs = (
	1	=> "Sport Tester",
	2	=> "Vantage NV",
	3	=> "Accurex Plus",
	4	=> "XTrainer Plus",
	6	=> "S520",
	7	=> "Coach",
	8	=> "S210",
	9	=> "S410",
	10	=> "S510",
	11	=> "S610",
	12	=> "S710",
	13	=> "S810",
	15	=> "E600",
	20	=> "AXN500",
	21	=> "AXN700",
	22	=> "S725X",
	23	=> "S725",
	33	=> "CS400",
	34	=> "CS600X",
	35	=> "CS600",
	36	=> "RS400",
	37	=> "RS800",
	38	=> "RS800X",
);

__PACKAGE__->mk_accessors( keys %defaults );

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
		fields_supported	=> {
			%fields_supported,
		},
		note	=> '',		# tmp read
		metric	=> 1,		# tmp read
		date	=> undef,	# tmp read
		time	=> 0,		# tmp read
		colfunc	=> [],		# tmp read
		blockline	=> 0,	# tmp read
		laps		=> [],	# tmp read
		cap_block	=> 0,
	});
}


=head1 METHODS

=cut

sub do_read {
	my( $self, $fh, $fname ) = @_;

	my $parser;
	my $gotparams;

	$self->{note} = "";

	binmode( $fh, ':crlf:encoding(windows-1252)' );
	while( defined(my $l = <$fh>) ){
		$l =~ s/$re_stripnl//g;

		if( $l =~/$re_empty/ ){
			next;

		} elsif( $l =~ /$re_block/ ){
			my $blockname = lc $1;
			$self->{blockline} = 0;

			if( $blockname eq 'params' ){
				$parser = \&parse_params;
				$gotparams++;

			} elsif( $blockname eq 'hrdata' ){
				$gotparams or croak "missing parameter block";
				$self->{time} ||= $self->{date}->hires_epoch;
				$parser = \&parse_hrdata;

			} elsif( $blockname eq 'inttimes' ){
				$self->{time} ||= $self->{date}->hires_epoch;
				$parser = \&parse_inttime;

			} elsif( $blockname eq 'intnotes' ){
				$parser = \&parse_intnotes;

			} elsif( $blockname eq 'extradata' ){
				# TODO: read meta extradata definition

			} elsif( $blockname eq 'trip' ){
				$parser = \&parse_trip;

			} elsif( $blockname eq 'note' ){
				$parser = \&parse_note;

			} else {
				$parser = undef;
			}
			# TODO: read meta threshold/zone limits+times

		} elsif( $parser ){
			$parser->( $self, $l );
			++$self->{blockline};

		} # else ignore input
	}

	$self->mark_new_laps( $self->{laps} ) if @{$self->{laps}};
	$self->meta_field('note', $self->{note} );
}

sub parse_params {
	my( $self, $l ) = @_;

	my( $k, $v ) = ($l =~ /$re_value/ )
		or croak "misformed input: $l";

	$k = lc $k;

	if( $k eq 'version' ){
		($v == 106 || $v == 107)
			or croak "unsupported version: $v";
	
	} elsif( $k eq 'monitor' ){
		if( exists $devs{$v} ){
			$self->meta_field( 'device', "Polar $devs{$v}" );
		}

	} elsif( $k eq 'interval' ){
		($v == 238 || $v == 204)
			and croak "unsupported data interval: $v";

		$self->{recint} = $v;
	
	} elsif( $k eq 'date' ){
		$v =~ /$re_date/
			or croak "invalid date";

		$self->{date} = DateTime->new(
			year	=> $1,
			month	=> $2,
			day	=> $3,
			time_zone	=> 'local',
		);

	} elsif( $k eq 'starttime' ){
		$v =~ /$re_time/
			or croak "invalid starttime";

		$self->{date}->add(
			hours	=> $1,
			minutes	=> $2,
			seconds	=> $4,
			nanoseconds	=> $5 * &NSEC,
		);

	} elsif( $k eq 'resthr' ){
		$self->meta_field( 'hr_rest', $v );

	} elsif( $k eq 'maxhr' ){
		$self->meta_field( 'hr_capacity', $v );

	} elsif( $k eq 'weight' ){
		$self->meta_field( 'weight', $v );

	} elsif( $k eq 'vo2max' ){
		$self->meta_field( 'vo2max', $v );

	} elsif( $k eq 'smode' ){
		@_ = $v =~ /$re_smode/
			or croak "invalid smode";

		# set unit conversion multiplieres
		my( $mspd, $mele );
		if( $_[7] ){ # uk
			$self->{metric} = 0;

			# 0.1 mph -> m/s
			# ($x/10 * 1.609344)/3.6
			$mspd = &MPH / 10;
			# ft -> m
			$mele = &FEET;

		} else { # metric
			$self->{metric} = 1;

			# 0.1 km/h -> m/s
			# ($x/10)/3.6
			$mspd = 1 / 10 / &KMH ;
			# m
			$mele = 1;
		}

		# add parser/fields for each column
		my @fields = qw/ time dur hr /;
		my @colfunc = ( sub { 'hr'	=> ($_[0] || undef) } );

		if( $_[0] ){
			push @fields, 'dist';
			push @colfunc, sub {
				'dist' => $_[0] * $mspd * $self->recint;
			};
		}

		if( $_[1] ){
			push @fields, 'cad';
			push @colfunc, sub {
				'cad' => $_[0];
			};
		}

		if( $_[2] ){
			push @fields, 'ele';
			push @colfunc, sub {
				'ele' => $_[0] * $mele;
			};
		}

		if( $_[3] ){
			push @fields, 'work';
			push @colfunc, sub {
				'work' => $_[0] * $self->recint;
			};
		}

		# TODO: support LR-balance
		# not supported, ignore:
		#push @colfunc, sub { 'pbal' => $_[0] } if ($5||$6) && $9;
		#push @colfunc, sub { 'air' => $_[0] } if $9;

		$self->fields_io( @fields );
		$self->{colfunc} = \@colfunc;
	}
	
}

sub parse_inttime {
	my( $self, $l ) = @_;

	my $row = $self->{blockline} % 5;
	my $id = int($self->{blockline} / 5 );
	my @f = split /$re_lapsep/,$l;

	if( $row == 0 ){
		if( $f[0] !~ /$re_laptime/ ){
			carp "invalid lap time in line $.";
			return;
		}

		my $delta = $3 + 60 * ( $2 + 60 * $1 );
		push @{ $self->{laps} }, {
			end	=> $self->{time} + $delta,
			meta	=> {
				note	=> undef,
				hr_min	=> $f[2],
				hr_avg	=> $f[3],
				hr_max	=> $f[4],
			},
		};

	} elsif( $row == 1 ){
		my $ele = $f[3]*10 *( $self->{metric} ? 1 : &FEET );

		$self->{laps}[$id]{ele} = $ele if $ele;

	} elsif( $row == 2 ){
		# TODO: read meta lap extra-data 1-3
		my $asc = $f[3]*10 *( $self->{metric} ? 1 : &FEET );
		my $dist = $f[4]/10 *( $self->{metric} ? 1000 : &MILE );

		$self->{laps}[$id]{ascent} = $asc if $asc;
		$self->{laps}[$id]{dist} = $dist if $dist;

	} elsif( $row == 3 ){
		# TODO: read meta lap type
		my $dist = $f[1] *( $self->{metric} ? 1 : &YARD );
		my $temp = $self->{metric}
			? $f[3] # Celsius
			: 5*($f[3] - 32 )/9; # farenheit

		$self->{laps}[$id]{dist} = $dist if $dist;
		$self->{laps}[$id]{temp} = $temp if $f[3];
	}
}

sub parse_intnotes {
	my( $self, $l ) = @_;

	if( $l !~ /$re_lapnote/ ){
		carp "skipping invalid lap note line $.";
		return;
	}

	my $lap = $1 -1;
	my $note = $2;

	if( ($lap < 0) || ($lap >= @{ $self->{laps} }) ){
		carp "skipping note for unknown lap $lap at line $.";
		return;
	}

	$note =~ s/\\n/\n/g;
	$self->{laps}[$lap]{meta}{note} = $note;
}

sub parse_trip {
	my( $self, $l ) = @_;

	my $row = $self->{blockline};
	if( $row == 0 ){
		my $v = $l / 10 * ($self->{metric}
			? 1000 : &MILE );
		$self->meta_field('dist', $v );

	} elsif( $row == 1 ){
		my $v = $l / ($self->{metric}
			? 1 : &FEET );
		$self->meta_field('ascent', $v );

	} elsif( $row == 2 ){
		$self->meta_field('dur', $l );

	} elsif( $row == 3 ){
		my $v = $l / ($self->{metric}
			? 1 : &FEET );
		$self->meta_field('ele_avg', $v );

	} elsif( $row == 4 ){
		my $v = $l / ($self->{metric}
			? 1 : &FEET );
		$self->meta_field('ele_max', $v );

	} elsif( $row == 5 ){
		my $v = $l / 128 * ($self->{metric}
			? &KMH : &MPH );
		$self->meta_field('spd_avg', $v );

	} elsif( $row == 6 ){
		my $v = $l / 128 * ($self->{metric}
			? &KMH : &MPH );
		$self->meta_field('spd_max', $v );

	} elsif( $row == 7 ){
		my $v = $l * ($self->{metric}
			? 1000 : &MILE );
		$self->meta_field('odo', $v );

	}
}

sub parse_note {
	my( $self, $l ) = @_;

	$self->{note} .= $l;
}

sub parse_hrdata {
	my( $self, $l ) = @_;

	my @row = split( /$re_fieldsep/, $l );

	$self->{time} += $self->recint;
	my %a = (
		time	=> $self->{time},
		dur	=> $self->recint,
		map {
			$_->( shift @row );
		} @{$self->{colfunc}},
	);
	$self->chunk_add( Workout::Chunk->new( \%a ));
}

sub fmtdur {
	my( $self, $sec ) = @_;

	my $xsec = ($sec - int($sec)) * 10;
	my $min = int($sec / 60 ); $sec %= 60;
	my $hrs = int($min / 60 ); $min %= 60;
	sprintf( '%02i:%02i:%02i.%1d', $hrs, $min, $sec, $xsec );
}

sub do_write {
	my( $self, $fh, $fname ) = @_;

	$self->chunk_count
		or croak "no data";

	my $laps = $self->laps;

	my %fields = map {
		$_	=> 1,
	} $self->fields_io;
	$self->debug( "writing fields: ", join(",", keys %fields ) );

	my $smode = sprintf('%0d%0d%0d%0d1110',
		$fields{dist} ? 1 : 0,
		$fields{cad} ? 1 : 0,
		$fields{ele} ? 1 : 0,
		$fields{work} ? 1 : 0,
	);
	$self->debug( "writing smode: ", $smode );
	my @colfunc = ( sub { int($_[0]->hr||0) } );
	push @colfunc, sub { int( ($_[0]->spd||0) * 36 +0.5) } if $fields{dist};
	push @colfunc, sub { int( ($_[0]->cad||0) +0.5) } if $fields{cad};
	push @colfunc, sub { int( ($_[0]->ele||0) +0.5) } if $fields{ele};
	push @colfunc, sub { int( ($_[0]->pwr||0) +0.5) } if $fields{work};

	my $sdate = DateTime->from_epoch( 
		epoch		=> $self->time_start,
		time_zone	=> $self->tz,
	); 

	my $hr_cap = int( $self->meta_field( 'hr_capacity' )
		|| $meta{hr_capacity} );
	my $hr_rest = int( $self->meta_field( 'hr_rest' )
		|| $meta{hr_rest} );
	my $vo2max = int( $self->meta_field( 'vo2max' )
		|| $meta{hr_vo2max} );
	my $weight = int( $self->meta_field( 'weight' )
		|| $meta{hr_weight} );

	# TODO: write meta device, summary

	binmode( $fh, ':crlf:encoding(windows-1252)' );
	print $fh 
"[Params]
Version=106
Monitor=12
SMode=$smode
Date=", $sdate->strftime( '%Y%m%d' ), "
StartTime=", $sdate->strftime( '%H:%M:%S.%1N' ), "
Length=", $self->fmtdur( $self->dur ), "
Interval=", $self->recint, "
Upper1=0
Lower1=0
Upper2=0
Lower2=0
Upper3=0
Lower3=0
Timer1=0:00:00.0
Timer2=0:00:00.0
Timer3=0:00:00.0
ActiveLimit=0
MaxHR=$hr_cap
RestHR=$hr_rest
StartDelay=0
VO2max=$vo2max
Weight=$weight

[Note]
", ($self->meta_field('note')||'') ,"\n\n";


	# write laps / Marker
	print $fh "[IntTimes]\n";
	foreach my $lap ( @$laps ){
		my $info = $lap->info;
		my $meta = $info->meta( $lap->meta );

		my $last_chunk = $meta->{chunk_last}
			or next;

		print $fh 
			# row 1
			join("\t", 
				$self->fmtdur( $meta->{time_end} - $self->time_start ),
				int($last_chunk->hr||0),
				int($meta->{hr_min}||0),
				int($meta->{hr_avg}||0),
				int($meta->{hr_max}||0),
				),"\n",
			# row 2
			join("\t",
				0,	# flags
				0,	# rectime
				0,	# rechr
				int( ($last_chunk->spd||0) * &KMH), # TODO check
				int($last_chunk->cad||0),
				int($last_chunk->ele||0),
				),"\n",
			# row 3
			join("\t", 
				0,	# extra1
				0,	# extra2
				0,	# extra3
				int( ($meta->{ascent}||0) /10),	# ascend
				int( ($meta->{dist}||0) /100),	# dist
				),"\n",
			# row 4
			join("\t", 
				0,	# lap type
				int($meta->{dist}||0),
				int($last_chunk->pwr||0),
				int(10 * ($last_chunk->temp||0) ),
				0,	# phase lap
				0,	# resrved
				),"\n",
			# row 5
			join("\t", 
				0,	# reserved
				0,	# reserved
				0,	# reserved
				0,	# reserved
				0,	# reserved
				0,	# reserved
				),"\n";
	}
	print $fh "\n";

	print $fh "[IntNotes]\n";
	foreach my $l ( 0 .. $#$laps ){
		my $note = $laps->[$l]->meta_field('note') or next;
		# TODO: support LR-balance
		$note =~ s/\n/\\n/g;
		print $fh $l+1, "\t", $note, "\n";
	}
	print $fh "\n";

	print $fh "[HRData]\n";
	my $it = $self->iterate;
	while( my $row = $it->next ){
		print $fh join( "\t", map {
			$_->( $row );
		} @colfunc ), "\n";
	};
}


1;
__END__

=head1 SEE ALSO

Workout::Store

=head1 AUTHOR

Rainer Clasen

=cut
