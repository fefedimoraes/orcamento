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
use JSON -support_by_pp;

&main;

#Campos do registro:
#Orgao;Unidade;Funcao;Subfuncao;Programa;Projeto/Atividade;Orcado;Atualizado;Empenhado;Liquidado;Mapeado

sub main {
	my $path = $ARGV[0];
	my $jsonloader = new JSONLoader;
	my $data = $jsonloader->load($path);
	
	my $hash = {};
	
	for my $json_entry (@{$data->{data}}) {
		my $key = $json_entry->{orgao};
		my $csv_entry = get_csv_entry($json_entry);
		
		if($hash->{$key}) {
			my $array = $hash->{$key};
			push(@$array, $csv_entry);
		} else {
			my $array = [];
			push(@$array, $csv_entry);
			$hash->{$key} = $array;
		}
	}
	
	my $file = JSON->new->allow_nonref->pretty->canonical->utf8->encode($hash);
	print $file;
}

sub get_csv_entry {
	my $json_entry = shift;
	my $csv_entry = $json_entry->{orgao} . ';' . $json_entry->{unidade} . ';' . $json_entry->{funcao} . ';' . $json_entry->{subfuncao} . ';' . 
									$json_entry->{programa} . ';' . $json_entry->{descricao} . ';' . $json_entry->{orcado} . ';' . $json_entry->{atualizado} . ';' . 
									$json_entry->{empenhado} . ';' . $json_entry->{liquidado} . ';' . 
									((scalar(keys(%{$json_entry->{coordenadas}})) == 0) ? 'nao' : 'sim');
	return $csv_entry;
}
