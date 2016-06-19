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
our @channels = ("#956f7fd1ae68f");

# Which server the channels are located on.
our $server = "irc.freenode.net";
our $server_port = 6667;

our $nick = "tim_the_bot";
our $username = $nick;
our $real_name = "kek";

our $reconnect_wait_sec = 60;
our $auto_ping_delay = 300;
