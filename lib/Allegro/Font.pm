# $Id$
#
#   This file is part of the Allegro-Perl package.
#   Copyright 2003 Colin O'Leary
#

package Allegro::Font;

use strict;
use warnings;

sub new
{
   my $proto = shift;
   my $class = ref($proto) || $proto;
   my $al = shift;
   my %opt = @_;

   my $font = { };

   if($opt{attach}) {
      $font->{font} = $opt{attach};
   } else {
      $font->{font} = Allegro::al_get_system_font();
   }

   bless $font, $class;
}

1;
