package BatteryModule;

use v5.36;
use AnyEvent;
use File::ChangeNotify;

=head1 NAME

BatteryModule - Consult and format a battery string from the Linux filesystem.

TODO: Make this use a filewatcher that works with anyevent

=head1 DESCRIPTION

This module uses internal Perl functions / libraries to print a formatted
battery string to the lemonbar it notifies battery changes.

=head1 METHODS

=head2 listen_state

Gets and formats the current battery status, finally, it registers
a callback to process changes.

=cut

sub listen_battery {
    my $battery = shift // "BAT0";
    my $callback = shift;

    my $status_path = "/sys/class/power_supply/$battery/status";
    my $capacity_path = "/sys/class/power_supply/$battery/capacity";

    my $watcher = File::ChangeNotify->instantiate_watcher(
        directories => [ "/sys/class/power_supply/$battery/" ],
        filter      => qr/^(?:$status_path|$capacity_path)$/,
       );

    my $previous_output = '';

    my $check_and_notify = sub($status, $capacity) {
        my $icon = "";
        if ($status eq 'Charging') {
            if ($capacity == 100) {
                $icon = '󰄌';
            } else {
                $icon = '';
           }
        } elsif ($status eq 'Discharging' || $status eq 'Not charging') {
            if ($capacity <= 5) {
                $icon = '+@fg=3;󰂃+@fg=0;';
            } elsif ($capacity <= 10) {
                $icon = '+@fg=3;󰁺+@fg=0;';
            } elsif ($capacity <= 20) {
                $icon = '+@fg=7;󰁻+@fg=0;';
            } elsif ($capacity <= 30) {
                $icon = '+@fg=6;󰁼+@fg=0;';
            } elsif ($capacity <= 40) {
                $icon = '+@fg=6;󰁽+@fg=0;';
            } elsif ($capacity <= 50) {
                $icon = '+@fg=6;󰁾+@fg=0;';
            } elsif ($capacity <= 60) {
                $icon = '+@fg=6;󰁿+@fg=0;';
            } elsif ($capacity <= 70) {
                $icon = '+@fg=5;󰂀+@fg=0;';
            } elsif ($capacity <= 80) {
                $icon = '+@fg=5;󰂁+@fg=0;';
            } elsif ($capacity <= 90) {
                $icon = '+@fg=5;󰂂+@fg=0;';
            } else {
                $icon = '+@fg=5;󱈏+@fg=0;';
            }
        } elsif ($status eq 'Full') {
            $icon = '+@fg=5;󱈏+@fg=0;';
        }

        my $output = "$icon $capacity";
        if ($output ne $previous_output) {
            $callback->($output);
            $previous_output = $output;
          }
      };

    # Non-blocking check for new events
    my $timer = AnyEvent->timer(
        after => 0,
        interval => 5, # Check every 5 seconds
        cb => sub {
            open my $status_fh, '<', $status_path or die "Cannot open $status_path: $!";
            my $status = <$status_fh>;
            chomp $status;
            close $status_fh;

            open my $capacity_fh, '<', $capacity_path or die "Cannot open $capacity_path: $!";
            my $capacity = <$capacity_fh>;
            chomp $capacity;
            close $capacity_fh;

            $check_and_notify->($status, $capacity);
        },
    );
    return $timer; # Return the timer to keep it alive
}

1;
