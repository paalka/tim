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
  my ($who, $channel) = @_;
  my $nick    = (split /!/, $who)[0];
  my $time_sent      = scalar localtime;

  return ($nick, $channel, $time_sent);
}

1;
