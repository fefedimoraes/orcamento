#!/usr/bin/perl

use strict;
use warnings;
use lib "../lib";
use JSONLoader;
use CachedGeocoder;

$| = 1;

&main;

sub main {
  my $path = $ARGV[0];
  find_geocodes($path);
}

sub find_geocodes {
  my $path = shift;

  my $jl = JSONLoader->new;
  my $data = $jl->load($path);
  my $geocoder = CachedGeocoder->new;

  foreach my $project_ref (@{$data}) {
    my $entities_ref = $project_ref->{entidades};
    foreach my $tag (keys %{$entities_ref}) {
      my @entities_array = @{$entities_ref->{$tag}};
      foreach my $entity (@entities_array) {
	my $response = $geocoder->geocode($entity);
	if($response =~ m/OK/) {
	  print "$entity: OK.\n";
	} elsif($response =~ m/ZERO_RESULTS/) {
	  print "$entity: ZERO_RESULTS.\n";
	} elsif($response =~ m/OVER_QUERY_LIMIT/) {
	  print "OVER_QUERY_LIMIT at $entity. Exiting ...\n";
	  die;
	}
      }
    }
  }
}