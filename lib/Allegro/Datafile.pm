# $Id$
#
#   This file is part of the Allegro-Perl package.
#   Copyright 2003 Colin O'Leary
#

package Allegro::Datafile;

use strict;
use warnings;

use Carp;

my $AL_DAT_INFO = Allegro::al_id("info");

sub new
{
   my $proto = shift;
   my $class = ref($proto) || $proto;
   my $al    = shift;
   my %opt   = @_;

   if($al->isa('Allegro::Display')) {
      $al = $al->{al};
   }

   my $data = { datafile => undef };

   if($opt{attach})
   {
      $data->{datafile} = $opt{attach};
      $data->{persist}  = 1;
   }
   elsif($opt{file})
   {
      if($opt{password}) {
         Allegro::al_packfile_password($opt{password});
      }

      $data->{datafile} = Allegro::al_load_datafile($opt{file});

      Allegro::al_packfile_password(0);

      if(!$data->{datafile}) {
         return undef;
      }
   } else {
      carp "Datafile() requires file" if $^W;
      return undef;
   }

   my %objects = ();

   $data->{size} = Allegro::al_get_datafile_size($data->{datafile});

   for(0 .. $data->{size}) {
      my $obj = create($al, $data->{datafile}, $_);

      if($obj) {
         $objects{$obj->{name}} = $obj;
      }
   }

   $data->{objects} = \%objects;

   bless $data, $class;
   return $data;
}

sub DESTROY
{
   my $self = shift;

# TODO: safely destroy datafile objects
#  Allegro::al_unload_datafile($self->{datafile});
   return 0;
}

sub create
{
   my ($al, $data, $i) = @_;

   if(@_ < 2) {
      $i = -1;
   }

   my $ptr   = Allegro::al_get_datafile_data($data, $i);
   my $atype = Allegro::al_get_datafile_type($data, $i);
   my $ref   = \$ptr;
   my $type  = undef;
   my $obj   = undef;

   return undef if($atype == AL_DAT_END());
   return undef if($atype == $AL_DAT_INFO);

   if($atype == Allegro::AL_DAT_FILE()) {
      $type = "Datafile";
      $obj = $al->Datafile(attach => bless($ref, "DATAFILEPtr"));
   } elsif($atype == Allegro::AL_DAT_FONT()) {
      $type = "Font";
      $obj = $al->Font(attach => bless($ref, "FONTPtr"));
   } elsif($atype == Allegro::AL_DAT_SAMPLE()) {
      $type = "Sample";
      $obj = $al->Sample(attach => bless($ref, "SAMPLEPtr"));
   } elsif($atype == Allegro::AL_DAT_MIDI()) {
      $type = "MIDI";
      $obj = $al->MIDI(attach => bless($ref, "MIDIPtr"));
   } elsif($atype == Allegro::AL_DAT_BITMAP()) {
      $type = "Bitmap";
      $obj = $al->Bitmap(attach => bless($ref, "BITMAPPtr"));
   } elsif($atype == Allegro::AL_DAT_PALETTE()) {
      $type = "Palette";
      $obj = $al->Palette(attach => bless($ref, "RGBPtr"));
   } elsif($atype == Allegro::AL_DAT_RLE_SPRITE()) {
      my $rle = bless($ref, "RLE_SPRITEPtr");
      my ($w, $h) = Allegro::al_get_rle_size($rle);
      my $d = Allegro::al_get_rle_depth($rle);

      my $bmp = Allegro::al_create_bitmap_ex($d, $w, $h);

      if(!$bmp) {
         warn "Couldn't allocate bitmap";
         return undef;
      }

      Allegro::al_draw_rle_sprite($bmp, $rle, 0, 0);
      $type = "Bitmap";
      $obj = $bmp;
   } elsif($atype == Allegro::AL_DAT_FLI()) {
      $type = "FLIC";
      $obj = $ref;
   } elsif($atype == Allegro::AL_DAT_DATA()) {
      $type = "data";
      $obj = $ref;
   } else {
      $type = "unknown";
      $obj = $ref;
   }

   if($type && $obj) {
      my $name = Allegro::al_get_datafile_property($data, $i, "NAME");

      if(!$name) {
         $name = "object_$i";
      }

      return { name   => $name,
               type   => $type,
               object => $obj   };
   }

   return undef;
}

sub object
{
   my $self = shift;
   my $name = shift;
   my $type = shift;

   my $obj = $self->{objects}->{$name};

   if(!$obj) {
      return undef;
   }

   if($type && ref($type)) {
      $$type = $obj->{type};
   }

   return $obj->{object};
}

sub names
{
   my $self = shift;

   return keys %{$self->{objects}};
}

1;

