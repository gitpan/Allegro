# $Id$
#
#   This file is part of the Allegro-Perl package.
#   Copyright 2003 Colin O'Leary
#

package Allegro::Sound;

use strict;
use warnings;

use Carp;

sub new
{
   my $proto = shift;
   my $class = ref($proto) || $proto;
   my $al    = shift;
   my %opt   = @_;

   my ($digi, $midi);

   $digi = defined $opt{digi} ? $opt{digi} : Allegro::AL_DIGI_AUTODETECT();
   $midi = defined $opt{midi} ? $opt{midi} : Allegro::AL_MIDI_AUTODETECT();

   if(Allegro::al_install_sound($digi, $midi, 0) != 0) {
      return undef;
   }

   $al->{digi} = $digi;
   $al->{midi} = $midi;

   bless {}, $class;
}

sub shutdown
{
   my $self = shift;

   Allegro::al_remove_sound();
   return $self;
}

sub volume
{
   my $self = shift;
   my %opt = @_;

   if(defined $opt{digi}) {
      Allegro::al_set_volume($opt{digi}, -1);
   }

   if(defined $opt{midi}) {
      Allegro::al_set_volume(-1, $opt{midi});
   }

   return $self;
}

1;
