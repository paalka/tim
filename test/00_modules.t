use strict;
use warnings;
use Test::More tests => 6;

require_ok("config.pm");
require_ok("IRC.pm");
use_ok("Tim");

# Test all sub modules
use_ok("Modules::Weather");
use_ok("Modules::AtB");
use_ok("Modules::Jenkins");
