#!/usr/bin/perl

use strict;
use warnings;

my @examples = ('blabalba cep: 02250-010 mais merda aqui',
		'blabalba CEP: 02250-010 mais merda aqui',
		'blabalba cep 02250010 mais merda aqui',
		'blabalba CEP 02250-010 mais merda aqui',
		'blabalba CEP  02250-010 mais merda aqui',
		'blabalba 02250-010 mais merda aqui');

&main;

sub main {
  foreach my $example (@examples) {
    print "Example: $example\n";
    print "Found:\n";
    extract_cep($example);
    print "\n";
  }
}

sub extract_cep {
  my $string = shift;

  while($string =~ m/\d{5}-\d{3}/gi) {
    print "\'$&\'\n";
  }
}
