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

package JSONLoader;
use JSON -support_by_pp;

sub new {
  my $class = shift;
  my $self = {
    _path => shift
  };

  bless $self, $class;
  return $self;
}

sub load {
  my $self = shift;
  my $filepath = $self->{_path} || shift || die "No path provided.";

  open FILE, "<", $filepath or die $!;
  my $filecontent = do { local $/; <FILE> };
  close FILE;

  my $json = new JSON;
  my $data = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($filecontent);
  return $data;
}

1;
