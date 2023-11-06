package MusicModule;

use v5.36;
use AnyEvent;
use AnyEvent::Handle;
use IPC::Open3;

=head1 NAME

MusicModule - Consult and format a resulting string from the command-line utility cmus listener.

TODO: Make this use the cmus socket or a constant stream.

=head1 DESCRIPTION

This module dynamically tries to get the current cmus playing song.

=head1 METHODS

=head2 listen_cmus

Gets and formats the current cmus playing song, finally, it registers
a callback to process changes.

=cut


sub listen_cmus {
    my $callback = shift;
    my $last_song = '';
    my $get_song = sub {
        my $info = `cmus-remote -Q`;
        if ($info =~ /status stopped/) {
            return "...";
        } elsif ($info =~ /tag title (.+)/) {
            return $1;
        }
        return "...";
    };

    # Immediate song update on start
    my $current_song = $get_song->();
    $callback->("+\@fg=3; $current_song+\@fg=0;");
    $last_song = $current_song;

    # Update at regular intervals.
    my $timer = AnyEvent->timer(
        after => 0,
        interval => 1, # check every second
        cb => sub {
            my $current_song = $get_song->();
            if ($current_song ne $last_song) {
                $callback->("+\@fg=3; $current_song+\@fg=0;");
                $last_song = $current_song;
            }
        }
    );

    # Return the timer to keep it alive
    return $timer;
}

1;
