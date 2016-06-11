#!/usr/bin/env/perl
use 5.020;
use strict;
use warnings;
use utf8;

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

    if ($msg =~ /!(?<command>\w+)(?<args>.*)/g) {
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
  my $time_sent = scalar localtime;

  return ($nick, $time_sent);
}

1;
