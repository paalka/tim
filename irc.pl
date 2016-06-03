#!/usr/local/bin/perl

use 5.020;
use strict;
use warnings;
use lib 'include/';

use POE;
use POE::Component::IRC;

use Tim;

my ($irc) = POE::Component::IRC->spawn();

# The create() call specifies the events the bot
# knows about and the functions that will handle those events.
say "Creating session...";
POE::Session->create(
  inline_states => {
    _start            => \&start_bot,
    irc_disconnected  => \&reconnect,
    irc_error         => \&reconnect,
    irc_socketerr     => \&reconnect,
    autoping          => \&do_auto_self_ping,
    irc_001           => \&on_connect,
    irc_public        => \&on_public,
  },
);

sub connect_to_server {
  my ($nick, $username, $ircname, $server, $port) = @_;
  say "Connecting to server: $server using port $port";
  $irc->yield(
    connect => {
      Nick     => $nick,
      Username => $username,
      Ircname  => $ircname,
      Server   => $server,
      Port     => $port,
    }
  );
}

sub start_bot {
  # Register which IRC related events to listen for (i.e. join, part, etc).
  $irc->yield(register => "all");

  connect_to_server($Tim::Config::nick,
                    $Tim::Config::username, $Tim::Config::real_name,
                    $Tim::Config::server, $Tim::Config::server_port);
}

# The bot has successfully connected to a server
sub on_connect {
  my ($kernel, $heap) = @_[KERNEL, HEAP];
  say "Joining channels...";
  for my $channel (@Tim::Config::channels) {
      say "Joining $channel...";
      $irc->yield(join => $channel);
  }

  # Ensure that the bot pings itself every 300 seconds, so that we avoid
  # timeouts.
  $heap->{seen_traffic} = 1;
  $kernel->delay(autoping => 300);
}

# Ping ourself to avoid timeouts.
sub do_auto_self_ping {
    my ($kernel, $heap) = @_[KERNEL, HEAP];

    if (!$heap->{seen_traffic}) {
        $kernel->post(poco_irc => userhost => $Tim::Config::nick)
    }

    $heap->{seen_traffic} = 0;
    $kernel->delay(autoping => 300);
}

sub reconnect {
    my $kernel = $_[KERNEL];

    $kernel->delay(autoping => undef);
    $kernel->delay(connect => $Tim::Config::reconnect_wait_sec);
}

# The bot has received a public message.
# Parse it for commands.
sub on_public {
  my ($kernel, $who, $where, $msg) = @_[KERNEL, ARG0, ARG1, ARG2];
  my ($nick, $channel, $time_sent) = Tim::parse_msg($who, $where->[0]);

  say "[$time_sent] <$nick:$channel> $msg";
  Tim::parse_commands($msg);
}

$poe_kernel->run();
exit 0;
