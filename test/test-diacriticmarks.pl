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