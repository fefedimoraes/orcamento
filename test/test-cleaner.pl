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
use JSON -support_by_pp;
use Data::Dumper;

my $loader = JSONLoader->new;
my $data = $loader->load('../src/2011-geocoded.json');

clean_invalid_location($data);
#clean_empty_coordinate($data);

#my $json_text = JSON->new->allow_nonref->pretty->utf8->encode($data);
#print $json_text;

sub locationIsValid {
  my $location = shift;
  my $lat = $location->{lat};
  my $lng = $location->{lng};
  if($lat < -23.395660 && $lat > -23.784969 && $lng < -46.364990 && $lng > -46.809319) {
    return 1;
  }
  return 0;
}

sub clean {
  my $data = shift;
  for my $entry (@{$data}) {
    my $coordinates = $entry->{coordenadas};
    for my $tag (keys %{$coordinates}) {
      my $entities = $coordinates->{$tag};
      my @valid_entities = ();
      for my $entity (@{$entities}) {
	my $locations = $entity->{localizacoes};
	my @valid_locations = ();

	for my $location (@{$locations}) {
	  if(locationIsValid($location)) {
	    push(@valid_locations, $location);
	  }
	}
	if(scalar @valid_locations) {
	  $entity->{localizacoes} = \@valid_locations;
	  push(@valid_entities, $entity);
	}
      }
      if(scalar @valid_entities) {
	$coordinates->{$tag} = \@valid_entities;
      } else {
	delete($coordinates->{$tag});
      }
    }
  }
}
