# $Id$
#
#   This file is part of the Allegro-Perl package.
#   Copyright 2003 Colin O'Leary
#

package Allegro::Sample;

use strict;
use warnings;

use Carp;

sub new
{
   my $proto = shift;
   my $class = ref($proto) || $proto;
   my $al    = shift;
   my %opt   = @_;

   my $sample = { sample => undef };

   if($opt{attach}) {
      $sample->{sample}  = $opt{attach};
      $sample->{persist} = 1;
   } elsif($opt{file}) {
      $sample->{sample}  = Allegro::al_load_sample($opt{file});
   } else {
      carp "Sample() requires file" if $^W;
      return undef;
   }

   if(!$sample->{sample}) {
      return undef;
   }

   bless $sample, $class;
}

sub DESTROY
{
   my $self = shift;

   if(!$self->{persist}) {
      Allegro::al_destroy_sample($self->{sample}) if $self->{sample};
   }

   return undef;
}

sub play
{
   my $self = shift;
   my %opt  = @_;

   $opt{volume} = $opt{vol} if defined $opt{vol};

   my $vol  = defined $opt{volume} ? $opt{volume} : 255;
   my $pan  = defined $opt{pan}    ? $opt{pan}    : 127;
   my $freq = defined $opt{freq}   ? $opt{freq}   : 1000;
   my $loop = defined $opt{loop}   ? $opt{loop}   : 0;

   Allegro::al_play_sample($self->{sample}, $vol, $pan, $freq, $loop);
   return $self;
}

sub adjust
{
   my $self = shift;
   my %opt  = @_;

   $opt{volume} = $opt{vol} if defined $opt{vol};

   my $vol  = defined $opt{volume} ? $opt{volume} : 255;
   my $pan  = defined $opt{pan}    ? $opt{pan}    : 127;
   my $freq = defined $opt{freq}   ? $opt{freq}   : 1000;
   my $loop = defined $opt{loop}   ? $opt{loop}   : 0;

   Allegro::al_adjust_sample($self->{sample}, $vol, $pan, $freq, $loop);
   return $self;
}

sub stop
{
   my $self = shift;

   Allegro::al_stop_sample($self->{sample});
   return $self;
}

1;
