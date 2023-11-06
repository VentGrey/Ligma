package VolumeModule;

use v5.36;
use AnyEvent;
use AnyEvent::Handle;

use IPC::Open3;

=head1 NAME

VolumeModule - Consult and format a volume string. Report every second.

=head1 DESCRIPTION

This module relies on pactl subscribe to monitor volume changes reading from
the command's stdout.

TODO: Figure out a way to reuse or daemonize pactl output (maybe a fifo?)

=head1 METHODS

=head2 listen_volume

Gets and formats the current date, finally, it registers
a callback to process changes.

=cut


sub listen_volume {
    my $callback = shift;

    my @cmd = ('pactl', 'subscribe');

    my ($wtr, $rdr, $err)  = (undef, undef, undef);
    my $pid = open3($wtr, $rdr, $err, @cmd);

    my $last_output;
    my $update_volume = sub {
    my ($mute, $volume) = split /\s+/, `pamixer --get-volume --get-mute`;

        if ($mute eq 'true') {
            return "+\@fg=8;󰖁 Muted+\@fg=0;";
        } elsif ($volume == 0) {
            return "+\@fg=8;󰕿 0+\@fg=0;";
        } elsif ($volume < 50) {
            return "+\@fg=6;󰖀 $volume+\@fg=0;";
        } else {
            return "+\@fg=5;󰕾 $volume+\@fg=0;";
        }
    };

    # Immediate volume update on start
    $callback->($update_volume->());

    my $handle;
    $handle = AnyEvent::Handle->new(
        fh => $rdr,
        on_read => sub {
            $handle->push_read(line => sub {
                my $current_output = $_[1];
                if (($current_output =~ /sink/ || $current_output =~ /change/ || $current_output =~ /cambiar/)
                    && (!defined $last_output || $current_output ne $last_output)) {
                    $callback->($update_volume->());
                    $last_output = $current_output;
                }
            });
        },
        on_error => sub {
            warn "Error with pactl: $!";
            $handle->destroy;
            close $wtr;  # Cerrar el proceso pactl
            close $rdr;
        }
    );

    # Return the handle to keep it alive
    return $handle;
}
1;
