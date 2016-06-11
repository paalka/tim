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

sub parse_command {
    my $msg = shift;
}

sub parse_msg {
  my $who       = shift;
  my $nick      = (split /!/, $who)[0];
  my $time_sent = scalar localtime;

  return ($nick, $time_sent);
}

1;
