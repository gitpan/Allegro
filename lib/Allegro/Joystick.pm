# $Id$
#
#   This file is part of the Allegro-Perl package.
#   Copyright 2003 Colin O'Leary
#
# The internal object representation here is a mess, but it mirrors
# the allegro joystick interface.  Use button() and position() to
# get easier to access data.
#
# Joystick
#      |-- index	joystick number (used for allegro routines)
#      |-- sticks	number of sticks (each may have multiple axes)
#      |-- buttons	number of buttons
#      |-- digital	set if provides digital input
#      |-- analog       set if provides analog input
#      |-- mode         default mode (digital/analog) to return
#      |-- s		stick data (array)
#      |   |
#      |   |-- name	description
#      |   |-- axes	number of axes
#      |   |-- flags	flags from allegro
#      |   |-- axis     axis data (array)
#      |       |
#      |       |-- name		description
#      |       |-- flags	flags from allegro
#      |       |-- analog	analog input
#      |       |-- digital	digital input
#      |       |-- status	status based on analog/digital flag
#      |-- b		button data (array)
#          |
#          |-- name	description
#          |-- status	on/off status
#

package Allegro::Joystick;

use strict;
use warnings;

use Carp;

my $index = -1;

sub count
{
   install();
   return Allegro::al_get_num_joysticks();
}

sub install
{
   if(Allegro::al_install_joystick(Allegro::AL_JOY_TYPE_AUTODETECT()) != 0) {
      return 0;
   }

   $index = 0;
   return Allegro::al_get_num_joysticks();
}

sub new
{
   my $proto = shift;
   my $class = ref($proto) || $proto;
   my $al    = shift;
   my %opt   = @_;

   if($opt{fake}) {
      my $self = { buttons => 0,
                   sticks  => 0,
                   fake    => 1 };

      bless $self, $class;
      return $self;
   }

   if($index == -1 && !install()) {
      return undef;
   }

   my $i;

   if(defined $opt{joystick}) {
      $i = $opt{joystick};
   } else {
      $i = $index;
      $index++;
   }

   if($i < 0 || $i >= Allegro::al_get_num_joysticks()) {
      if(defined $opt{joystick}) {
         carp "Joystick() invalid joystick" if $^W;
      }

      return undef;
   }

   my ($flags, $sticks, $buttons) = Allegro::al_get_joystick_info($i);

   my $joy = { index     => $i,
               sticks    => $sticks,
               buttons   => $buttons,
               digital   => 0,
               analog    => 0,
               calibrate => 0
             };

   if($flags & Allegro::AL_JOYFLAG_DIGITAL()) {
      $joy->{digital} = 1;
   }

   if($flags & Allegro::AL_JOYFLAG_ANALOGUE()) {
      $joy->{analog} = 1;
   }

   if($opt{mode}) {
      $joy->{mode} = $opt{mode};

      if($joy->{mode} ne 'digital' && $joy->{mode} ne 'analog') {
         carp "Joystick() invalid mode" if $^W;
         return undef;
      }
   } elsif($joy->{digital}) {
      $joy->{mode} = 'digital';
   } else {
      $joy->{mode} = 'analog';
   }

   if($flags & Allegro::AL_JOYFLAG_CALIBRATE()) {
      $joy->{calibrate} = 1;
   }

   Allegro::al_poll_joystick();

   for(my $j = 0; $j < $buttons; $j++) {
      my ($status, $name) =
         Allegro::al_get_joystick_button_info($i, $j);

      $joy->{b}->[$j] = { name   => $name,
                          status => $status };
   }

   for(my $j = 0; $j < $sticks; $j++) {
      my ($flags, $axes, $name) =
         Allegro::al_get_joystick_stick_info($i, $j);

      $joy->{s}->[$j] = { name  => $name,
                          flags => $flags,
                          axes  => $axes   };

      if($flags & Allegro::AL_JOYFLAG_DIGITAL()) {
      } else {
      }

      for(my $k = 0; $k < $axes; $k++) {
         my ($analog, $digital, $name) =
            Allegro::al_get_joystick_axis_info($i, $j, $k);

         my $status = $joy->{s}->[$j]->{digital} ? $digital : $analog;

         $joy->{s}->[$j]->{axis}->[$k] = { name    => $name,
                                           analog  => $analog,
                                           digital => $digital,
                                           status  => $status   };
      }
   }

   bless $joy, $class;
}

sub poll
{
   my $self = shift;
   my %opt  = @_;

   return $self if($self->{fake});

   my $i = $self->{index};
   my $mode;

   if($opt{mode}) {
      $mode = $opt{mode};

      if($mode ne 'digital' && $mode ne 'analog') {
         carp "poll() invalid mode" if $^W;
         return undef;
      }
   } else {
      $mode = $self->{mode};
   }

   Allegro::al_poll_joystick();

   for(my $j = 0; $j < $self->{buttons}; $j++) {
      my ($status, $name) =
         Allegro::al_get_joystick_button_info($i, $j);

      $self->{b}->[$j]->{status} = $status;
   }

   for(my $j = 0; $j < $self->{sticks}; $j++)
   {
      for(my $k = 0; $k < $self->{s}->[$j]->{axes}; $k++)
      {
         my ($analog, $digital, $name) =
            Allegro::al_get_joystick_axis_info($i, $j, $k);

         $self->{s}->[$j]->{axis}->[$k]->{analog}  = $analog;
         $self->{s}->[$j]->{axis}->[$k]->{digital} = $digital;

         $self->{s}->[$j]->{axis}->[$k]->{status} =
            ($mode eq 'digital') ? $digital : $analog;
      }
   }

   return $self;
}

sub calibrate_text
{
   my $self = shift;

   return undef if($self->{fake});
   return Allegro::al_calibrate_joystick_name($self->{index});
}

sub calibrate
{
   my $self = shift;

   return undef if($self->{fake});

   if(Allegro::al_calibrate_joystick($self->{index}) == 0) {
      return $self;
   }

   return undef;
}
   
sub button
{
   my $self = shift;

   $self->poll;

   if(defined($_[0])) {
      return undef if($self->{fake});
      return $self->{b}->[$_[0]]->{status};
   } else {
      return () if($self->{fake});

      my @a;

      for(0 .. ($self->{buttons}-1)) {
         push(@a, $self->{b}->[$_]->{status});
      }
      return @a;
   }
}

sub position
{
   my $self = shift;
   my $s = defined($_[0]) ? $_[0] : -1;
   my $a = defined($_[1]) ? $_[1] : -1;

   $self->poll;

   if($s >= 0 && $a >= 0) {
      return undef if($self->{fake});
      return $self->{s}->[$s]->{axis}->[$a]->{status};
   }

   return () if($self->{fake});

   my @a;

   if($s >= 0) {
      for(my $i = 0; $i < $self->{s}->[$s]->{axes}; $i++) {
         push(@a, $self->{s}->[$s]->{axis}->[$i]->{status});
      }
   } else {
      for(my $i = 0; $i < $self->{sticks}; $i++) {
         for(my $j = 0; $j < $self->{s}->[$i]->{axes}; $j++) {
            push(@a, $self->{s}->[$i]->{axis}->[$j]->{status});
         }
      }
   }

   return @a;
}

sub buttons { return $_[0]->{buttons} }
sub sticks  { return $_[0]->{sticks}  }

sub axes
{
   my $self  = shift;
   my $stick = shift;

   return 0 if($self->{fake});

   $stick ||= 0;
   return $self->{s}->[$stick]->{axes};
}

sub button_name
{
   my $self   = shift;
   my $button = shift;

   if(defined $button) {
      return $self->{b}->[$button]->{name};
   } else {
      my @names;
      push @names, $_->{name} for @{$self->{b}};
      return @names;
   }
}

sub stick_name
{
   my $self  = shift;
   my $stick = shift;

   if(defined $stick) {
      return $self->{s}->[$stick]->{name};
   } else {
      my @names;
      push @names, $_->{name} for @{$self->{s}};
      return @names;
   }
}

sub axis_name
{
   my $self  = shift;
   my $stick = shift;
   my $axis  = shift;

   if(!defined $stick) {
      carp "axis_name() requires at least one arg" if $^W;
      return undef;
   }

   if(defined $axis) {
      return $self->{s}->[$stick]->{axis}->[$axis]->{name};
   } else {
      my @names;
      push @names, $_->{name} for @{$self->{s}->[$stick]->{axis}};
      return @names;
   }
}

1;
