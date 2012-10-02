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
