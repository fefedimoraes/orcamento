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

# Converts a SEMPLA CSV into a Projeto/Atividade variable-based JSON.

package CSV2JSON;
use Tie::File;
use EntityExtractor;

my @csv;

sub new {
  my $class = shift;
  my $self = {
    _csvfilepath => shift,
    _separator => shift
  };

  die "Path to CSV file not provided." unless(defined($self->{_csvfilepath}));
  $self->{_separator} = ';' unless(defined($self->{_separator}));
  $self->{_extractor} = EntityExtractor->new;

  tie @csv, 'Tie::File', $self->{_csvfilepath} or die "$?";

  bless $self, $class;
  return $self;
}

my $get_row_type = sub {
  my $row = shift;
  my $type = $1 if($row =~ m/\**(.*?): /);
  $type =~ s/ã/a/g;
  $type =~ s/ç/c/g;
  $type =~ s/ô/o/g;
  $type =~ s/ /_/g;
  $type =~ s/-//g;
  $type = lc($type);

  $row =~ s/\**.*: //;
  return ($type, $row);
};

my $get_header = sub {
  my $self = shift;
  my @header = split(/$self->{_separator}/, $csv[0]);
  return @header;
};

my $get_entities = sub {
  my ($self, $string) = @_;
  my ($result, $debug) = $self->{_extractor}->extract_entities($string);
  my $entities = "";

  foreach my $tag (keys %{$result}) {
    my @array = @{$result->{$tag}};

    $entities .= "\t\t\t\t\"$tag\" : [\n";
    foreach my $element (@array) {
      $entities .= "\t\t\t\t\t\"$element\"";
      $entities .= $element eq $array[-1] ? "\n" : ",\n";
    }
    $entities .= $tag eq ((keys %{$result})[-1]) ? "\t\t\t\t]\n" : "\t\t\t\t],\n";
  }

  return($entities, $debug);
};

my $get_activity = sub {
  my ($self, $current, $rowvalues) = @_;
  my $activity;

  ${$rowvalues}[0] =~ s/\"//g; # Removes " characters from activity description
  ${rowvalues}[-1] =~ s/\s+$//; # Trims last value

  my ($entities, $debug) = $get_entities->($self, ${$rowvalues}[0]);

  $activity = (${$current}{id} == 0 ? "\n\t\t{\n" : ",\n\t\t{\n");
  $activity .= "\t\t\t\"id\" : \"${$current}{id}\",\n";
  $activity .= "\t\t\t\"orgao\" : \"${$current}{orgao}\",\n";
  $activity .= "\t\t\t\"unidade\" : \"${$current}{unidade}\",\n";
  $activity .= "\t\t\t\"funcao\" : \"${$current}{funcao}\",\n";
  $activity .= "\t\t\t\"sub_funcao\" : \"${$current}{subfuncao}\",\n";
  $activity .= "\t\t\t\"programa\" : \"${$current}{programa}\",\n";
  $activity .= "\t\t\t\"projeto/atividade\" : \"${$rowvalues}[0]\",\n";
  $activity .= "\t\t\t\"orcado\" : \"${$rowvalues}[1]\",\n";
  $activity .= "\t\t\t\"atualizado\" : \"${$rowvalues}[2]\",\n";
  $activity .= "\t\t\t\"empenhado\" : \"${$rowvalues}[3]\",\n";
  $activity .= "\t\t\t\"liquidado\" : \"${$rowvalues}[4]\",\n";
  $activity .= "\t\t\t\"entidades_georeferenciaveis\" : {\n";
  $activity .= "$entities";
  $activity .= "\t\t\t}\n";
#   $activity .= "\t\t\t\"debug\" : \"$debug\"\n";
  $activity .= "\t\t}";

  return $activity;
};

sub convert {
  my $self = shift;

  my %current = ();
  my $json;

  $json = "{\n\t\"projeto/atividade\" : [";
  $current{id} = 0;

  for my $i (2..scalar(@csv)) {
    my ($rowtype, $row) = $get_row_type->($csv[$i]);
    @rowvalues = split(/$self->{_separator}/, $row);
    if($rowtype eq "projeto/atividade") {
      my $activity = $get_activity->($self, \%current, \@rowvalues);
      $json .= $activity;
      $current{id} = $current{id} + 1;
    } else {
      $current{$rowtype} = $rowvalues[0];
    }
  }

  $json .= "\n\t]\n";
  $json .= "}\n";
  return $json;
}

sub DESTROY {
  untie @csv;
}

1;