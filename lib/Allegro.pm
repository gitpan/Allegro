# $Id$
#
#   This file is part of the Allegro-Perl package.
#   Copyright 2003 Colin O'Leary.
#

package Allegro;

use 5.006;
use strict;
use warnings;

use base qw(DynaLoader Exporter);

use Carp;

our $VERSION = '0.01';

bootstrap Allegro $VERSION;

my $AL = undef;
my $sleep = sub { select undef, undef, undef, $_[0] };

sub new
{
   my $proto = shift;
   my $class = ref($proto) || $proto;
   my %opt   = @_;

   return $AL if($AL);

   my $al = {};
   bless $al, $class;

   my $driver = AL_SYSTEM_AUTODETECT();

   if(defined($opt{driver})) {
      $driver = AL_SYSTEM_NONE() if($opt{driver} eq 'none');
   }

   if(al_install_allegro($driver) != 0) {
      return undef;
   }

   if(al_install_timer() == 0) {
      $al->{timer} = 1;
      $sleep = \&rest;
   } else {
      $al->{timer} = 0;
   }

   $AL = $al;
   return $al;
}

sub shutdown
{
   al_allegro_exit();
   return $_[0];
}

sub error
{
   return al_get_error();
}

sub message
{
   my $self = shift;
   my $msg  = join("", @_);

   al_set_gfx_mode(AL_GFX_TEXT(), 0, 0, 0, 0);
   al_allegro_message($msg);
   return $self;
}

sub sleep
{
   &$sleep(@_);
}

sub rest
{
   if(ref $_[0]) {
      al_rest($_[1] * 1000);
   } else {
      al_rest($_[0] * 1000);
   }
}

sub DESTROY { }

sub AUTOLOAD
{
   my $obj  = $Allegro::AUTOLOAD;

   if(!$_[0]) {
      croak "Nonexistant subroutine call $Allegro::AUTOLOAD";
   }

   if($obj =~ /([A-Z][A-Za-z]+)$/)
   {
      eval "require $obj";

      die if($@);

      unshift @_, "Allegro::$1";

      $obj = "Allegro::$1::new";
      goto &$obj;
   }

   if($obj !~ /DESTROY$/) {
      croak "Nonexistant method call $Allegro::AUTOLOAD";
   }

   return undef;
}

sub AL_NULL_BITMAP   { bless do { \(my $o = 0) }, "BITMAPPtr" }
sub AL_NULL_DATAFILE { bless do { \(my $o = 0) }, "DATAFILEPtr" }
sub AL_NULL_FONT     { bless do { \(my $o = 0) }, "FONTPtr" }
sub AL_NULL_MIDI     { bless do { \(my $o = 0) }, "MIDIPtr" }
sub AL_NULL_PALETTE  { bless do { \(my $o = 0) }, "RGBPtr" }
sub AL_NULL_SAMPLE   { bless do { \(my $o = 0) }, "SAMPLEPtr" }

#
# These lists are generated automatically by misc/gen-allegr-pm from
# Allegro.xs and auto.xsh.  Do not remove the BEGIN_ and END_ tags.
#

my @functions = (
#BEGIN_FUNC
   'al_acquire_bitmap',
   'al_adjust_sample',
   'al_allegro_exit',
   'al_allegro_init',
   'al_allegro_message',
   'al_allocate_voice',
   'al_arc',
   'al_bitmap_color_depth',
   'al_bitmap_mask_color',
   'al_blit',
   'al_calibrate_joystick',
   'al_calibrate_joystick_name',
   'al_clear_bitmap',
   'al_clear_keybuf',
   'al_clear_to_color',
   'al_create_bitmap',
   'al_create_bitmap_ex',
   'al_create_color_map',
   'al_create_palette',
   'al_create_sample',
   'al_create_sub_bitmap',
   'al_create_system_bitmap',
   'al_create_timer',
   'al_create_video_bitmap',
   'al_deallocate_voice',
   'al_decrement_timer',
   'al_desktop_color_depth',
   'al_destroy_bitmap',
   'al_destroy_color_map',
   'al_destroy_font',
   'al_destroy_midi',
   'al_destroy_palette',
   'al_destroy_rle_sprite',
   'al_destroy_sample',
   'al_draw_gouraud_sprite',
   'al_draw_lit_rle_sprite',
   'al_draw_lit_sprite',
   'al_draw_rle_sprite',
   'al_draw_sprite',
   'al_draw_sprite_h_flip',
   'al_draw_sprite_v_flip',
   'al_draw_sprite_vh_flip',
   'al_draw_trans_rle_sprite',
   'al_draw_trans_sprite',
   'al_drawing_mode',
   'al_ellipse',
   'al_ellipsefill',
   'al_fixup_datafile',
   'al_floodfill',
   'al_get_bitmap_clip',
   'al_get_bitmap_size',
   'al_get_color_map',
   'al_get_datafile_data',
   'al_get_datafile_property',
   'al_get_datafile_size',
   'al_get_datafile_type',
   'al_get_display_switch_mode',
   'al_get_error',
   'al_get_gfx_capabilities',
   'al_get_joystick_axis_info',
   'al_get_joystick_button_info',
   'al_get_joystick_info',
   'al_get_joystick_stick_info',
   'al_get_key',
   'al_get_key_shifts',
   'al_get_midi_info',
   'al_get_mouse_info',
   'al_get_num_joysticks',
   'al_get_palette',
   'al_get_palette_color',
   'al_get_refresh_rate',
   'al_get_rle_depth',
   'al_get_rle_size',
   'al_get_rle_sprite',
   'al_get_screen',
   'al_get_screen_size',
   'al_get_sound_input_cap_bits',
   'al_get_sound_input_cap_parm',
   'al_get_sound_input_cap_rate',
   'al_get_sound_input_cap_stereo',
   'al_get_system_font',
   'al_get_timer_updates',
   'al_get_version',
   'al_geta',
   'al_geta_depth',
   'al_getb',
   'al_getb_depth',
   'al_getg',
   'al_getg_depth',
   'al_getpixel',
   'al_getr',
   'al_getr_depth',
   'al_hline',
   'al_id',
   'al_install_allegro',
   'al_install_joystick',
   'al_install_keyboard',
   'al_install_mouse',
   'al_install_sound',
   'al_install_sound_input',
   'al_install_timer',
   'al_is_memory_bitmap',
   'al_is_same_bitmap',
   'al_is_screen_bitmap',
   'al_is_sub_bitmap',
   'al_is_system_bitmap',
   'al_is_video_bitmap',
   'al_keypressed',
   'al_line',
   'al_load_bitmap',
   'al_load_datafile',
   'al_load_datafile_object',
   'al_load_midi',
   'al_load_sample',
   'al_makeacol',
   'al_makeacol_depth',
   'al_makecol',
   'al_makecol_depth',
   'al_masked_blit',
   'al_masked_stretch_blit',
   'al_midi_pause',
   'al_midi_resume',
   'al_midi_seek',
   'al_mouse_needs_poll',
   'al_packfile_password',
   'al_pivot_scaled_sprite',
   'al_pivot_scaled_sprite_v_flip',
   'al_pivot_sprite',
   'al_pivot_sprite_v_flip',
   'al_play_looped_midi',
   'al_play_midi',
   'al_play_sample',
   'al_poll_joystick',
   'al_poll_keyboard',
   'al_poll_mouse',
   'al_polygon',
   'al_position_mouse',
   'al_position_mouse_z',
   'al_putpixel',
   'al_read_sound_input',
   'al_readkey',
   'al_reallocate_voice',
   'al_rect',
   'al_rectfill',
   'al_release_bitmap',
   'al_release_voice',
   'al_remove_keyboard',
   'al_remove_mouse',
   'al_remove_sound',
   'al_remove_sound_input',
   'al_remove_timer',
   'al_request_refresh_rate',
   'al_reserve_voices',
   'al_rest',
   'al_rotate_scaled_sprite',
   'al_rotate_scaled_sprite_v_flip',
   'al_rotate_sprite',
   'al_rotate_sprite_v_flip',
   'al_save_bitmap',
   'al_scare_mouse',
   'al_scare_mouse_area',
   'al_scroll_screen',
   'al_select_palette',
   'al_set_alpha_blender',
   'al_set_clip',
   'al_set_color_conversion',
   'al_set_color_depth',
   'al_set_color_map',
   'al_set_display_switch_mode',
   'al_set_freeze_mouse',
   'al_set_gfx_mode',
   'al_set_keyboard_rate',
   'al_set_leds',
   'al_set_mouse_range',
   'al_set_mouse_speed',
   'al_set_mouse_sprite',
   'al_set_mouse_sprite_focus',
   'al_set_palette',
   'al_set_palette_color',
   'al_set_sound_input_source',
   'al_set_trans_blender',
   'al_set_volume',
   'al_set_volume_per_voice',
   'al_set_window_title',
   'al_show_mouse',
   'al_show_video_bitmap',
   'al_simulate_keypress',
   'al_start_sound_input',
   'al_start_timer',
   'al_stop_midi',
   'al_stop_sample',
   'al_stop_sound_input',
   'al_stop_timer',
   'al_stretch_blit',
   'al_text_height',
   'al_text_length',
   'al_text_mode',
   'al_textout',
   'al_textout_centre',
   'al_textout_justify',
   'al_textout_right',
   'al_triangle',
   'al_unload_datafile',
   'al_unload_datafile_object',
   'al_unscare_mouse',
   'al_unselect_palette',
   'al_vline',
   'al_voice_check',
   'al_voice_get_frequency',
   'al_voice_get_pan',
   'al_voice_get_position',
   'al_voice_get_volume',
   'al_voice_set_frequency',
   'al_voice_set_playmode',
   'al_voice_set_position',
   'al_voice_set_priority',
   'al_voice_set_volume',
   'al_voice_start',
   'al_voice_stop',
   'al_vsync',
#END_FUNC
);

my @defines = (
   'AL_NULL_BITMAP',
   'AL_NULL_DATAFILE',
   'AL_NULL_FONT',
   'AL_NULL_MIDI',
   'AL_NULL_PALETTE',
   'AL_NULL_SAMPLE',
#BEGIN_DEFINE
   'AL_BPS_TO_TIMER',
   'AL_COLORCONV_15_TO_16',
   'AL_COLORCONV_15_TO_24',
   'AL_COLORCONV_15_TO_32',
   'AL_COLORCONV_15_TO_8',
   'AL_COLORCONV_16_TO_15',
   'AL_COLORCONV_16_TO_24',
   'AL_COLORCONV_16_TO_32',
   'AL_COLORCONV_16_TO_8',
   'AL_COLORCONV_24_TO_15',
   'AL_COLORCONV_24_TO_16',
   'AL_COLORCONV_24_TO_32',
   'AL_COLORCONV_24_TO_8',
   'AL_COLORCONV_32A_TO_15',
   'AL_COLORCONV_32A_TO_16',
   'AL_COLORCONV_32A_TO_24',
   'AL_COLORCONV_32A_TO_8',
   'AL_COLORCONV_32_TO_15',
   'AL_COLORCONV_32_TO_16',
   'AL_COLORCONV_32_TO_24',
   'AL_COLORCONV_32_TO_8',
   'AL_COLORCONV_8_TO_15',
   'AL_COLORCONV_8_TO_16',
   'AL_COLORCONV_8_TO_24',
   'AL_COLORCONV_8_TO_32',
   'AL_COLORCONV_DITHER_HI',
   'AL_COLORCONV_DITHER_PAL',
   'AL_COLORCONV_EXPAND_15_TO_16',
   'AL_COLORCONV_KEEP_TRANS',
   'AL_COLORCONV_NONE',
   'AL_COLORCONV_REDUCE_16_TO_15',
   'AL_DAT_BITMAP',
   'AL_DAT_C_SPRITE',
   'AL_DAT_DATA',
   'AL_DAT_END',
   'AL_DAT_FILE',
   'AL_DAT_FLI',
   'AL_DAT_FONT',
   'AL_DAT_MAGIC',
   'AL_DAT_MIDI',
   'AL_DAT_NAME',
   'AL_DAT_PALETTE',
   'AL_DAT_PALLETE',
   'AL_DAT_PATCH',
   'AL_DAT_PROPERTY',
   'AL_DAT_RLE_SPRITE',
   'AL_DAT_SAMPLE',
   'AL_DAT_XC_SPRITE',
   'AL_DIGI_ALSA',
   'AL_DIGI_ARTS',
   'AL_DIGI_AUDIODRIVE',
   'AL_DIGI_AUTODETECT',
   'AL_DIGI_BEOS',
   'AL_DIGI_ESD',
   'AL_DIGI_MACOS',
   'AL_DIGI_NONE',
   'AL_DIGI_OSS',
   'AL_DIGI_SB10',
   'AL_DIGI_SB15',
   'AL_DIGI_SB16',
   'AL_DIGI_SB20',
   'AL_DIGI_SBPRO',
   'AL_DIGI_SOUNDSCAPE',
   'AL_DIGI_VOICES',
   'AL_DIGI_WINSOUNDSYS',
   'AL_DRAW_MODE_COPY_PATTERN',
   'AL_DRAW_MODE_MASKED_PATTERN',
   'AL_DRAW_MODE_SOLID',
   'AL_DRAW_MODE_SOLID_PATTERN',
   'AL_DRAW_MODE_TRANS',
   'AL_DRAW_MODE_XOR',
   'AL_GFX_AUTODETECT',
   'AL_GFX_AUTODETECT_FULLSCREEN',
   'AL_GFX_AUTODETECT_WINDOWED',
   'AL_GFX_BEOS',
   'AL_GFX_BEOS_FULLSCREEN',
   'AL_GFX_BEOS_FULLSCREEN_SAFE',
   'AL_GFX_BEOS_WINDOWED',
   'AL_GFX_BEOS_WINDOWED_SAFE',
   'AL_GFX_CAN_SCROLL',
   'AL_GFX_CAN_TRIPLE_BUFFER',
   'AL_GFX_DIRECTX',
   'AL_GFX_DIRECTX_ACCEL',
   'AL_GFX_DIRECTX_OVL',
   'AL_GFX_DIRECTX_SAFE',
   'AL_GFX_DIRECTX_SOFT',
   'AL_GFX_DIRECTX_WIN',
   'AL_GFX_DRAWSPROCKET',
   'AL_GFX_GDI',
   'AL_GFX_HW_CURSOR',
   'AL_GFX_HW_FILL',
   'AL_GFX_HW_FILL_COPY_PATTERN',
   'AL_GFX_HW_FILL_SOLID_PATTERN',
   'AL_GFX_HW_FILL_XOR',
   'AL_GFX_HW_GLYPH',
   'AL_GFX_HW_HLINE',
   'AL_GFX_HW_HLINE_COPY_PATTERN',
   'AL_GFX_HW_HLINE_SOLID_PATTERN',
   'AL_GFX_HW_HLINE_XOR',
   'AL_GFX_HW_LINE',
   'AL_GFX_HW_LINE_XOR',
   'AL_GFX_HW_MEM_BLIT',
   'AL_GFX_HW_MEM_BLIT_MASKED',
   'AL_GFX_HW_SYS_TO_VRAM_BLIT',
   'AL_GFX_HW_SYS_TO_VRAM_BLIT_MASKED',
   'AL_GFX_HW_TRIANGLE',
   'AL_GFX_HW_TRIANGLE_XOR',
   'AL_GFX_HW_VRAM_BLIT',
   'AL_GFX_HW_VRAM_BLIT_MASKED',
   'AL_GFX_MODEX',
   'AL_GFX_PHOTON',
   'AL_GFX_PHOTON_DIRECT',
   'AL_GFX_SAFE',
   'AL_GFX_TEXT',
   'AL_GFX_VBEAF',
   'AL_GFX_VESA1',
   'AL_GFX_VESA2B',
   'AL_GFX_VESA2L',
   'AL_GFX_VESA3',
   'AL_GFX_VGA',
   'AL_GFX_XDGA',
   'AL_GFX_XDGA2',
   'AL_GFX_XDGA2_SOFT',
   'AL_GFX_XDGA_FULLSCREEN',
   'AL_GFX_XTENDED',
   'AL_GFX_XWINDOWS',
   'AL_GFX_XWINDOWS_FULLSCREEN',
   'AL_JOYFLAG_ANALOGUE',
   'AL_JOYFLAG_CALIBRATE',
   'AL_JOYFLAG_CALIB_ANALOGUE',
   'AL_JOYFLAG_CALIB_DIGITAL',
   'AL_JOYFLAG_DIGITAL',
   'AL_JOYFLAG_SIGNED',
   'AL_JOYFLAG_UNSIGNED',
   'AL_JOY_HAT_CENTER',
   'AL_JOY_HAT_CENTRE',
   'AL_JOY_HAT_DOWN',
   'AL_JOY_HAT_LEFT',
   'AL_JOY_HAT_RIGHT',
   'AL_JOY_HAT_UP',
   'AL_JOY_TYPE_2PADS',
   'AL_JOY_TYPE_4BUTTON',
   'AL_JOY_TYPE_6BUTTON',
   'AL_JOY_TYPE_8BUTTON',
   'AL_JOY_TYPE_AUTODETECT',
   'AL_JOY_TYPE_DB9_LPT1',
   'AL_JOY_TYPE_DB9_LPT2',
   'AL_JOY_TYPE_DB9_LPT3',
   'AL_JOY_TYPE_FSPRO',
   'AL_JOY_TYPE_GAMEPAD_PRO',
   'AL_JOY_TYPE_GRIP',
   'AL_JOY_TYPE_GRIP4',
   'AL_JOY_TYPE_IFSEGA_ISA',
   'AL_JOY_TYPE_IFSEGA_PCI',
   'AL_JOY_TYPE_IFSEGA_PCI_FAST',
   'AL_JOY_TYPE_LINUX_ANALOGUE',
   'AL_JOY_TYPE_N64PAD_LPT1',
   'AL_JOY_TYPE_N64PAD_LPT2',
   'AL_JOY_TYPE_N64PAD_LPT3',
   'AL_JOY_TYPE_NONE',
   'AL_JOY_TYPE_PSXPAD_LPT1',
   'AL_JOY_TYPE_PSXPAD_LPT2',
   'AL_JOY_TYPE_PSXPAD_LPT3',
   'AL_JOY_TYPE_SIDEWINDER',
   'AL_JOY_TYPE_SIDEWINDER_AG',
   'AL_JOY_TYPE_SNESPAD_LPT1',
   'AL_JOY_TYPE_SNESPAD_LPT2',
   'AL_JOY_TYPE_SNESPAD_LPT3',
   'AL_JOY_TYPE_STANDARD',
   'AL_JOY_TYPE_TURBOGRAFX_LPT1',
   'AL_JOY_TYPE_TURBOGRAFX_LPT2',
   'AL_JOY_TYPE_TURBOGRAFX_LPT3',
   'AL_JOY_TYPE_WIN32',
   'AL_JOY_TYPE_WINGEX',
   'AL_JOY_TYPE_WINGWARRIOR',
   'AL_KB_ACCENT1_FLAG',
   'AL_KB_ACCENT2_FLAG',
   'AL_KB_ACCENT3_FLAG',
   'AL_KB_ACCENT4_FLAG',
   'AL_KB_ALT_FLAG',
   'AL_KB_CAPSLOCK_FLAG',
   'AL_KB_CTRL_FLAG',
   'AL_KB_EXTENDED',
   'AL_KB_INALTSEQ_FLAG',
   'AL_KB_LWIN_FLAG',
   'AL_KB_MENU_FLAG',
   'AL_KB_NORMAL',
   'AL_KB_NUMLOCK_FLAG',
   'AL_KB_RWIN_FLAG',
   'AL_KB_SCROLOCK_FLAG',
   'AL_KB_SHIFT_FLAG',
   'AL_KEY_0',
   'AL_KEY_0_PAD',
   'AL_KEY_1',
   'AL_KEY_1_PAD',
   'AL_KEY_2',
   'AL_KEY_2_PAD',
   'AL_KEY_3',
   'AL_KEY_3_PAD',
   'AL_KEY_4',
   'AL_KEY_4_PAD',
   'AL_KEY_5',
   'AL_KEY_5_PAD',
   'AL_KEY_6',
   'AL_KEY_6_PAD',
   'AL_KEY_7',
   'AL_KEY_7_PAD',
   'AL_KEY_8',
   'AL_KEY_8_PAD',
   'AL_KEY_9',
   'AL_KEY_9_PAD',
   'AL_KEY_A',
   'AL_KEY_ABNT_C1',
   'AL_KEY_ALT',
   'AL_KEY_ALTGR',
   'AL_KEY_ASTERISK',
   'AL_KEY_AT',
   'AL_KEY_B',
   'AL_KEY_BACKSLASH',
   'AL_KEY_BACKSLASH2',
   'AL_KEY_BACKSPACE',
   'AL_KEY_C',
   'AL_KEY_CAPSLOCK',
   'AL_KEY_CIRCUMFLEX',
   'AL_KEY_CLOSEBRACE',
   'AL_KEY_COLON',
   'AL_KEY_COLON2',
   'AL_KEY_COMMA',
   'AL_KEY_CONVERT',
   'AL_KEY_D',
   'AL_KEY_DEL',
   'AL_KEY_DEL_PAD',
   'AL_KEY_DOWN',
   'AL_KEY_E',
   'AL_KEY_END',
   'AL_KEY_ENTER',
   'AL_KEY_ENTER_PAD',
   'AL_KEY_EQUALS',
   'AL_KEY_ESC',
   'AL_KEY_F',
   'AL_KEY_F1',
   'AL_KEY_F10',
   'AL_KEY_F11',
   'AL_KEY_F12',
   'AL_KEY_F2',
   'AL_KEY_F3',
   'AL_KEY_F4',
   'AL_KEY_F5',
   'AL_KEY_F6',
   'AL_KEY_F7',
   'AL_KEY_F8',
   'AL_KEY_F9',
   'AL_KEY_G',
   'AL_KEY_H',
   'AL_KEY_HOME',
   'AL_KEY_I',
   'AL_KEY_INSERT',
   'AL_KEY_J',
   'AL_KEY_K',
   'AL_KEY_KANA',
   'AL_KEY_KANJI',
   'AL_KEY_L',
   'AL_KEY_LCONTROL',
   'AL_KEY_LEFT',
   'AL_KEY_LSHIFT',
   'AL_KEY_LWIN',
   'AL_KEY_M',
   'AL_KEY_MAX',
   'AL_KEY_MENU',
   'AL_KEY_MINUS',
   'AL_KEY_MINUS_PAD',
   'AL_KEY_MODIFIERS',
   'AL_KEY_N',
   'AL_KEY_NOCONVERT',
   'AL_KEY_NUMLOCK',
   'AL_KEY_O',
   'AL_KEY_OPENBRACE',
   'AL_KEY_P',
   'AL_KEY_PAUSE',
   'AL_KEY_PGDN',
   'AL_KEY_PGUP',
   'AL_KEY_PLUS_PAD',
   'AL_KEY_PRTSCR',
   'AL_KEY_Q',
   'AL_KEY_QUOTE',
   'AL_KEY_R',
   'AL_KEY_RCONTROL',
   'AL_KEY_RIGHT',
   'AL_KEY_RSHIFT',
   'AL_KEY_RWIN',
   'AL_KEY_S',
   'AL_KEY_SCRLOCK',
   'AL_KEY_SLASH',
   'AL_KEY_SLASH_PAD',
   'AL_KEY_SPACE',
   'AL_KEY_STOP',
   'AL_KEY_T',
   'AL_KEY_TAB',
   'AL_KEY_TILDE',
   'AL_KEY_U',
   'AL_KEY_UP',
   'AL_KEY_V',
   'AL_KEY_W',
   'AL_KEY_X',
   'AL_KEY_Y',
   'AL_KEY_YEN',
   'AL_KEY_Z',
   'AL_MASK_COLOR_15',
   'AL_MASK_COLOR_16',
   'AL_MASK_COLOR_24',
   'AL_MASK_COLOR_32',
   'AL_MASK_COLOR_8',
   'AL_MIDI_2XOPL2',
   'AL_MIDI_ALSA',
   'AL_MIDI_AUTODETECT',
   'AL_MIDI_AWE32',
   'AL_MIDI_BEOS',
   'AL_MIDI_DIGMID',
   'AL_MIDI_MPU',
   'AL_MIDI_NONE',
   'AL_MIDI_OPL2',
   'AL_MIDI_OPL3',
   'AL_MIDI_OSS',
   'AL_MIDI_QUICKTIME',
   'AL_MIDI_SB_OUT',
   'AL_MIDI_TRACKS',
   'AL_MIDI_VOICES',
   'AL_MIDI_WIN32MAPPER',
   'AL_MSEC_TO_TIMER',
   'AL_PLAYMODE_BACKWARD',
   'AL_PLAYMODE_BIDIR',
   'AL_PLAYMODE_FORWARD',
   'AL_PLAYMODE_LOOP',
   'AL_PLAYMODE_PLAY',
   'AL_SECS_TO_TIMER',
   'AL_SWITCH_AMNESIA',
   'AL_SWITCH_BACKAMNESIA',
   'AL_SWITCH_BACKGROUND',
   'AL_SWITCH_IN',
   'AL_SWITCH_NONE',
   'AL_SWITCH_OUT',
   'AL_SWITCH_PAUSE',
   'AL_SYSTEM_AUTODETECT',
   'AL_SYSTEM_BEOS',
   'AL_SYSTEM_DIRECTX',
   'AL_SYSTEM_DOS',
   'AL_SYSTEM_LINUX',
   'AL_SYSTEM_MACOS',
   'AL_SYSTEM_NONE',
   'AL_SYSTEM_QNX',
   'AL_SYSTEM_XWINDOWS',
#END_DEFINE
);

our @EXPORT      = ();
our @EXPORT_OK   = (@functions, @defines, 'sleep');
our %EXPORT_TAGS = (functions => [@functions],
                    defines   => [@defines],
                    all       => [@functions, @defines]);

1;
