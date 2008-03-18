package Workout::Filter::Join;

=head1 NAME

Workout::Filter::Join - Join blocks within Workout data

=head1 SYNOPSIS

  $src = Workout::Store::SRM->new( "foo.srm" );
  $join = Workout::Filter::Join->new( $src );
  while( my $chunk = $join->next ){
  	# do something
  }

=head1 DESCRIPTION

Iterator that automagically fills the gaps between individual data blocks
with fake chunks.

=cut

use 5.008008;
use strict;
use warnings;
use base 'Workout::Filter::Base';
use Carp;

our $VERSION = '0.01';

=head2 new( $src, $arg )

new iterator

=cut

sub new {
	my $class = shift;
	my $self = $class->SUPER::new( @_ );
	$self->{queued} = undef;
	$self->{last} = undef;
	$self;
}

=head2 next

get next data chunk

=cut

sub next {
	my( $self ) = @_;

	if( $self->{queued} ){
		$self->{last}= $self->{queued};
		$self->{queued} = undef;
		$self->{cntout}++;
		return $self->{last};
	}

	my $t = $self->src->next
		or return;
	$self->{cntin}++;

	my $l = $self->{last};
	my $ltime = $t->{time} - $t->{dur};
	if( $l && abs($ltime - $l->{time}) > 0.1){
		$self->{queued} = $t;
		$t = {
			time    => $ltime,
			dur     => $ltime - $l->{time},
		}
	}

	$self->{last} = $t;
	$self->{cntout}++;
	return $t;
}


1;
__END__

=head1 SEE ALSO

Workout::Filter::Base

=head1 AUTHOR

Rainer Clasen

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Rainer Clasen

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
