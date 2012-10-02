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

# Extracts entities from a given string.

#!/usr/bin/perl

package EntityExtractor;
use JSONLoader;

sub new {
  my $class = shift;
  my $self = {
    _listspath => shift || "../resources/algorithm/lists.json",
  };

  my $jsonloader = JSONLoader->new;
  ${$self}{_lists} = $jsonloader->load($self->{_listspath});
  ${$self}{_blacklist} = map { $_ => 1} @{$self->{_lists}->{blacklist}};

  bless $self, $class;
  return $self;
}

my $pushmatch = sub {
  my ($self, $array, $match) = @_;
  $match =~ s/^\s+//; # Removes leading spaces
  $match =~ s/\s+$//; # Removes trailing spaces
  push(@{$array}, $match) unless ${$self->{_blacklist}{lc($match)}};
};

sub extract_entities {
  my $self = shift;
  my $string = shift;
  my %result = ();

  foreach my $key (keys %{$self->{_lists}->{replace}}) {
    $string =~ s/$key/${$self->{_lists}->{replace}}{$key}/gi;
  }

  foreach my $term (@{$self->{_lists}->{terms}}) {
    my $regexp = defined($term->{secondterm}) ? qr/$term->{secondterm}/ : qr/[^;,]+/;
    my @entities = ();

    while($string =~ m/\b($term->{term})\b\s*$regexp/gi) {
    #while($string =~ m/\b($term->{term})\b\s*$regexp/gi) {
      $pushmatch->($self, \@entities, $&);
    }
    $result{$term->{tag}} = \@entities if(@entities);
  }

  return (\%result, $string);
}

1;
