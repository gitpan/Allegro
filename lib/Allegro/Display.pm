# $Id$
#
#   This file is part of the Allegro-Perl package.
#   Copyright 2003 Colin O'Leary
#

package Allegro::Display;

use strict;
use warnings;

use Carp;
use base 'Allegro::Bitmap';

sub new
{
   my $proto = shift;
   my $class = ref($proto) || $proto;
   my $al    = shift;
   my %opt   = @_;

   if(!$al || !$al->isa('Allegro')) {
      croak "Allegro::Display::new() should be called via ->Display";
   }

   my $width  = $opt{width}  || 0;
   my $height = $opt{height} || 0;
   my $depth  = $opt{depth}  || 24;
   my $vw     = defined($opt{vw}) ? $opt{vw} : 0;
   my $vh     = defined($opt{vh}) ? $opt{vw} : 0;

   if(defined $opt{size}) {
      ($width, $height) = @{$opt{size}};
   }

   if(defined $opt{virtual}) {
      ($vw, $vh) = @{$opt{virtual}};
   }

   if(!$width || !$height) {
      $width = 640;
      $height = 480;
   }

   Allegro::al_set_color_depth($depth);

   my $driver = Allegro::AL_GFX_AUTODETECT_WINDOWED();

   if(defined($opt{mode}))
   {
      $driver = Allegro::AL_GFX_AUTODETECT_WINDOWED()
         if($opt{mode} eq 'window');
      $driver = Allegro::AL_GFX_AUTODETECT_FULLSCREEN()
         if($opt{mode} eq 'fullscreen');
      $driver = Allegro::AL_GFX_SAFE()
         if($opt{mode} eq 'safe');
   }

   if(Allegro::al_set_gfx_mode($driver, $width, $height, $vw, $vh) != 0) {
      return undef;
   }

   $al->{cap} = Allegro::al_get_gfx_capabilities();

   my $disp = { bitmap   => Allegro::al_get_screen(),
                depth    => $depth,
                al       => $al,
              };

   if($depth == 8) {
      $disp->{palette} = Allegro::al_create_palette();
      Allegro::al_get_palette($disp->{palette});
   }

   ($disp->{width}, $disp->{height}, $disp->{v_width}, $disp->{v_height}) =
      Allegro::al_get_screen_size();

   bless $disp, $class;
   $disp->set_defaults();

   return $disp;
}

sub shutdown
{
   my $self = shift;

   Allegro::al_set_gfx_mode(Allegro::AL_GFX_TEXT(), 0, 0, 0, 0);
   return $self;
}

sub v_width  { $_[0]->{v_width}  }
sub v_height { $_[0]->{v_height} }

sub title
{
   my $self = shift;
   my $title = shift;

   if($title) {
      Allegro::al_set_window_title($title);
      $self->{title} = $title;
   }

   return $title;
}

sub palette
{
   my $self = shift;
   my $pal = shift;

   if($self->{depth} != 8) {
      carp "palette() only works on 8-bit displays" if $^W;
      return undef;
   }

   if($pal) {
      Allegro::al_set_palette($pal->{palette});
      return $pal;
   }

   $pal = $self->{al}->Palette();
   Allegro::al_get_palette($pal->{palette});

   return $pal;
}

sub vsync
{
   Allegro::al_vsync();
   return $_[0];
}

sub Bitmap
{
   return Allegro::Bitmap->new(@_);
}

sub Datafile
{
   my $self = shift;
   return Allegro::Datafile($self, @_);
}

1;
