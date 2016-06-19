package Tim::Config;

use 5.020;
use strict;
use warnings;
use utf8;

use Modules::Weather;

# Create the mapping between commands and functions.
our $command_handlers = {
    "vær" => \&Modules::Weather::generate_weather_report,
};

# The list of channels to join.
our @channels = ("#example1", "#example2");

# Which server the channels are located on.
our $server = "irc.example.net";
our $server_port = 6667;

our $nick = "Your nick here";
our $username = $nick;
our $real_name = "Your name here";

our $reconnect_wait_sec = 60;
our $auto_ping_delay = 300;

# Load the local config file, if it exists.
eval {
    require 'local.config.pm';
}; die $@ if $@;

1;
