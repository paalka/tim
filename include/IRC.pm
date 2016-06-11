#!/usr/bin/env perl
use 5.020;
use strict;
use warnings;
use utf8;

use POE qw(Component::IRC);

package Tim::IRC;

sub get_irc_component {
    my $heap = shift;
    return $heap->{irc};
}

sub connect_to_server {
  my ($heap, $nick, $username, $ircname, $server, $port) = @_;
  say "Connecting to server: $server using port $port";
  my $irc = get_irc_component($heap);

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
  my $heap = @_[POE::Session::HEAP];
  my $irc = get_irc_component($heap);

  # Register which IRC related events to listen for (i.e. join, part, etc).
  $irc->yield(register => "all");

  connect_to_server($heap, $Tim::Config::nick,
                    $Tim::Config::username, $Tim::Config::real_name,
                    $Tim::Config::server, $Tim::Config::server_port);
}

# The bot has successfully connected to a server
sub on_connect {
  my ($kernel, $heap) = @_[POE::Session::KERNEL, POE::Session::HEAP];
  my $irc = get_irc_component($heap);

  say "Joining channels...";
  for my $channel (@Tim::Config::channels) {
      say "Joining $channel...";
      $irc->yield(join => $channel);
  }

  # Ensure that the bot pings itself every 'auto_ping_delay' seconds, so that
  # we avoid timeouts.
  $heap->{seen_traffic} = 1;
  $kernel->delay(autoping => $Tim::Config::auto_ping_delay);
}

# Ping ourself to avoid timeouts.
sub do_auto_self_ping {
    my ($kernel, $heap) = @_[POE::Session::KERNEL, POE::Session::HEAP];
    my $irc = get_irc_component($heap);

    if (!$heap->{seen_traffic}) {
        $kernel->post(poco_irc => userhost => $Tim::Config::nick)
    }

    $heap->{seen_traffic} = 0;
    $kernel->delay(autoping => $Tim::Config::auto_ping_delay);
}

# Attempt to reconnect after 'reconnect_wait_sec' seconds.
sub reconnect {
    my $kernel = $_[POE::Session::KERNEL];

    $kernel->delay(autoping => undef);
    $kernel->delay(connect => $Tim::Config::reconnect_wait_sec);
}

# The bot has received a public message.
# Parse it for commands.
sub message_handler  {
  my ($kernel, $heap, $who, $where, $msg) = @_[POE::Session::KERNEL,
                                               POE::Session::HEAP,
                                               POE::Session::ARG0,
                                               POE::Session::ARG1,
                                               POE::Session::ARG2];

  my ($nick, $time_sent) = Tim::parse_sender($who);
  my $channel = $where->[0];

  say "[$time_sent] <$nick:$channel> $msg";
  my ($cmd, @args) = Tim::parse_command($msg);

  $heap->{seen_traffic} = 1;
}

1;
