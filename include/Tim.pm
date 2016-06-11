#!/usr/bin/env/perl
use 5.020;
use strict;
use warnings;
use utf8;

use LWP::UserAgent;

package Tim;
require 'config.pm';
require 'IRC.pm';

# Trim leading and trailing whitespace.
sub trim_whitespace {
    my $string = shift;
    $string =~ s/^\s+|\s+$//g;
    return $string;
}

# Parse commands of the form "!command arg1 arg2 ...".
sub parse_command {
    my $msg = shift;

    if ($msg =~ /!(?<command>\S+)(?<args>.*)/g) {
        my $command = trim_whitespace($+{command});
        my @args = split(/ /, trim_whitespace($+{args}));

        return ($command, @args);
    }

    # No command was found.
    return;
}

sub parse_sender {
  my $who       = shift;
  my $nick      = (split /!/, $who)[0];

  return $nick;
}

sub make_request {
    my $url = shift;

    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new(GET => $url);
    my $resp = $ua->request($req);

    if ($resp->is_error) {
        log_message("HTTP GET error code: ", $resp->code, "\n");
        log_message("HTTP GET error message: ", $resp->message, "\n");
        return;
    }

    return $resp->decoded_content;
}

sub log_message {
    my $msg = shift;
    my $current_time = scalar localtime;
    say "[$current_time] $msg";
}

1;
