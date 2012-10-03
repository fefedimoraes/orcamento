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

package CSV2JSON;
use Fcntl 'O_RDONLY';
use Tie::File;
use JSON::PP;
use EntityExtractor;

sub new {
  my $class = shift;
  my $self = {
    _csvfilepath => shift,
    _comma => shift || ';'
  };

  bless $self, $class;
  return $self;
}

sub extract_row_type {
  my $row = shift;
  my $type = "undefined";

  if($row =~ m/^\**(.*?): /) {
    $type = $1;
    $type =~ s/ã/a/g;
    $type =~ s/ç/c/g;
    $type =~ s/ô/o/g;
    $type =~ s/ /_/g;
    $type =~ s/-//g;
    $type = lc($type);
  }

  $row =~ s/^\**.*: //;
  return ($type, $row);
}

sub extract_entities {
  my $string = shift;
  my $extractor = EntityExtractor->new;
  my ($result, $debug) = $extractor->extract_entities($string);
  return $result;
}

sub get_project {
  my $row_ref = shift;
  my $current_ref = shift;
  my @row_values = @{$row_ref};
  my %current_values = %{$current_ref};

  # Some descriptions contain '"' characters, screwing json up. That's why we should remove it.
  $row_values[0] =~ s/"//g;
  $row_values[-1] =~ s/\s+$//; # Trims last value

  my $entities = extract_entities($row_values[0]);
  $current_values{descricao} = $row_values[0];
  $current_values{orcado} = $row_values[1];
  $current_values{atualizado} = $row_values[2];
  $current_values{empenhado} = $row_values[3];
  $current_values{liquidado} = $row_values[4];
  $current_values{entidades} = $entities;

  return %current_values;
}

sub convert {
  my $self = shift;
  my $path = $self->{_csvfilepath} || shift || die "No path to csv provided.";

  my @projects = ();
  my %current_values = ();
  $current_values{id} = 0;

  tie my @csv, 'Tie::File', $path, autochomp => 1 or die "$!";

  for my $i (2..scalar(@csv)-1) {
    my ($type, $row) = extract_row_type($csv[$i]);
    my @row_values = split(/$self->{_comma}/, $row);
    if($type eq "projeto/atividade") {
      my %project = get_project(\@row_values, \%current_values);
      push(@projects, \%project);
      $current_values{id} = $current_values{id} + 1;
    } else {
      $current_values{$type} = $row_values[0] unless($type eq "fonte" || $type eq "modalidade_da_despesa" || $type eq "categoria_da_despesa" || $type eq "elemento_economico");
    }
  }

  untie @csv;

  my $json = JSON::PP->new->allow_nonref->pretty->utf8;
  my $json_text = $json->encode(\@projects);
  return $json_text;
}

1;
