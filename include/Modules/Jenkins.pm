#!/usr/bin/env perl
use 5.020;
use strict;
use warnings;
use utf8;

package Modules::Jenkins;

use JSON::MaybeXS;

use lib '../';
use Tim;

sub make_jenkins_api_request {
    my $api_url = shift;
    my $base_url = "$Tim::Config::jenkins_url/$api_url";

    my $raw_response = Tim::make_request($base_url, $Tim::Config::jenkins_username, $Tim::Config::jenkins_token);
    my $decoded_json_response = decode_json($raw_response);

    return $decoded_json_response;
}

sub get_failed_jobs {
    my $last_builds_api_url= "api/json?tree=jobs[name,lastBuild[result]]";
    my $json_response = make_jenkins_api_request($last_builds_api_url);
    my @failed_jobs = ();

    if (defined($json_response)) {
        my @all_jobs = @{$json_response->{"jobs"}};

        if (@all_jobs) {
            # Loop through all the jobs, and get those who have failed.
            foreach my $job (@all_jobs) {
                my $last_result = lc $job->{"lastBuild"}->{"result"};
                if ($last_result ne lc $Tim::Config::jenkins_success_status) {
                    push @failed_jobs, $job;
                }
            }
        }

        return @failed_jobs;
    }
}

sub create_failed_builds_report {
    my @failed_builds = get_failed_jobs();
    my @status_msgs = ();

    if (@failed_builds) {
        foreach my $failed_build (@failed_builds) {
            my $build_status = $failed_build->{"lastBuild"}->{"result"};
            my $build_name = $failed_build->{"name"};

            my $status_msg = "Failed to build $build_name (status: $build_status)!";
            push @status_msgs, $status_msg;
        }
    }

    return join("\n", @status_msgs);
}

1;
