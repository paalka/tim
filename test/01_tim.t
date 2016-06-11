use strict;
use warnings;
use utf8;
use Test::More tests => 6;

use Tim;

my $msg_whitespace = "  !vær arg1 arg2 arg3  ";
my $msg_no_whitespace = "!vær arg1 arg2 arg3";

# Make sure that whitespace is removed properly.
is(Tim::trim_whitespace($msg_whitespace), $msg_no_whitespace, "Leading and trailing whitespace is removed properly.");

# See whether the function is capable of parsing commands properly.
my ($cmd, @args) = Tim::parse_command($msg_whitespace);

my $expected_cmd = "vær";
my @expected_args = ("arg1", "arg2", "arg3");

is($cmd, $expected_cmd, "The command is properly parsed.");
is(@args, @expected_args, "The command is properly parsed.");

my ($cmd_invalid, @args_invalid) = Tim::parse_command("This is not a valid command.");
ok(!defined($cmd_invalid), "No command is returned if the command is invalid.");
ok(!@args_invalid, "No arguments is returned if the command is invalid.");

my $nick = Tim::parse_sender('nick!~nick@127.0.0.1');
is($nick, "nick", "The nick was obtained correctly.");
