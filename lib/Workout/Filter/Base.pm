#
# Copyright (c) 2008 Rainer Clasen
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms described in the file LICENSE included in this
# distribution.
#

=head1 NAME

Workout::Filter::Base - Base Class to filter Workout chunks

=head1 SYNOPSIS

  # read SRM file with 1sec recint and multiple blocks
  $src = Workout::Store::SRM->read( "input.srm" ); 
  $it = Workout::Filter::Join->new( $src->iterate );
  while( defined(my $chunk = $it->next)){
  	print join(",",@$chunk{qw(time dur pwr)}),"\n";
  }

=head1 DESCRIPTION

Base Class for modifying and filtering the Chunks of a Workout.

=cut

package Workout::Filter::Base;

use 5.008008;
use strict;
use warnings;
use base 'Workout::Iterator';
use Carp;

our $VERSION = '0.01';


=head2 new( $iter, $arg )

create empty Iterator.

=cut

sub new {
	my( $class, $iter, $a ) = @_;

	$iter->isa( 'Workout::Iterator' )
		or $iter = $iter->iterate( $a );

	$a ||= {};
	$class->SUPER::new( $iter, {
		%$a,
		queue	=> [],
	});
}

sub _push {
	my $self = shift;
	push @{$self->{queue}}, @_;
}

sub _pop {
	my $self = shift;
	pop @{$self->{queue}};
}

sub _fetch {
	my( $self ) = @_;

	if( my $r = $self->_pop ){
		return $r;
	}

	if( my $r = $self->src->next ){
		$self->{cntin}++;
		return $r;
	}

	return;
}


1;
__END__

=head1 SEE ALSO

Workout::Iterator

=head1 AUTHOR

Rainer Clasen

=cut

