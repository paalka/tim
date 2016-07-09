#!/usr/bin/env perl
use 5.020;
use strict;
use warnings;
use utf8;
use Module::Refresh;

package Modules::Reload;
use lib '../';

sub reload_config {
    my $refresher = Module::Refresh->new;
    $refresher->refresh_module('local.config.pm');
    return "The local config was refreshed!";
}

1;
