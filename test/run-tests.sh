#!/bin/sh
set -e
echo "Running tests..."
prove -e '/usr/bin/perl -MDevel::Cover -I. -I../include' *.t
cover
