#!/usr/bin/perl

use warnings;
use strict;
use lib "../lib";
use Getopt::Std;
use Downloader;
use DiacriticMarks;
use CSV2JSON;
use CachedGeocoder;
use JSON -support_by_pp;

$| = 1;
&main;

sub main {
  my %arguments;
  my $csvfilepath;

  # Obter o ano através da linha de comando
  getopts('fy:', \%arguments);
  usage() unless(defined $arguments{'y'});

  # Verifica se forcar download esta ativado
  if($arguments{'f'}) {
    print "Forcing download ...\n";
    $csvfilepath = download_csv($arguments{'y'});
  }

  # Verifica se o arquivo ja foi baixado pelo modo force
  unless(defined $csvfilepath) {
    print "Checking if file was previously downloaded ...\n";
    # Se o arquivo nao foi baixado pelo modo force, verifica se o arquivo ja foi baixado previamente
    $csvfilepath = "../resources/data/raw/" . $arguments{'y'} . ".csv";
    unless(-e $csvfilepath) {
      print "File was not found. Downloading $arguments{'y'}.csv ...\n";
      # Se o arquivo nao foi baixado previamente, baixe-o
      $csvfilepath = download_csv($arguments{'y'});
    } else {
      print "File was found ...\n";
    }
  }

  # Remover acentos do arquivo
  print "Stripping diacritic marks ...\n";
  my $stripped_text = strip_diacriticmarks($csvfilepath);
  $csvfilepath = "../resources/data/stripped/" . $arguments{'y'} . ".csv";
  save_data($csvfilepath, $stripped_text);

  # Converter o arquivo para formato JSON
  print "Converting $arguments{'y'}.csv to $arguments{'y'}.json ...\n";
  my $data = convert_csv($csvfilepath);

  # Salvar versão preliminar
  print "Saving file $arguments{'y'}.json\n";
  save_data("../resources/data/json/$arguments{'y'}.json", JSON->new->allow_nonref->pretty->utf8->encode($data));

  # Geocodificar entidades encontradas
  print "Geocoding entities found ...\n";
  geocode_entities($data);

  # Limpar coordenadas inválidas
  print "Cleaning up data ...\n";
  clean($data);

  # Adicionar estatisticas
  print "Statistics ...\n";
  classify($data);
  $data = statistics($data);

  # Salvar arquivo JSON
  print "Saving file $arguments{'y'}-geocoded.json\n";
  save_data("../resources/data/json/$arguments{'y'}-geocoded.json", JSON->new->allow_nonref->pretty->utf8->encode($data));
}

sub save_data {
  my $path = shift;
  my $data = shift;
  open FILE, ">", $path or die $!;
  print FILE $data;
  close FILE;
}

sub locationIsValid {
  my $location = shift;
  my $lat = $location->{lat};
  my $lng = $location->{lng};
  if($lat < -23.395660 && $lat > -23.784969 && $lng < -46.364990 && $lng > -46.809319) {
    return 1;
  }
  return 0;
}

sub format_number {
  my $number = shift;
  $number =~ s/\.//g;
  $number =~ s/,/\./g;
  return $number;
}

sub new_metadata_entry {
  my $description = shift;
  my $entry = {};
  $entry->{descricao} = $description;
  $entry->{quantidade} = 0;
  $entry->{orcado} = 0;
  $entry->{atualizado} = 0;
  $entry->{empenhado} = 0;
  $entry->{liquidado} = 0;
  return $entry;
}

sub update_metadata {
  my $entry = shift;
  my $metadata_entry = shift;
  $metadata_entry->{quantidade}++;
  $metadata_entry->{orcado} += format_number($entry->{orcado});
  $metadata_entry->{atualizado} += format_number($entry->{atualizado});
  $metadata_entry->{empenhado} += format_number($entry->{empenhado});
  $metadata_entry->{liquidado} += format_number($entry->{liquidado});
}

sub download_csv {
  my $year = shift;
  my $url = "http://sempla.prefeitura.sp.gov.br/orc_tabela_csv.php?year=2-11&sel=0_$year|1_*|2_*|3_*|4_*|5_*|6_*|7_*|8_*|9_*|10_*";
  my $filepath = "../resources/data/raw/" . $year . ".csv";
  my $downloader = new Downloader($url, $filepath);
  $downloader->download;
  return $filepath;
}

sub strip_diacriticmarks {
  my $filepath = shift;
  my $dc = DiacriticMarks->new;
  my $stripped_text = $dc->strip_file($filepath);
  return $stripped_text;
}

sub convert_csv {
  my $csvfile = shift;
  my $csv2json = CSV2JSON->new($csvfile);
  my $json_text = $csv2json->convert;
  my $data = JSON->new->allow_nonref->utf8->decode($json_text);
  return $data;
}

sub geocode_entities {
  my $data = shift;
  my $geocoder = CachedGeocoder->new;
  my $json = new JSON;
  my $current = 0;
  my $total = scalar @{$data};

  for my $entry (@{$data}) {
    $current++;
    print "\r$current of $total.";
    my $entities = $entry->{entidades};
    my $coordinates = {};
    for my $tag (keys %{$entities}) {
      my @coordinates_of_tag = ();
      my $tag_entities = $entities->{$tag};
      for my $entity (@{$tag_entities}) {
	my $response = $geocoder->geocode($entity);
	my $response_data = $json->decode($response);
	next if($response_data->{status} eq "ZERO_RESULTS");
	die "$entity: Over Query Limit" if($response_data->{status} eq "OVER_QUERY_LIMIT");
	my @entity_coordinates = ();
	for my $result (@{$response_data->{results}}) {
	  my $location = $result->{geometry}->{location};
	  push(@entity_coordinates, $location);
	}
	my $coordinates_data = {};
	$coordinates_data->{entidade} = $entity;
	$coordinates_data->{localizacoes} = \@entity_coordinates;
	push(@coordinates_of_tag, $coordinates_data);
      }
      $coordinates->{$tag} = \@coordinates_of_tag;
    }
    $entry->{coordenadas} = $coordinates;
  }
  print "\n";
}

sub clean {
  my $data = shift;
  for my $entry (@{$data}) {
    my $coordinates = $entry->{coordenadas};
    for my $tag (keys %{$coordinates}) {
      my $entities = $coordinates->{$tag};
      my @valid_entities = ();
      for my $entity (@{$entities}) {
	my $locations = $entity->{localizacoes};
	my @valid_locations = ();

	for my $location (@{$locations}) {
	  if(locationIsValid($location)) {
	    push(@valid_locations, $location);
	  }
	}
	if(scalar @valid_locations) {
	  $entity->{localizacoes} = \@valid_locations;
	  push(@valid_entities, $entity);
	}
      }
      if(scalar @valid_entities) {
	$coordinates->{$tag} = \@valid_entities;
      } else {
	delete($coordinates->{$tag});
      }
    }
  }
}

sub classify {
  my $data = shift;
  for my $entry (@{$data}) {
    my $entities = $entry->{entidades};
    unless(scalar keys %{$entities}) {
      $entry->{tipo} = 1;
    } else {
      my $coordinates = $entry->{coordenadas};
      if(scalar keys %{$coordinates} == 0) {
	$entry->{tipo} = 2;
      } elsif(scalar keys %{$coordinates} == 1) {
	for my $tag (keys %{$coordinates}) {
	  my $tag_array = $coordinates->{$tag};
	  if(scalar @{$tag_array} == 1) {
	    $entry->{tipo} = 3;
	  } else {
	    $entry->{tipo} = 4;
	  }
	}
      } else {
	$entry->{tipo} = 4;
      }
    }
  }
}

sub statistics {
  my $data = shift;
  my $metadata = {};
  $metadata->{tipo_1} = new_metadata_entry("Entradas sem entidades identificadas");
  $metadata->{tipo_2} = new_metadata_entry("Entradas com entidades identificadas, sem coordenadas");
  $metadata->{tipo_3} = new_metadata_entry("Entradas com entidades identificadas, unica coordenada");
  $metadata->{tipo_4} = new_metadata_entry("Entradas com entidades identificadas, multiplas coordenadas");

  for my $entry (@{$data}) {
    my $type = $entry->{tipo};
    if($type == 1) {
      update_metadata($entry, $metadata->{tipo_1});
    } elsif($type == 2) {
      update_metadata($entry, $metadata->{tipo_2});
    } elsif($type == 3) {
      update_metadata($entry, $metadata->{tipo_3});
    } elsif($type == 4) {
      update_metadata($entry, $metadata->{tipo_4});
    }
  }

  my $new_json = {};
  $new_json->{metadata} = $metadata;
  $new_json->{data} = $data;
  return $new_json;
}

sub usage {
  print "Usage: perl main.pl [-f] [-y YEAR]\n";
  exit;
}