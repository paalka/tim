#!/usr/bin/env perl
use 5.020;
use strict;
use warnings;
use utf8;

package Modules::AtB;

use JSON::MaybeXS;
use XML::Simple qw(:strict);

use lib '../';
use Tim;

sub ask_bus_oracle {
    return 'Invalid question! Usage: !<command> $question.' unless (@_);

    my $question = join(' ', @_);

    my $base_url = 'https://www.atb.no/xmlhttprequest.php?service=routeplannerOracle.getOracleAnswer&question=';
    my $url = $base_url . $question;

    my $oracle_response = Tim::trim_whitespace(Tim::make_request($url));
    return $oracle_response;
}

sub argument_help {
    return "<question to the bus oracle>";
}

1;
