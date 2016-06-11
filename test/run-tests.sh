#!/bin/sh
prove -e '/usr/bin/perl -MDevel::Cover -I. -I../include' *.t
cover
