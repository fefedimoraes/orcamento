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
