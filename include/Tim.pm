#!/usr/bin/env/perl
use 5.020;
use strict;
use warnings;
use utf8;

package Tim;
require 'config.pm';

sub parse_commands {
    my $msg = shift;
    print $msg;
}

sub parse_msg {
  my $who       = shift;
  my $nick      = (split /!/, $who)[0];
  my $time_sent = scalar localtime;

  return ($nick, $time_sent);
}

1;
