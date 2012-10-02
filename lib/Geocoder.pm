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

package Geocoder;
use Downloader;

my $GEOCODE_BASE_URL = 'http://maps.googleapis.com/maps/api/geocode/json';
my $BOUNDARIES = 'bounds=-19.779320,-44.160561|-25.250469,-53.109612'; # Sao Paulo (State) Boundaries
my $SENSOR = 'sensor=false';

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
  my $url = $GEOCODE_BASE_URL . '?' . 'address=' . $address . '&' . $BOUNDARIES . '&' . $SENSOR;
  my $downloader = Downloader->new($url);
  my $content = $downloader->download;
  return $content;
}
