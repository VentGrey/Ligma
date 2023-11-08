# Ligma

> Paquita Cabeza.

This is my spectrwm configuration repository. No fancy prog-rock refs this time.

This theme tries to stay as close to [Epitaph](https://github.com/VentGrey/Epitaph) in both keybindings and ease of use (i think...). 

Provided font files belong to the `JetBrainsMono` family by [nerd fonts](https://nerdfonts.com/). Files are provided as-is, without any modifications. 
Provided wallpapers are the same as included in [Epitaph](https://github.com/VentGrey/Epitaph), see Epitaph's README.md file for copyright / author recognition.

## Screenshots

![Screenshot_2023-11-08](https://github.com/VentGrey/Ligma/assets/24773698/595d66fc-9fe2-4a12-a325-afd7639ee522)


## Requirements

This rice is a lesser version of Epitaph, reduced to be as simple as spectrwm allows me to be.

To run this you'll need:

- spectrwm 3.5.0
- Perl `v=5.36` or higher.
- `libanyevent-perl` or equivalent in your distribution. Or use CPAN.
- A pulseaudio interface (via pulseaudio or `pipewire-pulse`).
- `pactl` and `pamixer`.
- `cmus`, because it's a peak music player.
- `rofi` using the provided `config.rasi` file. Make sure to copy it or adapt yours.
- `tilix` as the provided `spectrwm.conf` suggests or your own terminal emulator.
- `emacsclient` as it is autostarted. It's highly recommended to learn emacs, it will increase your *obo* greatly.
- `nitrogen` to set your wallpapers.
- `picom` for not-ugly, absolutely not pretty decorations that try to keep picom's GPU hunger from striking.
- `gcc` or any other C compiler for the provided `batteryd.c` written by [Suavesito](https://github.com/Suavesito-Olimpiada/dotfiles/blob/master/herbstluftwm/bin/battery.c). Minor modifications made.
- `setxkbmap` for the keyboard rofi script.
- `dunst` for notifications, si señor.
- 

## The `ligma.pl` bar script.

Using elements from *ponjo*, *crototoco*, *padalustro*, *timulo* and *crotolamo*, this script is a reduced version of `genesis` in Epitaph, it essentially outputs less modules, ideal for window managers that provide a bar with their own modules + script output.

All format characters can be found in this source code with the following notation: `+@fg=n;` where `n` is any number from 0 to 9.

You can use perl to replace these formatters with blank formatters for other bars like:

- lemonbar

- dzen2

- xmobar

```perl
#!/usr/bin/perl

use v5.36;

my $source_code = do { local $/; <STDIN> };
$source_code =~ s/\+\@fg=[0-9];/%{F-}/g;        # Lemonbar or use Genesis.pl
$source_code =~ s/\+\@fg=[0-9];/<fc=#000000>/g; # Dzen2
$source_code =~ s/\+\@fg=[0-9];/<fc=#000000>/g; # Xmobar

# TODO: Expand with fg and similar formatting opts

print $source_code;
```

Run the Perl script with the source code as input and redirect the output to a new file. For example:

```shell
./replace_format_characters.pl < source_code.txt > modified_source_code.txt
```

### Known bugs
- Bar is not completely stable, it might die at random or make the wm stuck. If this happens logout using the power menu rofi script.

- Spamming volume changes might freeze bar. This means holding down the key.

Any help in solving these or improvements to `ligma.pl` are welcome.
