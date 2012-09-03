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

# Fetches and stores a file from a given URL.

#!/usr/bin/perl

package Downloader;
use WWW::Mechanize;

sub new {
  my $class = shift;
  my $self = {
    _url => shift,
    _filepath => shift
  };

  bless $self, $class;
  return $self;
}

sub download {
  my $self = shift;
  my $url = shift || $self->{_url} || die "No URL provided.";

  my $mech = WWW::Mechanize->new();
  $mech->agent_alias('Windows Mozilla');
  $mech->get($self->{_url});
  $mech->success() or die "Couldn't get '$self->{_url}'. Download failed.";

  my $content = $mech->content;
  if(defined($self->{_filepath})) {
    open FILE, ">", $self->{_filepath} or die $!;
    print FILE $content;
    close FILE;
  }

  return $content;
}

1;
