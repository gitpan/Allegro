# $Id$
#
#   This file is part of the Allegro-Perl package.
#   Copyright 2003 Colin O'Leary
#

package Allegro::Keyboard;

use strict;
use warnings;

use Carp;

my (%keys, %names);

sub new
{
   my $proto = shift;
   my $class = ref($proto) || $proto;
   my $al    = shift;
   my %opt   = @_;

   if(Allegro::al_install_keyboard() != 0) {
      return undef;
   }

   my $kb = { };

   $kb->{mode} = $opt{mode} || 'key';

   bless $kb, $class;
   return $kb;
}

sub shutdown
{
   Allegro::al_remove_keyboard();
   return $_[0];
}

sub pressed
{
   my $self = shift;
   my $key  = shift;

   if(defined $key) {
      $key = lc $key;

      if($key =~ /^#(\d+)$/) {
         return Allegro::al_get_key($key);
      } elsif(exists($keys{$key})) {
         return Allegro::al_get_key($keys{$key});
      } else {
         carp "pressed() invalid key '$key'" if $^W;
         return undef;
      }
   } else {
      return Allegro::al_keypressed();
   }
}

sub read
{
   my $self = shift;
   my %opt  = @_;
   my ($mode, $scan, $ascii, $key);

   $mode = defined($opt{mode}) ? $opt{mode} : $self->{mode};

   if($mode ne 'key' && $mode ne 'ascii' && $mode ne 'both') {
      carp "read() invalid mode" if $^W;
      return undef;
   }

   ($ascii, $scan) = Allegro::al_readkey();

   if(exists($names{$scan})) {
      $key = $names{$scan};
   } else {
      $key = "#$scan";
   }

   if($mode eq 'key') {
      return $key;
   } elsif($mode eq 'ascii') {
      return chr($ascii);
   } else {
      return ($key, chr($ascii));
   }
}

sub simulate
{
   my ($self, @keys) = @_;

   @keys = map { $_ = lc $_ } @keys;

   for my $key (@keys)
   {
      if($key =~ /^#(\d+)$/) {
         Allegro::al_simulate_keypress($1);
      } elsif(defined $keys{$key}) {
         Allegro::al_simulate_keypress($keys{$key});
      } else {
         carp "simulate() invalid key '$key'" if $^W;
         return undef;
      }
   }

   return $self;
}

sub clear
{
   Allegro::al_clear_keybuf();
   return $_[0];
}

%keys =
(
   a		=> Allegro::AL_KEY_A(),
   b		=> Allegro::AL_KEY_B(),
   c		=> Allegro::AL_KEY_C(),
   d		=> Allegro::AL_KEY_D(),
   e		=> Allegro::AL_KEY_E(),
   f		=> Allegro::AL_KEY_F(),
   g		=> Allegro::AL_KEY_G(),
   h		=> Allegro::AL_KEY_H(),
   i		=> Allegro::AL_KEY_I(),
   j		=> Allegro::AL_KEY_J(),
   k		=> Allegro::AL_KEY_K(),
   l		=> Allegro::AL_KEY_L(),
   m		=> Allegro::AL_KEY_M(),
   n		=> Allegro::AL_KEY_N(),
   o		=> Allegro::AL_KEY_O(),
   p		=> Allegro::AL_KEY_P(),
   q		=> Allegro::AL_KEY_Q(),
   r		=> Allegro::AL_KEY_R(),
   s		=> Allegro::AL_KEY_S(),
   t		=> Allegro::AL_KEY_T(),
   u		=> Allegro::AL_KEY_U(),
   v		=> Allegro::AL_KEY_V(),
   w		=> Allegro::AL_KEY_W(),
   x		=> Allegro::AL_KEY_X(),
   y		=> Allegro::AL_KEY_Y(),
   z		=> Allegro::AL_KEY_Z(),

   0		=> Allegro::AL_KEY_0(),
   1		=> Allegro::AL_KEY_1(),
   2		=> Allegro::AL_KEY_2(),
   3		=> Allegro::AL_KEY_3(),
   4		=> Allegro::AL_KEY_4(),
   5		=> Allegro::AL_KEY_5(),
   6		=> Allegro::AL_KEY_6(),
   7		=> Allegro::AL_KEY_7(),
   8		=> Allegro::AL_KEY_8(),
   9		=> Allegro::AL_KEY_9(),

   '0_pad'	=> Allegro::AL_KEY_0_PAD(),
   '1_pad'	=> Allegro::AL_KEY_1_PAD(),
   '2_pad'	=> Allegro::AL_KEY_2_PAD(),
   '3_pad'	=> Allegro::AL_KEY_3_PAD(),
   '4_pad'	=> Allegro::AL_KEY_4_PAD(),
   '5_pad'	=> Allegro::AL_KEY_5_PAD(),
   '6_pad'	=> Allegro::AL_KEY_6_PAD(),
   '7_pad'	=> Allegro::AL_KEY_7_PAD(),
   '8_pad'	=> Allegro::AL_KEY_8_PAD(),
   '9_pad'	=> Allegro::AL_KEY_9_PAD(),

   f1		=> Allegro::AL_KEY_F1(),
   f2		=> Allegro::AL_KEY_F2(),
   f3		=> Allegro::AL_KEY_F3(),
   f4		=> Allegro::AL_KEY_F4(),
   f5		=> Allegro::AL_KEY_F5(),
   f6		=> Allegro::AL_KEY_F6(),
   f7		=> Allegro::AL_KEY_F7(),
   f8		=> Allegro::AL_KEY_F8(),
   f9		=> Allegro::AL_KEY_F9(),
   f10		=> Allegro::AL_KEY_F10(),
   f11		=> Allegro::AL_KEY_F11(),
   f12		=> Allegro::AL_KEY_F12(),

   escape	=> Allegro::AL_KEY_ESC(),
   tilde	=> Allegro::AL_KEY_TILDE(),
   minus	=> Allegro::AL_KEY_MINUS(),
   equals	=> Allegro::AL_KEY_EQUALS(),
   backspace	=> Allegro::AL_KEY_BACKSPACE(),
   tab		=> Allegro::AL_KEY_TAB(),
   openbrace	=> Allegro::AL_KEY_OPENBRACE(),
   closebrace	=> Allegro::AL_KEY_CLOSEBRACE(),
   enter	=> Allegro::AL_KEY_ENTER(),
   colon	=> Allegro::AL_KEY_COLON(),
   quote	=> Allegro::AL_KEY_QUOTE(),
   backslash	=> Allegro::AL_KEY_BACKSLASH(),
   backslash2	=> Allegro::AL_KEY_BACKSLASH2(),
   comma	=> Allegro::AL_KEY_COMMA(),
   period	=> Allegro::AL_KEY_STOP(),
   slash	=> Allegro::AL_KEY_SLASH(),
   space	=> Allegro::AL_KEY_SPACE(),

   insert	=> Allegro::AL_KEY_INSERT(),
   delete	=> Allegro::AL_KEY_DEL(),
   home		=> Allegro::AL_KEY_HOME(),
   end		=> Allegro::AL_KEY_END(),
   pageup	=> Allegro::AL_KEY_PGUP(),
   pagedown	=> Allegro::AL_KEY_PGDN(),
   left		=> Allegro::AL_KEY_LEFT(),
   right	=> Allegro::AL_KEY_RIGHT(),
   up		=> Allegro::AL_KEY_UP(),
   down		=> Allegro::AL_KEY_DOWN(),

   slash_pad	=> Allegro::AL_KEY_SLASH_PAD(),
   asterisk_pad	=> Allegro::AL_KEY_ASTERISK(),
   minus_pad	=> Allegro::AL_KEY_MINUS_PAD(),
   plus_pad	=> Allegro::AL_KEY_PLUS_PAD(),
   delete_pad	=> Allegro::AL_KEY_DEL_PAD(),
   enter_pad	=> Allegro::AL_KEY_ENTER_PAD(),

   printscreen	=> Allegro::AL_KEY_PRTSCR(),
   pause	=> Allegro::AL_KEY_PAUSE(),

   abnt_c1	=> Allegro::AL_KEY_ABNT_C1(),
   yen		=> Allegro::AL_KEY_YEN(),
   kana		=> Allegro::AL_KEY_KANA(),
   convert	=> Allegro::AL_KEY_CONVERT(),
   noconvert	=> Allegro::AL_KEY_NOCONVERT(),
   at		=> Allegro::AL_KEY_AT(),
   circumflex	=> Allegro::AL_KEY_CIRCUMFLEX(),
   colon2	=> Allegro::AL_KEY_COLON2(),
   kanji	=> Allegro::AL_KEY_KANJI(),

   leftshift	=> Allegro::AL_KEY_LSHIFT(),
   rightshift	=> Allegro::AL_KEY_RSHIFT(),
   leftcontrol	=> Allegro::AL_KEY_LCONTROL(),
   rightcontrol	=> Allegro::AL_KEY_RCONTROL(),
   alt		=> Allegro::AL_KEY_ALT(),
   altgr	=> Allegro::AL_KEY_ALTGR(),
   leftwin	=> Allegro::AL_KEY_LWIN(),
   rightwin	=> Allegro::AL_KEY_RWIN(),
   menu		=> Allegro::AL_KEY_MENU(),

   scrolllock	=> Allegro::AL_KEY_SCRLOCK(),
   numlock	=> Allegro::AL_KEY_NUMLOCK(),
   capslock	=> Allegro::AL_KEY_CAPSLOCK()
);

while(my ($name, $code) = each(%keys)) {
   $names{$code} = $name;
}

# Aliases to entries in %keys
# These can't be in the hash up above since they would screw
# up generation of %names.

$keys{'esc'}		= Allegro::AL_KEY_ESC();
$keys{'~'}		= Allegro::AL_KEY_TILDE();
$keys{'-'}		= Allegro::AL_KEY_MINUS();
$keys{'='}		= Allegro::AL_KEY_EQUALS();
$keys{"\t"}		= Allegro::AL_KEY_TAB();
$keys{'['}		= Allegro::AL_KEY_OPENBRACE();
$keys{']'}		= Allegro::AL_KEY_CLOSEBRACE();
$keys{"\r"}		= Allegro::AL_KEY_ENTER();
$keys{"\n"}		= Allegro::AL_KEY_ENTER();
$keys{':'}		= Allegro::AL_KEY_COLON();
$keys{"'"}		= Allegro::AL_KEY_QUOTE();
$keys{"\\"}		= Allegro::AL_KEY_BACKSLASH();
$keys{','}		= Allegro::AL_KEY_COMMA();
$keys{'.'}		= Allegro::AL_KEY_STOP();
$keys{'/'}		= Allegro::AL_KEY_SLASH();
$keys{' '}		= Allegro::AL_KEY_SPACE();
$keys{'ins'}		= Allegro::AL_KEY_INSERT();
$keys{'del'}		= Allegro::AL_KEY_DEL();
$keys{'stop'}		= Allegro::AL_KEY_STOP();
$keys{'dot'}		= Allegro::AL_KEY_STOP();
$keys{'asterisk'}	= Allegro::AL_KEY_ASTERISK();
$keys{'*'}		= Allegro::AL_KEY_ASTERISK();
$keys{'del_pad'}	= Allegro::AL_KEY_DEL_PAD();
$keys{'lshift'}		= Allegro::AL_KEY_LSHIFT();
$keys{'rshift'}		= Allegro::AL_KEY_RSHIFT();
$keys{'lcontrol'}	= Allegro::AL_KEY_LCONTROL();
$keys{'rcontrol'}	= Allegro::AL_KEY_RCONTROL();
$keys{'lctrl'}		= Allegro::AL_KEY_LCONTROL();
$keys{'rctrl'}		= Allegro::AL_KEY_RCONTROL();
$keys{'lwin'}		= Allegro::AL_KEY_LWIN();
$keys{'rwin'}		= Allegro::AL_KEY_RWIN();
$keys{'scroll'}		= Allegro::AL_KEY_SCRLOCK();
$keys{'num'}		= Allegro::AL_KEY_NUMLOCK();
$keys{'caps'}		= Allegro::AL_KEY_CAPSLOCK();

1;
