# $Id$
#
#   This file is part of the Allegro-Perl package.
#   Copyright 2003 Colin O'Leary
#

package Allegro::Bitmap;

use strict;
use warnings;

use Carp;

our $GD = undef;

# Try to load GD.pm to get PNG/JPEG support
eval { require GD };

if(!$@) {
   $GD = 1;
}

sub new
{
   my $proto = shift;
   my $class = ref($proto) || $proto;
   my $disp  = shift;
   my %opt   = @_;

   if(!$disp || (!$disp->isa('Allegro::Display') && !$disp->isa('Allegro'))) {
      croak "Allegro::Bitmap::new() should be called via ".
            "\$display->Bitmap() or \$allegro->Bitmap()";
   }

   my $bmp = { bitmap  => undef,
               palette => undef,
               width   => undef,
               height  => undef,
               depth   => undef,
               video   => 0,
               system  => 0
             };

   # Aliases
   $opt{w}  = $opt{width}      if defined $opt{width};
   $opt{h}  = $opt{height}     if defined $opt{height};
   $opt{bg} = $opt{background} if defined $opt{background};

   # Attach to previously created bitmap pointer
   if($opt{attach})
   {
      $bmp->{bitmap} = $opt{attach};

      ($bmp->{width}, $bmp->{height}) =
         Allegro::al_get_bitmap_size($bmp->{bitmap});
      $bmp->{depth} = Allegro::al_bitmap_color_depth($bmp->{bitmap});

      if(defined $opt{palette}) {
         $bmp->{palette} = $opt{palette};
      } else {
         $bmp->{palette} = undef;
      }

      $bmp->{persist} = 1;
   }

   # Create a sub-bitmap
   elsif($opt{parent})
   {
      my ($x, $y, $w, $h, $parent);

      $parent = $opt{parent};

      if(!$parent->isa('Allegro::Bitmap')) {
         carp "Bitmap() parent bitmap is invalid" if $^W;
         return undef;
      }

      $x = defined $opt{x} ? $opt{x} : 0;
      $y = defined $opt{y} ? $opt{y} : 0;
      $w = defined $opt{w} ? $opt{w} : 0;
      $h = defined $opt{h} ? $opt{h} : 0;

      $bmp->{bitmap}  = Allegro::al_create_sub_bitmap($parent->{bitmap},
                           $x, $y, $w, $h);
      $bmp->{width}   = $w;
      $bmp->{height}  = $h;
      $bmp->{depth}   = Allegro::al_bitmap_color_depth($parent->{bitmap});
      $bmp->{palette} = $parent->{palette};
      $bmp->{persist} = 1;

      if(!$bmp->{bitmap}) {
         return undef;
      }
   }

   # Load from a file
   elsif($opt{file})
   {
      my $pal = Allegro::al_create_palette();

      if(!$pal) {
         warn "Allegro::Bitmap::new() couldn't allocate palette";
         return undef;
      }

      # Convert from GD.pm if available
      if($opt{file} =~ /\.png$/i ||
         $opt{file} =~ /\.jpg$/i)
      {
         return undef if(!$GD);

         GD::Image->trueColor(1);

         my $image = GD::Image->new($opt{file});
         return undef if(!$image);

         my $data = $image->gd;
         $bmp->{bitmap} = Allegro::_load_memory_gd($data, length($data), $pal);
      }
      else
      {
         $bmp->{bitmap} = Allegro::al_load_bitmap($opt{file}, $pal);
      }

      if(!$bmp->{bitmap}) {
         Allegro::al_destroy_palette($pal);
         return undef;
      }

      ($bmp->{width}, $bmp->{height}) =
         Allegro::al_get_bitmap_size($bmp->{bitmap});
      $bmp->{depth} = Allegro::al_bitmap_color_depth($bmp->{bitmap});

      if($bmp->{depth} == 8) {
         $bmp->{palette} = $pal;
      } else {
         Allegro::al_destroy_palette($pal);
         $bmp->{palette} = undef;
      }
   }

   # Create a new bitmap
   elsif($opt{w} && $opt{h})
   {
      # Create video bitmap
      if($opt{video})
      {
         if(defined $opt{depth}) {
            carp "Bitmap() depth is ignored for video bitmaps" if $^W;
         }

         if(!$disp->isa('Allegro::Display')) {
            carp "Video bitmaps must be created by a Display object" if $^W;
            return undef;
         }

         $bmp->{bitmap}  = Allegro::al_create_video_bitmap($opt{w}, $opt{h});
         $bmp->{depth}   = $disp->{depth};
         $bmp->{video}   = 1;
         $bmp->{persist} = 1;

         if($disp->{depth} == 8) {
            $bmp->{palette} = $disp->{palette};
         } else {
            $bmp->{palette} = undef;
         }
      }

      # Create system bitmap
      elsif($opt{system})
      {
         if(defined $opt{depth}) {
            carp "Bitmap() depth is ignored for system bitmaps" if $^W;
         }

         if(!$disp->isa('Allegro::Display')) {
            carp "System bitmaps must be created by a Display object" if $^W;
            return undef;
         }

         $bmp->{bitmap}  = Allegro::al_create_system_bitmap($opt{w}, $opt{h});
         $bmp->{depth}   = $disp->{depth};
         $bmp->{system}  = 1;
         $bmp->{persist} = 1;

         if($disp->{depth} == 8) {
            $bmp->{palette} = $disp->{palette};
         } else {
            $bmp->{palette} = undef;
         }
      }

      # Create memory bitmap
      else
      {
         my $d;

         if($disp->isa('Allegro::Display')) {
            $d = $opt{depth} || $disp->{depth};
         } else {
            $d = $opt{depth} || 32;
         }

         $bmp->{bitmap}  = Allegro::al_create_bitmap_ex($d, $opt{w}, $opt{h});
         $bmp->{depth}   = $d;
         $bmp->{persist} = 0;
         $bmp->{palette} = undef;
      }

      $bmp->{width}   = $opt{w};
      $bmp->{height}  = $opt{h};

      if(!$bmp->{bitmap}) {
         return undef;
      }
   }

   else
   {
      carp "Bitmap() is missing parameters" if $^W;
      return undef;
   }

   bless $bmp, $class;

   if(defined $opt{bg}) {
      $bmp->clear(color => $opt{bg});
   }

   my %mask =
   (
      8  => Allegro::AL_MASK_COLOR_8(),
      15 => Allegro::AL_MASK_COLOR_15(),
      16 => Allegro::AL_MASK_COLOR_15(),
      24 => Allegro::AL_MASK_COLOR_24(),
      32 => Allegro::AL_MASK_COLOR_32()
   );

   $bmp->{mask} = $mask{$bmp->{depth}};
   $bmp->set_defaults();

   return $bmp;
}

sub set_defaults
{
   my $self = shift;

   $self->{default} = {
      clear_color	=> 'black',
      ellipse_border	=> 'white',
      ellipse_color	=> 'gray',
      floodfill_color	=> 'white',
      line_color	=> 'white',
      polygon_color	=> 'white',
      putpixel_color	=> 'random',
      rect_border	=> 'white',
      rect_color	=> 'gray',
      text_align	=> 'left',
      text_bg		=> -1,
      text_color	=> 'white',
      text_font		=> undef,
   };

   return $self;
}

sub DESTROY
{
   my $self = shift;

   if(!$self->{persist}) {
      Allegro::al_destroy_bitmap($self->{bitmap})   if $self->{bitmap};
      Allegro::al_destroy_palette($self->{palette}) if $self->{palette};
   }
}

sub width  { $_[0]->{width}  }
sub height { $_[0]->{height} }
sub depth  { $_[0]->{depth}  }

sub palette
{
   my $self = shift;
   return Allegro::Palette::new($Allegro::AL, attach => $self->{palette});
}

sub default
{
   my $self = shift;
   my ($key, $val) = @_;

   if($key) {
      $self->{default}->{$key} = $val if defined $val;
      return $self->{default}->{$key};
   } else {
      return $self->{default};
   }
}

sub clear
{
   my $self = shift;
   my %opt  = @_;

   $opt{color} = $self->{default}->{clear_color} if !defined $opt{color};

   Allegro::al_clear_to_color($self->{bitmap}, $self->color($opt{color}));
   return $self;
}

sub putpixel
{
   my $self = shift;
   my %opt  = @_;

   if(!defined $opt{x} || !defined $opt{y}) {
      carp "putpixel() requires x, y" if $^W;
      return undef;
   }

   $opt{color} = $self->{default}->{putpixel_color} if !defined $opt{color};

   Allegro::al_putpixel($self->{bitmap}, $opt{x}, $opt{y},
      $self->color($opt{color}));
   return $self;
}

sub getpixel
{
   my $self = shift;
   my %opt  = @_;

   if(!defined $opt{x} || !defined $opt{y}) {
      carp "getpixel() requires x, y" if $^W;
      return undef;
   }

   my $c = Allegro::al_getpixel($self->{bitmap}, $opt{x}, $opt{y});

   if($self->{depth} == 8) {
      return $c;
   } 

   my $r = Allegro::al_getr_depth($self->{depth}, $c);
   my $g = Allegro::al_getg_depth($self->{depth}, $c);
   my $b = Allegro::al_getb_depth($self->{depth}, $c);

   if($self->{depth} == 32) {
      my $a = Allegro::al_geta($c);
      return [$r, $g, $b, $a];
   }

   return [$r, $g, $b];
}

sub line
{
   my $self = shift;
   my %opt  = @_;

   $opt{x} = $opt{x1} if defined $opt{x1};
   $opt{y} = $opt{y1} if defined $opt{y1};

   $opt{color} = $self->{default}->{line_color} if !defined $opt{color};

   if(defined($opt{x})  && defined($opt{y}) &&
      defined($opt{x2}) && defined($opt{y2}))
   {
      Allegro::al_line($self->{bitmap}, $opt{x}, $opt{y},
         $opt{x2}, $opt{y2}, $self->color($opt{color}));
   }
   elsif(defined($opt{x}) && defined($opt{x2}) && defined($opt{y}))
   {
      Allegro::al_hline($self->{bitmap}, $opt{x}, $opt{y},
         $opt{x2}, $self->color($opt{color}));
   }
   elsif(defined($opt{x}) && defined($opt{y}) && defined($opt{y2}))
   {
     Allegro::al_vline($self->{bitmap}, $opt{x}, $opt{y},
         $opt{y2}, $self->color($opt{color}));
   }
   elsif(defined($opt{x}) && defined($opt{y}))
   {
      Allegro::al_putpixel($self->{bitmap}, $opt{x}, $opt{y}, 
         $self->color($opt{color}));
   }
   else
   {
      carp "line() requires (x, y) coordinate" if $^W;
      return undef;
   }

   return $self;
}

sub triangle
{
   my $self = shift;
   my %opt  = @_;

   $opt{color} = $self->{default}->{triangle_color} if !defined $opt{color};

   if(!defined $opt{x1} || !defined $opt{y1} ||
      !defined $opt{x2} || !defined $opt{y2} ||
      !defined $opt{x3} || !defined $opt{y3}) {
      carp "triangle() requires x1, y1, x2, y2, x3, y3" if $^W;
      return undef;
   }

   Allegro::al_triangle($self->{bitmap}, $opt{x1}, $opt{y2},
      $opt{x2}, $opt{y2}, $opt{x3}, $opt{y3}, $self->color($opt{color}));
   return $self;
}

sub rect
{
   my $self = shift;
   my %opt  = @_;

   if(!defined $opt{color} && !defined $opt{border}) {
      $opt{border} = $self->{default}->{rect_border};
      $opt{color}  = $self->{default}->{rect_color};
   }

   $opt{w} = $opt{width}  if defined $opt{width};
   $opt{h} = $opt{height} if defined $opt{height};

   $opt{x} = 0 if !defined $opt{x};
   $opt{y} = 0 if !defined $opt{y};

   my $x2 = $self->{width} - 1;
   my $y2 = $self->{height} - 1;

   $x2 = $opt{x2} if defined($opt{x2});
   $y2 = $opt{y2} if defined($opt{y2});

   $x2 = $opt{x} + $opt{w} - 1 if defined($opt{w});
   $y2 = $opt{y} + $opt{h} - 1 if defined($opt{h});

   if($opt{color}) {
      Allegro::al_rectfill($self->{bitmap}, $opt{x}, $opt{y}, $x2, $y2,
         $self->color($opt{color}));
   }

   if($opt{border}) {
      Allegro::al_rect($self->{bitmap}, $opt{x}, $opt{y}, $x2, $y2, 
         $self->color($opt{border}));
   }

   return $self;
}

sub ellipse
{
   my $self = shift;
   my %opt  = @_;

   $opt{w} = $opt{width}  if defined $opt{width};
   $opt{h} = $opt{height} if defined $opt{height};

   if(defined $opt{radius}) {
      $opt{w} = $opt{radius};
      $opt{h} = $opt{radius};
   }

   if(!defined $opt{x} || !defined $opt{y} ||
      !defined $opt{w} || !defined $opt{h})
   {
      carp "ellipse() requires x, y, radius" if $^W;
      return undef;
   }

   if(!defined $opt{color} && !defined $opt{border}) {
      $opt{color}  = $self->{default}->{ellipse_color};
      $opt{border} = $self->{default}->{ellipse_border};
   }

   if(defined $opt{color}) {
      Allegro::al_ellipsefill($self->{bitmap}, $opt{x}, $opt{y},
         $opt{w}, $opt{h}, $self->color($opt{color}));
   }

   if(defined $opt{border}) {
      Allegro::al_ellipse($self->{bitmap}, $opt{x}, $opt{y},
         $opt{w}, $opt{h}, $self->color($opt{color}));
   }

   return $self;
}

sub circle
{
   return Allegro::Bitmap::ellipse(@_);
}

sub floodfill
{
   my $self = shift;
   my %opt  = @_;

   $opt{color} = $self->{default}->{floodfill_color} if !defined $opt{color};

   if(!defined $opt{x} || !defined $opt{y}) {
      carp "floodfill() requires x, y" if $^W;
      return undef;
   }

   Allegro::al_floodfill($self->{bitmap}, $opt{x}, $opt{y},
      $self->color($opt{color}));
   return $self;
}

sub text
{
   my $self = shift;
   my %opt  = @_;

   $opt{x}  = 0 if !defined $opt{x};
   $opt{y}  = 0 if !defined $opt{y};

   $opt{fg} = $opt{foreground} if defined $opt{foreground};
   $opt{fg} = $opt{color}      if defined $opt{color};
   $opt{bg} = $opt{background} if defined $opt{background};

   $opt{fg}    = $self->{default}->{text_color} if !defined $opt{fg};
   $opt{bg}    = $self->{default}->{text_bg}    if !defined $opt{bg};
   $opt{align} = $self->{default}->{text_align} if !defined $opt{align};

   $opt{w} = $opt{width} if defined $opt{width};

   if(!defined $opt{text}) {
      carp "text() requires text" if $^W;
      return undef;
   }

   if($opt{align} eq 'justify' && !defined $opt{w}) {
      carp "text() requires width for justified text" if $^W;
      return undef;
   }

   my $font;

   if($opt{font}) {
      $font = $opt{font}->{font};
   } elsif($self->{default}->{text_font}) {
      $font = $self->{default}->{text_font}->{font};
   } else {
      $font = Allegro::al_get_system_font();
   }

   if($opt{bg} eq '-1') {
      Allegro::al_text_mode(-1);
   } else {
      Allegro::al_text_mode($self->color($opt{bg}));
   }

   if($opt{align} eq 'left')
   {
      Allegro::al_textout($self->{bitmap}, $font, $opt{text},
         $opt{x}, $opt{y}, $self->color($opt{fg}));
   }
   elsif($opt{align} eq 'right')
   {
      Allegro::al_textout_right($self->{bitmap}, $font, $opt{text}, 
         $opt{x}, $opt{y}, $self->color($opt{fg}));
   }
   elsif($opt{align} eq 'center' || $opt{align} eq 'centre')
   {
      Allegro::al_textout_centre($self->{bitmap}, $font, $opt{text},
         $opt{x}, $opt{y}, $self->color($opt{fg}));
   }
   elsif($opt{align} eq 'justify')
   {
      Allegro::al_textout_justify($self->{bitmap}, $font, $opt{text},
         $opt{x}, $opt{x} + $opt{w}, $opt{y}, $opt{x} + $opt{w},
         $self->color($opt{fg}));
   }
   else
   {
      carp "text() invalid align value '$opt{align}'" if $^W;
      return undef;
   }

   return $self;
}

sub polygon
{
   my $self  = shift;
   my $color;

   if(@_ & 1) {
      $color = shift;
   } else {
      $color = $self->{default}->{polygon_color};
   }

   my @points = @_;

   if(@points < 6) {
      carp "polygon() requires at least 3 points" if $^W;
      return undef;
   }

   Allegro::al_polygon($self->{bitmap}, $self->color($color), @points);
   return $self;
}

sub acquire
{
   my $self = shift;

   Allegro::al_acquire_bitmap($self->{bitmap});
   return $self;
}

sub release
{
   my $self = shift;

   Allegro::al_release_bitmap($self->{bitmap});
   return $self;
}

sub write
{
   my $self     = shift;
   my $filename = shift;
   my %opt      = @_;

   if($filename =~ /\.(png|jpg)$/i && $GD) {
      return gd_write($self, $filename, @_);
   }

   my $r;

   if($self->{palette}) {
      $r = Allegro::al_save_bitmap($filename, $self->{bitmap},
              $self->{palette});
   } else {
      $r = Allegro::al_save_bitmap($filename, $self->{bitmap},
              AL_NULL_PALETTE());
   }

   return $r == 0 ? 1 : undef;
}      

sub gd_write
{
   my $self     = shift;
   my $filename = shift;
   my %opt      = @_;

   # TODO: fix gd.c
   return undef;

   my $data;

   if($self->{palette}) {
      $data = Allegro::_create_gd($self->{bitmap}, $self->{palette});
   } else {
      $data = Allegro::_create_gd($self->{bitmap}, 
         AL_NULL_PALETTE());
   }

   return undef if(!$data);

   my $image = GD::Image->newFromGdData($data);

   if(!$image) {
      Allegro::_destroy_gd($data);
      return undef;
   }

   my ($file, $out);

   if(!open($file, '>', $filename)) {
      Allegro::_destroy_gd($data);
      return undef;
   }

   if($filename =~ /png$/i) {
      $out = $image->png;
   } else {
      $out = $image->jpeg;
   }

   binmode $file;
   print $file $out;
   close $file;

   Allegro::_destroy_gd($data);
   return $self;
}

sub color
{
   my $self = shift;

   my %colors =
   (
      black => [0, 0, 0],
      blue  => [0, 0, 255],
      gray  => [128, 128, 128],
      green => [0, 255, 0],
      red   => [255, 0, 0],
      white => [255, 255, 255],
   );

   if(@_ == 0) {
      carp "color() requires argument(s)" if $^W;
      return undef;
   }

   if($_[0] eq 'trans' || $_[0] eq 'mask' || $_[0] eq 'transparent') {
      return $self->{mask};
   }

   my ($r, $g, $b, $a);

   if($_[0] eq 'random')
   {
      # Pick a color at random
      $r = int rand 256;
      $g = int rand 256;
      $b = int rand 256;
   }
   elsif(defined $colors{$_[0]})
   {
      # Pre-defined named color
      ($r, $g, $b) = @{$colors{$_[0]}};
   }
   elsif($_[0] =~ /^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i)
   {
      # HTML style hex RGB
      ($r, $g, $b) = map { hex $_ } ($1, $2, $3);
   }
   elsif(ref $_[0] eq 'ARRAY')
   {
      # Array ref
      ($r, $g, $b, $a) = @{$_[0]};
   }
   elsif(@_ == 1 && $_[0] =~ /\d+/ && $_[0] > 0 && $_[0] < 256)
   {
      # Palette index
      return $_[0];
   }
   elsif(@_ == 3 || @_ == 4)
   {
      # List of RGB(A) params
      ($r, $g, $b, $a) = @_;
   }
   else
   {
      carp "color() invalid color" if $^W;
      return undef;
   }

   if(defined $a) {
      return Allegro::al_makeacol_depth($self->{depth}, $r, $g, $b, $a);
   } else {
      return Allegro::al_makecol_depth($self->{depth}, $r, $g, $b);
   }
}

sub blit_to
{
   my ($self, $target, %opt) = @_;

   if(!$target || !$target->isa('Allegro::Bitmap')) {
      carp "blit_to() requires a target bitmap" if $^W;
      return undef;
   }

   return $target->blit($self, %opt);
}

# TODO: implement alpha blender
sub blit
{
   my ($self, $from, %opt) = @_;

   if(!$from || !$from->isa('Allegro::Bitmap')) {
      carp "blit() requires source bitmap" if $^W;
      return undef;
   }

   my ($sx, $sy, $dx, $dy, $sh, $sw, $dh, $dw, $sd, $dd, $px, $py);

   # Get source x, y
   if(defined $opt{source}) {
      my $source = $opt{source};

      if(ref($source) ne 'ARRAY' || scalar(@$source) != 2) {
         carp "blit() invalid source param" if $^W;
         return undef;
      }

      ($sx, $sy) = @$source;
   } else {
      $sx = defined $opt{sx} ? $opt{sx} : 0;
      $sy = defined $opt{sy} ? $opt{sy} : 0;
   }

   # Get destination x, y
   if(defined $opt{dest}) {
      my $dest = $opt{dest};

      if(ref($dest) ne 'ARRAY' || scalar(@$dest) != 2) {
         carp "blit() invalid dest param" if $^W;
         return undef;
      }

      ($dx, $dy) = @$dest;
   } else {
      $dx = defined $opt{dx} ? $opt{dx} : 0;
      $dy = defined $opt{dy} ? $opt{dy} : 0;

      $dx = defined $opt{x} ? $opt{x} : $dx;
      $dy = defined $opt{y} ? $opt{y} : $dy;
   }

   # Get source width, height
   if(defined $opt{source_size}) {
      my $size = $opt{source_size};

      if(ref($size) ne 'ARRAY' || scalar(@$size) != 2) {
         carp "blit() invalid source_size param" if $^W;
         return undef;
      }

      ($sw, $sh) = @$size;
   } else {
      $sw = defined $opt{sw} ? $opt{sw} : $from->{width};
      $sh = defined $opt{sh} ? $opt{sh} : $from->{height};

      $sw = defined $opt{width}  ? $opt{width}  : $sw;
      $sh = defined $opt{height} ? $opt{height} : $sh;

      $sw = defined $opt{w} ? $opt{w} : $sw;
      $sh = defined $opt{h} ? $opt{h} : $sh;
   }

   # Get destination width, height
   if(defined $opt{dest_size}) {
      my $size = $opt{dest_size};

      if(ref($size) ne 'ARRAY' || scalar(@$size) != 2) {
         carp "blit() invalid dest_size param" if $^W;
         return undef;
      }

      ($dw, $dh) = @$size;
   } else {
      $dw = defined $opt{dw} ? $opt{dw} : $sw;
      $dh = defined $opt{dh} ? $opt{dh} : $sh;
   }

   if($opt{fit})
   {
      my $ratio = $from->{width} / $from->{height};

      if($ratio > ($self->{width} / $self->{height})
      {
         $dw = $self->{width};
         $dh = $self->{width} * (1 / $ratio);
      } else {
         $dw = $self->{height} * $ratio;
         $dh = $self->{height};
      }

      $dx = ($self->{width} - $dw) / 2;
      $dy = ($self->{height} - $dh) / 2;
   }

   # Color depths
   $sd = $from->{depth};
   $dd = $from->{depth};

   my $src = $from->{bitmap};
   my $dst = $self->{bitmap};
   my $tmp = undef;

   my $mask    = $opt{masked} ? 1 : 0;
   my $stretch = (($sw != $dw) || ($sh != $dh));
   my $rotate  = 0;

   if(defined $opt{rotate}) {
      $mask = 1;
      $rotate = 1;

      if($opt{rotate} < 0.0 || $opt{rotate} >= 1.0) {
         carp "blit() invalid rotate param" if $^W;
         return undef;
      }
   }

   # Standard blit (depth conversion allowed)
   if(!$mask && !$stretch)
   {
      Allegro::al_blit($from->{bitmap}, $self->{bitmap},
         $sx, $sy, $dx, $dy, $sw, $sh);
      return $self;
   }

   if($rotate && ($sx != 0 || $sy != 0)) {
      carp "blit() rotated blit requires source (x, y) to be 0" if $^W;
      return undef;
   }

   # Rotated blit (depth conversion allowed)
   if($rotate && !$stretch)
   {
      if(defined $opt{origin}) {
         my @origin = @{$opt{origin}};

         if(@origin != 2) {
            carp "blit() invalid origin" if $^W;
            return undef;
         }

         ($px, $py) = @origin;
      } else {
         $px = 0;
         $py = 0;
      }

      Allegro::al_pivot_sprite($self->{bitmap}, $src, $dx, $dy,
         $px, $py, $opt{rotate} * 256);
      return $self;
   }

   # Create a temporary bitmap if:
   #   - color depths don't match
   #   - bitmaps are same (this should really check for overlapping)
   #   - doing a stretch blit and source is not a memory bitmap
   #   - doing a masked blit and source is not a memory bitmap and
   #       vram -> vram masked blits aren't allowed
   if(($sd != $dd)                                      ||
      (Allegro::al_is_same_bitmap($src, $dst))          ||
      ($stretch && !Allegro::al_is_memory_bitmap($src)) ||
      ($mask && Allegro::al_is_system_bitmap($src))     ||
      ($mask && Allegro::al_is_video_bitmap($src) &&
         !($Allegro::AL->{cap} & AL_GFX_HW_VRAM_BLIT_MASKED())))
   {
      $tmp = al_create_bitmap_ex($dd, $sw, $sh);

      if(!$tmp) {
         warn "couldn't allocate bitmap.";
         return undef;
      }

      # print "creating temp copy $sw x $sh x $dd from $dd \@ $sx, $sy\n";
      Allegro::al_blit($src, $tmp, $sx, $sy, 0, 0, $sw, $sh);
      $src = $tmp;
      $sx  = 0;
      $sy  = 0;
   }

   # Do stretched/masked blit
   if($stretch && $mask)
   {
      Allegro::al_masked_stretch_blit($src, $dst, $sx, $sy, $sw, $sh,
         $dx, $dy, $dw, $dh);
   }
   elsif($stretch)
   {
      Allegro::al_stretch_blit($src, $dst, $sx, $sy, $sw, $sh,
         $dx, $dy, $dw, $dh);
   }
   elsif($mask)
   {
      Allegro::al_masked_blit($src, $dst, $sx, $sy, $dx, $dy, $sw, $sh);
   }

   if($tmp) {
      Allegro::al_destroy_bitmap($tmp);
   }

   return $self;
}

1;
