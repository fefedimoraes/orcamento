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
use JSONLoader;
use Data::Dumper;

&main;

sub main {
  my $filepath = $ARGV[0];
  my $jsonloader = new JSONLoader;
  my $data = $jsonloader->load($filepath);

  my @entity_w_location = ();
  my @entity_w_multiple_location = ();
  my @entity_wo_location = ();
  my @no_entity = ();

  foreach my $entry (@{$data}) {
    my %entities = %{$entry->{entidades}};
    if(scalar keys %entities) {
      my @coordinates = @{$entry->{coordenadas}};
      if(scalar @coordinates == 0) {
	push(@entity_wo_location, $entry);
      } elsif (scalar @coordinates == 1){
	my $coordinate = shift(@coordinates);
	my @locations = @{$coordinate->{localizacoes}};
	if(scalar @locations == 1) {
	  push(@entity_w_location, $entry);
	} else {
	  push(@entity_w_multiple_location, $entry);
	}
      } else {
	push(@entity_w_multiple_location, $entry);
      }
    } else {
      push(@no_entity, $entry);
    }
  }

  my %values;

  open FILE, ">", "entity_w_location.txt" or die $!;
  %values = ();
  foreach my $entry (@entity_w_location) {
    print FILE "\n";
    print FILE Dumper $entry;

    my $orcado = $entry->{orcado};
    my $atualizado = $entry->{atualizado};
    my $empenhado = $entry->{empenhado};
    my $liquidado = $entry->{liquidado};

    $orcado =~ s/\.//g;
    $orcado =~ s/,/\./g;

    $atualizado =~ s/\.//g;
    $atualizado =~ s/,/\./g;

    $empenhado =~ s/\.//g;
    $empenhado =~ s/,/\./g;

    $liquidado =~ s/\.//g;
    $liquidado =~ s/,/\./g;

    $values{'orcado'} = ($values{'orcado'} ? $values{'orcado'} + $orcado : $orcado);
    $values{'atualizado'} = ($values{'atualizado'} ? $values{'atualizado'} + $atualizado : $atualizado);
    $values{'empenhado'} = ($values{'empenhado'} ? $values{'empenhado'} + $empenhado : $empenhado);
    $values{'liquidado'} = ($values{'liquidado'} ? $values{'liquidado'} + $liquidado : $liquidado);

    my $coordinates = $entry->{coordenadas};
    foreach my $coordinate (@{$coordinates}) {
      my $locations = $coordinate->{localizacoes};
      foreach my $location (@{$locations}) {
	if(locationIsValid($location->{lat}, $location->{lng})) {
	  print FILE "Valido\n";
	  $values{'valido'} = ($values{'valido'} ? $values{'valido'} + 1 : 1);
	} else {
	  print FILE "Invalido\n";
	  $values{'invalido'} = ($values{'invalido'} ? $values{'invalido'} + 1 : 1);
	}
      }
    }
  }
  print FILE "Quantidade: " . scalar @entity_w_location . "\n";
  print FILE "Orçado: $values{'orcado'}\n";
  print FILE "Atualizado: $values{'atualizado'}\n";
  print FILE "Empenhado: $values{'empenhado'}\n";
  print FILE "Liquidado: $values{'liquidado'}\n";
  print FILE "Coordenadas Validas: $values{'valido'}\n";
  print FILE "Coordenadas Invalidas: $values{'invalido'}\n";
  close FILE;

  open FILE, ">", "entity_w_multiple_location.txt" or die $!;
  %values = ();
  foreach my $entry (@entity_w_multiple_location) {
    print FILE "\n";
    print FILE Dumper $entry;

    my $orcado = $entry->{orcado};
    my $atualizado = $entry->{atualizado};
    my $empenhado = $entry->{empenhado};
    my $liquidado = $entry->{liquidado};

    $orcado =~ s/\.//g;
    $orcado =~ s/,/\./g;

    $atualizado =~ s/\.//g;
    $atualizado =~ s/,/\./g;

    $empenhado =~ s/\.//g;
    $empenhado =~ s/,/\./g;

    $liquidado =~ s/\.//g;
    $liquidado =~ s/,/\./g;

    $values{'orcado'} = ($values{'orcado'} ? $values{'orcado'} + $orcado : $orcado);
    $values{'atualizado'} = ($values{'atualizado'} ? $values{'atualizado'} + $atualizado : $atualizado);
    $values{'empenhado'} = ($values{'empenhado'} ? $values{'empenhado'} + $empenhado : $empenhado);
    $values{'liquidado'} = ($values{'liquidado'} ? $values{'liquidado'} + $liquidado : $liquidado);

    my $coordinates = $entry->{coordenadas};
    foreach my $coordinate (@{$coordinates}) {
      my $locations = $coordinate->{localizacoes};
      foreach my $location (@{$locations}) {
	if(locationIsValid($location->{lat}, $location->{lng})) {
	  print FILE "Valido.\n";
	  $values{'valido'} = ($values{'valido'} ? $values{'valido'} + 1 : 1);
	} else {
	  print FILE "Invalido.\n";
	  $values{'invalido'} = ($values{'invalido'} ? $values{'invalido'} + 1 : 1);
	}
      }
    }
  }
  print FILE "Quantidade: " . scalar @entity_w_multiple_location . "\n";
  print FILE "Orçado: $values{'orcado'}\n";
  print FILE "Atualizado: $values{'atualizado'}\n";
  print FILE "Empenhado: $values{'empenhado'}\n";
  print FILE "Liquidado: $values{'liquidado'}\n";
  print FILE "Coordenadas Validas: $values{'valido'}\n";
  print FILE "Coordenadas Invalidas: $values{'invalido'}\n";
  close FILE;

  open FILE, ">", "entity_wo_location.txt" or die $!;
  %values = ();
  foreach my $entry (@entity_wo_location) {
    print FILE Dumper $entry;

    my $orcado = $entry->{orcado};
    my $atualizado = $entry->{atualizado};
    my $empenhado = $entry->{empenhado};
    my $liquidado = $entry->{liquidado};

    $orcado =~ s/\.//g;
    $orcado =~ s/,/\./g;

    $atualizado =~ s/\.//g;
    $atualizado =~ s/,/\./g;

    $empenhado =~ s/\.//g;
    $empenhado =~ s/,/\./g;

    $liquidado =~ s/\.//g;
    $liquidado =~ s/,/\./g;

    $values{'orcado'} = ($values{'orcado'} ? $values{'orcado'} + $orcado : $orcado);
    $values{'atualizado'} = ($values{'atualizado'} ? $values{'atualizado'} + $atualizado : $atualizado);
    $values{'empenhado'} = ($values{'empenhado'} ? $values{'empenhado'} + $empenhado : $empenhado);
    $values{'liquidado'} = ($values{'liquidado'} ? $values{'liquidado'} + $liquidado : $liquidado);
  }
  print FILE "Quantidade: " . scalar @entity_wo_location . "\n";
  print FILE "Orçado: $values{'orcado'}\n";
  print FILE "Atualizado: $values{'atualizado'}\n";
  print FILE "Empenhado: $values{'empenhado'}\n";
  print FILE "Liquidado: $values{'liquidado'}\n";
  close FILE;

  open FILE, ">", "no_entity.txt" or die $!;
  %values = ();
  foreach my $entry (@no_entity) {
    print FILE Dumper $entry;

    my $orcado = $entry->{orcado};
    my $atualizado = $entry->{atualizado};
    my $empenhado = $entry->{empenhado};
    my $liquidado = $entry->{liquidado};

    $orcado =~ s/\.//g;
    $orcado =~ s/,/\./g;

    $atualizado =~ s/\.//g;
    $atualizado =~ s/,/\./g;

    $empenhado =~ s/\.//g;
    $empenhado =~ s/,/\./g;

    $liquidado =~ s/\.//g;
    $liquidado =~ s/,/\./g;

    $values{'orcado'} = ($values{'orcado'} ? $values{'orcado'} + $orcado : $orcado);
    $values{'atualizado'} = ($values{'atualizado'} ? $values{'atualizado'} + $atualizado : $atualizado);
    $values{'empenhado'} = ($values{'empenhado'} ? $values{'empenhado'} + $empenhado : $empenhado);
    $values{'liquidado'} = ($values{'liquidado'} ? $values{'liquidado'} + $liquidado : $liquidado);
  }
  print FILE "Quantidade: " . scalar @no_entity . "\n";
  print FILE "Orçado: $values{'orcado'}\n";
  print FILE "Atualizado: $values{'atualizado'}\n";
  print FILE "Empenhado: $values{'empenhado'}\n";
  print FILE "Liquidado: $values{'liquidado'}\n";
  close FILE;
}

sub locationIsValid {
  my ($lat, $lng) = @_;
  if($lat < -23.395660 && $lat > -23.784969 && $lng < -46.364990 && $lng > -46.809319) {
    return 1;
  }
  return 0;
}
