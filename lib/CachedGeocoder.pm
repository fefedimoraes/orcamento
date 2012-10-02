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

package CachedGeocoder;
use Geocoder;
use GeocoderCache;

sub new {
  my $class = shift;
  my $self = {
    _address => shift
  };

  bless $self, $class;
  return $self;
}

sub geocode {
  my $self = shift;
  my $address = shift || $self->{_address} || die "No address provided.";

  my $cache = GeocoderCache->new;
  my $response = $cache->select($address);
  return ${${$response}[0]}[-1] if (scalar(@{$response}));

  my $geocoder = Geocoder->new;
  $response = $geocoder->geocode($address);
  $cache->insert($address, $response);
  return $response;
}

1;
