# $Id$
#
#   This file is part of the Allegro-Perl package.
#   Copyright 2003 Colin O'Leary
#

package Allegro::Mouse;

use strict;
use warnings;

use Carp;

use Allegro::Bitmap;

sub new
{
   my $proto = shift;
   my $class = ref($proto) || $proto;
   my $al    = shift;
   my $m;

   $m->{buttons} = Allegro::al_install_mouse();

   if($m->{buttons} == -1) {
      return undef;
   }

   $m->{poll}    = Allegro::al_mouse_needs_poll();
   $m->{stale}   = 1;
   $m->{xspeed}  = 2;
   $m->{yspeed}  = 2;

   for (0 .. ($m->{buttons}-1)) {
      $m->{b}[$_] = 0;
   }

   bless $m, $class;
}

sub shutdown
{
   Allegro::al_remove_mouse();
}

sub poll
{
   my $self = shift;

   Allegro::al_poll_mouse();

   my ($x, $y, $z, $b) = Allegro::al_get_mouse_info();

   $self->{x} = $x;
   $self->{y} = $y;
   $self->{z} = $z;

   my $mask = 1;

   for my $x (@{$self->{b}}) {
      $x = ($b & $mask) ? 1 : 0;
      $mask <<= 1;
   }

   $self->{stale} = 0;
   return $self;
}

sub button
{
   my $self = shift;

   $self->poll;

   if(defined($_[0])) {
      if($_[0] >= $self->{buttons}) {
         carp "button() invalid button $_[0]" if $^W;
         return undef;
      }

      return $self->{b}->[$_[0]];
   } else {
      return @{$self->{b}};
   }
}

sub position
{
   my $self = shift;

   $self->poll;

   if(defined($_[0])) {
      return $self->{$_[0]};
   } else {
      return ($self->{x}, $self->{y}, $self->{z});
   }
}

sub show
{
   my $self = shift;
   my $bmp  = shift;

   if(!$bmp || !$bmp->isa('Allegro::Bitmap')) {
      carp "show() requires bitmap" if $^W;
      return undef;
   }

   Allegro::al_show_mouse($bmp->{bitmap});
   return $self;
}

sub hide
{
   Allegro::al_show_mouse(Allegro::AL_NULL_BITMAP());
   return $self;
}

sub scare
{
   my $self = shift;
   my %opt  = @_;

   $opt{w} = $opt{width}  if defined $opt{width};
   $opt{h} = $opt{height} if defined $opt{height};

   if(defined $opt{x} && defined $opt{y} &&
      defined $opt{w} && defined $opt{h})
   {
      Allegro::al_scare_mouse_area($opt{x}, $opt{y}, $opt{w}, $opt{h});
   } else {
      Allegro::al_scare_mouse();
   }

   return $self;
}

sub unscare
{
   Allegro::al_unscare_mouse();
   return $self;
}

sub freeze
{
   Allegro::_freeze_mouse(1);
   return $self;
}

sub unfreeze
{
   Allegro::_freeze_mouse(0);
   return $self;
}

sub set
{
   my $self = shift;
   my %opt  = @_;

   if(!defined($opt{x}) || !defined($opt{y})) {
      carp "set() requires x, y" if $^W;
      return undef;
   }

   Allegro::al_position_mouse($opt{x}, $opt{y});

   if(defined($opt{z})) {
      Allegro::al_position_mouse_z($opt{z});
   }

   return $self;
}

sub clip
{
   my $self = shift;
   my %opt  = @_;

   $opt{w} = $opt{width}  if defined $opt{width};
   $opt{h} = $opt{height} if defined $opt{height};

   if(defined $opt{x} && defined $opt{y} &&
      defined $opt{w} && defined $opt{h})
   {
      Allegro::al_set_mouse_range($opt{x}, $opt{h}, $opt{x} + $opt{w},
         $opt{y} + $opt{h});
      return $self;
   }

   carp "clip() requires x, y, width, height" if $^W;
   return undef;
}

sub speed
{
   my $self = shift;
   my %opt  = @_;

   if(defined $opt{x}) {
      $self->{xspeed} = $opt{x};
   }

   if(defined $opt{y}) {
      $self->{yspeed} = $opt{y};
   }

   Allegro::al_set_mouse_speed($self->{xspeed}, $self->{yspeed});
   return ($self->{xspeed}, $self->{yspeed});
}

sub sprite
{
   my $self = shift;
   my %opt  = @_;

   if($opt{bitmap})
   {
      if($opt{bitmap} eq 'default') {
         Allegro::al_set_mouse_sprite(AL_NULL_BITMAP());
      } else {
         if(!$opt{bitmap}->isa('Allegro::Bitmap')) {
            carp "sprite() invalid bitmap" if $^W;
            return undef;
         }

         Allegro::al_set_mouse_sprite($opt{bitmap}->{bitmap});
      }
   }

   if(defined $opt{x} && defined $opt{y}) {
      Allegro::al_set_mouse_sprite_focus($opt{x}, $opt{y});
   }

   return $self;
}

sub mickeys
{
   my ($x, $y);

   Allegro::al_get_mouse_mickeys($x, $y);
   return ($x, $y);
}

1;
