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
use DiacriticMarks;

&main;

sub main {
  #&test1;
  &test2;
}

sub test1 {
  my $string = "àÀâÂäçéÉèÈêÊëîïôùÙûüÜ";
  my $dc = DiacriticMarks->new($string);
  my $newstring = $dc->strip;
  print "$string\n$newstring\n";
}

# sub test2 {
#   my $path = "../resources/data/raw/2012.csv";
#   open FILE, "<", $path or die $!;
#   my $dc = DiacriticMarks->new;
#   while(<FILE>) {
#     my $newstring = $dc->strip($_);
#     print $newstring;
#   }
# }

sub test2 {
  my $path = "../resources/data/raw/2011.csv";
  my $dc = DiacriticMarks->new;
  my $stripped_file = $dc->strip_file($path);
  print $stripped_file;
}
