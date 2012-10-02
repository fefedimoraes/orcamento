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
use JSON -support_by_pp;

&main;

sub main {
  my $path = $ARGV[0];
  geocode_entities($path);
}

sub geocode_entities {
  my $path = shift;
  my $geocoder = CachedGeocoder->new;
  my $json = new JSON;
  my $jsonloader = JSONLoader->new;
  my $data = $jsonloader->load($path);

  for my $entry (@{$data}) {
    my $entities = $entry->{entidades};
    my @coordinates = ();
    for my $tag (keys %{$entities}) {
      next if($tag eq "numero"); # FIXME
      my $tag_entities = $entities->{$tag};
      for my $entity (@{$tag_entities}) {
	my $response = $geocoder->geocode($entity);
	my $response_data = $json->decode($response);
	next if($response_data->{status} eq "ZERO_RESULTS");
	die "$entity: Over Query Limit" if($response_data->{status} eq "OVER_QUERY_LIMIT");
	my @entity_coordinates = ();
	for my $result (@{$response_data->{results}}) {
	  my $location = $result->{geometry}->{location};
	  push(@entity_coordinates, $location);
	}
	my $coordinates_data = {};
	$coordinates_data->{entidade} = $entity;
	$coordinates_data->{tag} = $tag;
	$coordinates_data->{localizacoes} = \@entity_coordinates;
	push(@coordinates, $coordinates_data);
      }
    }
    $entry->{coordenadas} = \@coordinates;
  }

  my $json_text = $json->allow_nonref->pretty->utf8->encode($data);
  print "$json_text\n";
}
