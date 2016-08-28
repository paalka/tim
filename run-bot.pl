#!/usr/bin/env perl
use 5.020;
use strict;
use warnings;
use lib 'include/';
use utf8;

use POE qw(Component::IRC);
use Tim;

my $irc = POE::Component::IRC->spawn();

Tim::log_message("Creating session...");
POE::Session->create(
  inline_states => {
    _start            => \&Tim::IRC::start_bot,
    irc_disconnected  => \&Tim::IRC::reconnect,
    irc_error         => \&Tim::IRC::reconnect,
    irc_socketerr     => \&Tim::IRC::reconnect,
    autoping          => \&Tim::IRC::do_auto_self_ping,
    irc_001           => \&Tim::IRC::on_connect,
    irc_public        => \&Tim::IRC::message_handler,
    irc_msg           => \&Tim::IRC::message_handler,
    periodic_tasks    => \&Tim::IRC::run_periodic_tasks,
  },
  # Store the irc component in the heap, so that it is easily accessible.
  heap => { irc => $irc },
);

$poe_kernel->run();
exit 0;
