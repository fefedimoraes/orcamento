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
use EntityExtractor;
use Data::Dumper;

#my $string = "Ama (AMA) nome da ama alt. do";
#my $string = "O cep é CEP: 02250-010";
#my $string = "O CNPJ da AMA Nome da AMA; é CNPJ 15.926.068/0001-73";
my $string = "Reforma e Ampliação de Edificações da Câmara Municipal de São Paulo";

my $extractor = EntityExtractor->new;
my ($result, $newstring) = $extractor->extract_entities($string);

print Dumper($result);

# foreach my $tag (keys %{$result}) {
#   my @entities = @{$result->{$tag}};
#
#   print "\"$tag\" : [\n";
#   foreach my $entity (@entities) {
#     print "\t\"$entity\"";
#     $entity eq $entities[-1] ? print "\n" : print ",\n";
#   }
#   $tag eq ((keys %{$result})[-1]) ? print "]\n" : print "],\n";
# }
#
# print "\"debug\" : \"$newstring\"\n";
