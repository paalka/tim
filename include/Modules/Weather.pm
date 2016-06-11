#!/usr/bin/env perl
use 5.020;
use strict;
use warnings;
use utf8;

package Modules::Weather;

use JSON::MaybeXS;
use XML::Simple qw(:strict);

use lib '../';
use Tim;

sub construct_location_url {
    my $location = shift;

    my $base_url = 'https://www.yr.no/_/websvc/jsonforslagsboks.aspx?s=';
    my $url = $base_url . $location;

    my $raw_search_response = Tim::make_request($url);
    my @locations_data = decode_json($raw_search_response);

    return $locations_data[0][1][0][1];
}

sub generate_weather_report {
    my ($location, @args) = @_;
    my $location_subdir = '/sted/Norge/Sør-trøndelag/Trondheim/Studentersamfundet/';

    if (defined($location)) {
        $location_subdir = construct_location_url($location);
    }

    my $base_url = 'https://www.yr.no';
    my $forecast_url = $base_url . $location_subdir . "varsel.xml";

    my $raw_forecast_xml = Tim::make_request($forecast_url);
    my $xml_ref = XMLin($raw_forecast_xml, KeyAttr => ['forecast'], ForceArray => ['forecast']);

    my $location_name = $xml_ref->{'location'}->{'name'};
    my $current_day_ref = $xml_ref->{'forecast'}[0]->{'tabular'}->{'time'}[0];

    # Wind speed in m/s
    my $wind_speed = $current_day_ref->{'windSpeed'}->{'mps'};
    my $wind_speed_describ = $current_day_ref->{'windSpeed'}->{'name'};

    # Temperature in celcius
    my $temp = $current_day_ref->{'temperature'}->{'value'};
    # Expected rain in mm
    my $rain_mm = $current_day_ref->{'precipitation'}->{'value'};

    return sprintf("%s: %s °C, %s (%s m/s), %s mm regn", $location_name, $temp,
                                                         $wind_speed_describ,
                                                         $wind_speed,
                                                         $rain_mm);
}
