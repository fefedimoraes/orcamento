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

package DiacriticMarks;
use Unicode::UCD 'charinfo';
use Encode 'decode_utf8';

sub new {
  my $class = shift;
  my $self = {
    _str => shift
  };

  bless $self, $class;
  return $self;
}

sub strip_string {
  my $self = shift;
  my $string = shift || $self->{_str} || die "No string provided.";

  $string =~ s/(Á|À|Ã|Â|Ä)/A/g;
  $string =~ s/(á|à|ã|â|ä)/a/g;

  $string =~ s/(É|È|Ẽ|Ê|Ë)/E/g;
  $string =~ s/(é|è|ẽ|ê|ë)/e/g;

  $string =~ s/(Í|Ì|Ĩ|Î|Ï)/I/g;
  $string =~ s/(í|ì|ĩ|î|ï)/i/g;

  $string =~ s/(Ó|Ò|Õ|Ô|Ö)/O/g;
  $string =~ s/(ó|ò|õ|ô|ö)/o/g;

  $string =~ s/(Ú|Ù|Ũ|Û|Ü)/U/g;
  $string =~ s/(ú|ù|ũ|û|ü)/u/g;

  $string =~ s/Ç/C/g;
  $string =~ s/ç/c/g;

  return $string;
}

sub strip_file {
  $self = shift;
  my $path = shift || die "No path provided.";
  my $stripped_file = "";
  open FILE, "<", $path or die $!;
  while(<FILE>) {
    $line = strip_string($self, $_);
    $stripped_file .= $line;
  }
  return $stripped_file;
}

1;
