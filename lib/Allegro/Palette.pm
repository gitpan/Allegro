# $Id$
#
#   This file is part of the Allegro-Perl package.
#   Copyright 2003 Colin O'Leary
#

package Allegro::Palette;

use strict;
use warnings;

use Carp;

sub new
{
   my $proto = shift;
   my $class = ref($proto) || $proto;
   my $al    = shift;
   my %opt   = @_;

   my $pal = { };

   if($opt{attach}) {
      $pal->{palette} = $opt{attach};
      $pal->{persit}  = 1;
   } else {
      $pal->{palette} = Allegro::al_create_palette();

      if(!$pal->{palette}) {
         warn "Allegro::Palette::new() couldn't allocate palette";
         return undef;
      }
   }

   bless $pal, $class;
   return $pal;
}

sub DESTROY
{
   my $self = shift;

   if(!$self->{persist}) {
      Allegro::al_destroy_palette($self->{palette}) if $self->{palette};
   }

   return undef;
}

sub set
{
   my $self = shift;
   my ($i, $r, $g, $b) = @_;

   if(@_ == 0 || $i < 0 || $i > 255) {
      carp "set() invalid index" if $^W;
      return;
   }

   if(@_ != 4) {
      carp "set() requires r, g, b values" if $^W;
      return;
   }

   Allegro::al_set_palette_color($self->{palette}, $i, $r, $g, $b);
   return $self;
}

sub get
{
   my $self = shift;

   if(@_ != 1) {
      carp "Allegro::Palette::get() requires index" if $^W;
      return undef;
   }

   if($_[0] < 0 || $_[0] > 255) {
      carp "Allegro::Palette::get() invalid index" if $^W;
      return undef;
   }

   return Allegro::al_get_palette_color($self->{palette}, $_[0]);
}

1;
