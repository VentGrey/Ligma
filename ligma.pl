#!/usr/bin/perl
use v5.36;
use AnyEvent;
use Fcntl ':flock';
use FindBin;
use POSIX;
use lib "$FindBin::Bin/Modules/";

use BatteryModule;
use KeyboardModule;
use MusicModule;
use VolumeModule;
use WifiModule;

open(my $lock_fh, '>', "/tmp/ligma.lock") or die "Could not create lock file: $!";
flock($lock_fh, LOCK_EX | LOCK_NB) or die "Another instance of this script is already running.";

# Kill any pactl left behind if killed.
`pkill pactl`;
`pkill cmus-remote`;

# Change process name to make tracking easy.
$0="Ligma";

my $cv = AnyEvent->condvar;

sub print_spectrwm_bar($message) {
  print("$message\n");
}

my %modules = (
    start  => [],
);

sub update_module($position, $index, $content) {
    $modules{$position}->[$index] = $content;
}


sub print_bar {
  my @start = map { defined($_) ? " $_ " : " <default_value> " } @{$modules{start}};
  print_spectrwm_bar(
    "@start"
   );
}

# Subroutine for bar refresh.
sub update_bar {
    print_bar();
}

########Modules#################################################################

#===== Bar printer =====
# This module re-prints the bar every few seconds (timer) to ensure a constant
# output to prevent bugs if lemonbar were to experience a bad formatter.
my $barprinter = AnyEvent->timer(
    after => 0,
    interval => 2,
    cb => \&update_bar
);

#===== CMUS Bar =====
my $music_values = MusicModule::listen_cmus(sub {
    my $music = shift;
    update_module('start', 0, "$music");
    update_bar();
});

#===== Keyboard Distribution =====
my $keyboard_handle = KeyboardModule::listen_keyboard(sub {
    my $layout = shift;
    update_module('start', 1, "$layout");
    update_bar();
});

#===== Wifi Connection =====
my $wifi_handle = WifiModule::listen_wifi(sub {
    my $wifi = shift;
    update_module('start', 2, "$wifi");
    update_bar();
});

# ===== Battery =====
# (Args: BATTERY_ID to monitor. e.g: "BAT0" or "BAT1")
# =====
my $battery_handle = BatteryModule::listen_battery("BAT0", sub {
    my $info = shift;
    update_module('start', 3, "$info");
    print_bar();
});


# ===== Volume =====
my $volume_handle = VolumeModule::listen_volume(sub {
    my $volume = shift;
    update_module('start', 4, "$volume");
    print_bar();
});

AnyEvent->condvar->recv;

1;
