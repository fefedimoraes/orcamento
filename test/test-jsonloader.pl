#!/usr/bin/perl

use warnings;
use strict;
use lib "../lib";
use JSONLoader;
use Data::Dumper;

&main;

sub main {
  my $path = "../resources/data/json/2012.json";
  my $jsonloader = JSONLoader->new;
  my $data = $jsonloader->load($path);
  print Dumper $data;
}