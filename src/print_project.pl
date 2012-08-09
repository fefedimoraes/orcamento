#!/usr/bin/perl

use strict;
use warnings;
use lib "../lib";
use JSONLoader;
use Data::Dumper;

&main;

sub main {
  my $path = $ARGV[0];
  print_project($path);
}

sub print_project {
  my $path = shift;
  my $jsonloader = JSONLoader->new;
  my $data = $jsonloader->load($path);
  for my $entry (@{$data}) {
    my $entidades = $entry->{entidades};
    print "Descricao: $entry->{descricao}\n";
    print Dumper $entidades;
    print "\n";
  }
}