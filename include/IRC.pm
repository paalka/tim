#!/usr/bin/env perl
use 5.020;
use strict;
use warnings;
use utf8;

use POE qw(Component::IRC);
use Encode qw(decode encode);

package Tim::IRC;

sub get_irc_component {
    my $heap = shift;
    return $heap->{irc};
}

sub connect_to_server {
  my ($heap, $nick, $username, $ircname, $server, $port) = @_;
  Tim::log_message("Connecting to server: $server using port $port");
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

  Tim::log_message("Joining channels...");
  for my $channel (@Tim::Config::channels) {
      Tim::log_message("Joining $channel...");
      $irc->yield(join => $channel);
      Tim::log_message("Joined $channel!");
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

  $heap->{seen_traffic} = 1;

  my $nick = Tim::parse_sender($who);
  return unless ($nick ne $Tim::Config::nick);

  my $channel = $where->[0];

  Tim::log_message("<$nick:$channel> $msg");
  my ($cmd, @args) = Tim::parse_command($msg);

  if (!defined($cmd)) {
      return;
  }

  my $command_handler = $Tim::Config::command_handlers{Encode::decode_utf8($cmd)}{Tim::Config::HANDLER()};
  if (defined($command_handler)) {
      eval {
          my $response = $command_handler->(@args);
          send_msg($nick, $response, $channel, $heap);
      }; send_msg($nick, $@, $channel, $heap) if $@;
  } elsif ($cmd eq Tim::Config::HELP()) {
      print_command_handlers_help($nick, $channel, $heap);
  } else {
      send_msg($nick, "Unrecognized command! Write !help to show the available commands.", $channel, $heap);
  }
}

sub print_command_handlers_help {
    my ($sender_nick, $channel, $heap) = @_;

    foreach my $cmd_name (sort(keys %Tim::Config::command_handlers)) {
        my $help_handler = $Tim::Config::command_handlers{$cmd_name}{Tim::Config::HELP()};

        if (defined($help_handler)) {
            my $help_msg = $help_handler->();
            my $msg = "!$cmd_name $help_msg";

            send_msg($sender_nick, $msg, $channel, $heap);
        }
    }
}

sub send_msg {
    my ($sender_nick, $msg, $channel, $heap) = @_;
    my $irc = get_irc_component($heap);

    my @msg_lines = split("\n", $msg);

    # This is a privmsg, so the channel is the senders nick.
    if ($channel eq $Tim::Config::nick) {
        $channel = $sender_nick;
    }

    foreach $msg (@msg_lines) {
        $irc->yield(privmsg => $channel => $msg);
    }

    return;
}

1;
