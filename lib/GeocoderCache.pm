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

# Store geocoder results in a local cache (sqlite database)

#!/usr/bin/perl

package GeocoderCache;
use DBI;

sub new {
  my $class = shift;
  my $self = {};

  my $dbh = DBI->connect("dbi:SQLite:dbname=../resources/cache.db","","", { RaiseError => 1 }) or die $DBI::errstr;
  $dbh->do("CREATE TABLE IF NOT EXISTS cache(id INTEGER PRIMARY KEY AUTOINCREMENT, request TEXT, response TEXT)");
  $self->{_dbh} = $dbh;

  bless $self, $class;
  return $self;
}

sub insert {
  my $self = shift;
  my $request = shift;
  my $response = shift;
  my $dbh = $self->{_dbh};

  my $sql = "INSERT INTO cache(request, response) VALUES(?, ?)";
  my $sth = $dbh->prepare($sql);
  $sth->execute($request, $response);
}

sub select {
  my $self = shift;
  my $request = shift;
  my $dbh = $self->{_dbh};

  my $sql = "SELECT * FROM cache WHERE request = ?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($request);
  my $arrayref = $sth->fetchall_arrayref;
  return $arrayref;
}

sub select_all {
  my $self = shift;
  my $dbh = $self->{_dbh};

  my $sql = "SELECT * FROM cache";
  my $sth = $dbh->prepare($sql);
  $sth->execute();
  my $arrayref = $sth->fetchall_arrayref;
  return $arrayref;
}

sub DESTROY {
  my $self = shift;
  $self->{_dbh}->disconnect;
}

1;
