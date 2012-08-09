#!/usr/bin/perl

use warnings;
use strict;
use lib "../lib";
use CSV2JSON;

&main;

sub main {
  my $csvfile = '../resources/data/stripped/2011.csv';

  my $csv2json = CSV2JSON->new($csvfile);

#   my @projects = $csv2json->convert;
#   print Dumper \@projects;

  my $json = $csv2json->convert;
  print "$json\n";
}