# $Id$
#
#   This file is part of the Allegro-Perl package.
#   Copyright 2003 Colin O'Leary
#

package Allegro::Timer;

use strict;
use warnings;

use Carp;

use base 'Exporter';
our @EXPORT    = qw(sleep);
our @EXPORT_OK = qw();

my %active_timers = ();
my $init = 0;
my $have_alarm;

sub async_poll
{
   for (values %active_timers)
   {
      if($_->{param}) {
         $_->real_poll(@{$_->{param}});
      } else {
         $_->real_poll();
      }
   }
}

sub sleep
{
   Allegro::al_rest($_[0] * 1000);
}

sub init
{
   my $class = shift;
   $init = 1;

   eval { require Time::HiRes;
          import Time::HiRes qw/setitimer ITIMER_REAL/;
        };

   if(!$@) {
      $have_alarm = 1;
      $SIG{ALRM} = \&async_poll;
      setitimer(ITIMER_REAL(), 0.001, 0.001);
   };
}

sub new
{
   my $proto = shift;
   my $class = ref($proto) || $proto;
   my $al    = shift;
   my %opt   = @_;

   init($proto) if(!$init);

   my $code = $opt{code};
   my $wait = $opt{wait} || $opt{interval};

   if(!$al->{timer}) {
      return undef;
   }

   if(!$code) {
      carp "Timer->new requires code param" if $^W;
      return undef;
   }

   if(!$wait) {
      carp "Timer->new requires interval param" if $^W;
      return undef;
   }

   my $param = undef;

   if($opt{param}) {
      if(ref($opt{param}) eq 'ARRAY') {
         $param = $opt{param};
      } else {
         $param = [ $opt{param} ];
      }
   }

   my $timer = { code  => $code,
                 wait  => $wait,
                 param => $param,
               };

   $timer->{id} = Allegro::al_create_timer();

   if($timer->{id} < 0) {
      warn "Couldn't create Allegro timer.";
      return undef;
   }

   if($have_alarm) {
      $timer->{needs_poll} = 0;
   } else {
      $timer->{needs_poll} = 1;
   }

   bless $timer, $class;

   $timer->start if(!$opt{defer});
   return $timer;
}

sub needs_poll
{
   return $_[0]->{needs_poll};
}

sub start
{
   my $self = shift;

   Allegro::al_start_timer($self->{id}, $self->{wait});
   $active_timers{$self->{id}} = $self;

   return $self;
}

sub stop
{
   my $self = shift;

   Allegro::al_stop_timer($self->{id});
   delete $active_timers{$self->{id}};

   return $self;
}

sub poll
{
   my $self = shift;

   if($self->{needs_poll}) {
      return $self->real_poll(@_);
   }

   return $self;
}

sub real_poll
{
   my $self = shift;

   my $i = Allegro::al_get_timer_updates($self->{id});

   while($i--) {
      if($self->{param}) {
         &{$self->{code}}(@{$self->{param}});
      } else {
         &{$self->{code}}();
      }

      Allegro::al_decrement_timer($self->{id});
   }

   return $self;
}

1;
