#Copyright (C) 2012  Fernando Ferreira Diniz de Moraes

#This program is free software; you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation; either version 2 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License along
#with this program; if not, write to the Free Software Foundation, Inc.,
#51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
