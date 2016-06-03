#!/usr/local/bin/perl

use 5.020;
use strict;
use warnings;
use lib 'include/';

use POE qw(Component::IRC);

use Tim;

my $irc = POE::Component::IRC->spawn();

# The create() call specifies the events the bot
# knows about and the functions that will handle those events.
say "Creating session...";
POE::Session->create(
  inline_states => {
    _start            => \&Tim::IRC::start_bot,
    irc_disconnected  => \&Tim::IRC::reconnect,
    irc_error         => \&Tim::IRC::reconnect,
    irc_socketerr     => \&Tim::IRC::reconnect,
    autoping          => \&Tim::IRC::do_auto_self_ping,
    irc_001           => \&Tim::IRC::on_connect,
    irc_public        => \&Tim::IRC::on_public,
  },
  heap => { irc => $irc },
);

$poe_kernel->run();
exit 0;
