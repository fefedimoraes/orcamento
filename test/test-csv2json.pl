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
use CSV2JSON;

&main;

sub main {
  execute();
  #checkencoding();
}

sub execute {
  my $csvfile = '../data/raw/2012.csv';

  my $csv2json = CSV2JSON->new($csvfile);
  my $json_text = $csv2json->convert;

  print "$json_text";
}

sub checkencoding {
  my $jsonfile = '../data/json/2012.json';

  my @file;
  tie @file, 'Tie::File', $jsonfile or die "$?";
  my $line = $file[1243];
  $line =~ s/Ã/a/g;
  print "$line\n";
  untie @file;
}