#!/usr/bin/perl

use strict;
use warnings;
use lib "../lib";
use JSONLoader;
use Data::Dumper;

&main;

sub main {
  my $path = $ARGV[0];

  my $jsonloader = JSONLoader->new;
  my $data = $jsonloader->load($path);
  count($data);
}

sub count {
  my $json = shift;
  my %mapeavel = ();
  my %naomapeavel = ();

  $mapeavel{'count'} = 0;
  $mapeavel{'orcado'} = 0;
  $mapeavel{'atualizado'} = 0;
  $mapeavel{'empenhado'} = 0;
  $mapeavel{'liquidado'} = 0;

  $naomapeavel{'count'} = 0;
  $naomapeavel{'orcado'} = 0;
  $naomapeavel{'atualizado'} = 0;
  $naomapeavel{'empenhado'} = 0;
  $naomapeavel{'liquidado'} = 0;

  foreach my $activity (@{$json->{projeto_atividade}}) {
    my @entities = @{$activity->{entidades_referenciaveis}};
    my $orcado = $activity->{orcado};
    my $atualizado = $activity->{atualizado};
    my $empenhado = $activity->{empenhado};
    my $liquidado = $activity->{liquidado};

    $orcado =~ s/\.//g;
    $orcado =~ s/,/\./g;

    $atualizado =~ s/\.//g;
    $atualizado =~ s/,/\./g;

    $empenhado =~ s/\.//g;
    $empenhado =~ s/,/\./g;

    $liquidado =~ s/\.//g;
    $liquidado =~ s/,/\./g;

    if(scalar(@entities) == 0) {
      $naomapeavel{'count'} = $naomapeavel{'count'} + 1;
      $naomapeavel{'orcado'} = $naomapeavel{'orcado'} + $orcado;
      $naomapeavel{'atualizado'} = $naomapeavel{'atualizado'} + $atualizado;
      $naomapeavel{'empenhado'} = $naomapeavel{'empenhado'} + $empenhado;
      $naomapeavel{'liquidado'} = $naomapeavel{'liquidado'} + $liquidado;
    } else {
      $mapeavel{'count'} = $mapeavel{'count'} + 1;
      $mapeavel{'orcado'} = $mapeavel{'orcado'} + $orcado;
      $mapeavel{'atualizado'} = $mapeavel{'atualizado'} + $atualizado;
      $mapeavel{'empenhado'} = $mapeavel{'empenhado'} + $empenhado;
      $mapeavel{'liquidado'} = $mapeavel{'liquidado'} + $liquidado;
    }
  }

  print "Mapeável\n";
  for (keys %mapeavel) {
    print "$_: $mapeavel{$_}\n";
  }
  print "\nNão Mapeável\n";
  for (keys %naomapeavel) {
    print "$_: $naomapeavel{$_}\n";
  }
}