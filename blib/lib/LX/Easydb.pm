#################################
# Module: LX::Easydb            #
# Version: V1.00                #
# Author: Aseel Akhtar Noor     #
# Copyright (c): 2012 PSS-Noida #
#################################
package LX::Easydb;
$VERSION = "1.00";
use 5.005;
use strict;
use warnings;
use DBI;
use Data::Dumper;
my $DBIconnect;

sub new
{
	my $class=shift;
	my %args = @_;
	my $dsn = 'dbi:mysql:'.$args{'dbname'}.':'.$args{'dbhost'}.':'.$args{'dbport'};
	$DBIconnect = DBI->connect($dsn, $args{'dbuser'}, $args{'dbpass'});
	my $self = {};
	bless $self, $class;
    return $self;
}

######################## SELECT Function #############################
sub Select
{
	my $self=shift;
	my ($tableName, $condition,$dataHash)=@_;
	my $query="SELECT * from ".$tableName." ".$condition;
	my $sql=$DBIconnect->prepare($query) or die "Can't prepare $query: $DBIconnect->errstr\n";
	my $count=$sql->execute or die "can't execute the query: $sql->errstr";
	my $dataHash1 = $sql->fetchrow_hashref();
	foreach my $key (keys $dataHash1) {
		my $value=$dataHash1->{$key};
		$dataHash->{$key}=$value;
    }
	$sql->finish;
}

######################## SELECT Function #############################
sub Check
{
	my $self=shift;
	my ($tableName, $condition)=@_;
	my $query="SELECT * from ".$tableName." ".$condition;
	my $sql=$DBIconnect->prepare($query) or die "Can't prepare $query: $DBIconnect->errstr\n";
	my $count=$sql->execute or die "can't execute the query: $sql->errstr";
	$sql->finish;
	if($count<1){$count=0;}
	return $count;
}

######################## SELECTALL Function #############################
sub SelectAll
{
	my $self=shift;
	my ($tableName,$dataHash)=@_;
	my $query="SELECT * from ".$tableName;
	my $sql=$DBIconnect->prepare($query) or die "Can't prepare $query: $DBIconnect->errstr\n";
	$sql->execute or die "can't execute the query: $sql->errstr";
	my $count=0;
	while (my $dataHash1 = $sql->fetchrow_hashref()){
		my $dataHash2;
		foreach my $key (keys $dataHash1) {
			my $value=$dataHash1->{$key};
			$dataHash2->{$key}=$value;
		}
		$dataHash->{$count}=$dataHash2;
		$count++;
	}
	$sql->finish;
}

######################## INSERT Function #############################
sub Insert
{
	my $self= shift;
	my ($tableName, $dataHash)=@_;
	my $value='';
	my $name='';
	my $key;
	foreach $key (keys $dataHash) {
		$name.= "`".$key."`,";
		$value.= "'".$dataHash->{$key}."',";
    }
	$name=~s/,$//isg;
	$value=~s/,$//isg;	
	my $query = "INSERT into $tableName ($name) value($value)";
	my $sql  = $DBIconnect->prepare($query) or die "Can't prepare $query: $DBIconnect->errstr\n";
	my $return = $sql->execute or die "can't execute the query: $sql->errstr";
	$sql->finish;
	return $return;
}

######################## UPDATE Function #############################
sub Update
{
	my $self= shift;
	my ($tableName, $dataHash,$condition)=@_;
	my $dataset='';
	foreach my $key (keys $dataHash) {
		$dataset.= $key."='".$dataHash->{$key}."',";
    }
	$dataset=~s/,$//isg;
	my $query = "Update ".$tableName." set ".$dataset." ".$condition;
	my $sql  = $DBIconnect->prepare($query) or die "Can't prepare $query: $DBIconnect->errstr\n";
	my $return = $sql->execute or die "can't execute the query: $sql->errstr";
	$sql->finish;
	return $return;
}

######################## Delete Function #############################
sub Delete
{
	my $self= shift;
	my ($tableName, $condition)=@_;
	my $query = "DELETE from ".$tableName." ".$condition;
	my $sql  = $DBIconnect->prepare($query) or die "Can't prepare $query: $DBIconnect->errstr\n";
	my $return = $sql->execute or die "can't execute the query: $sql->errstr";
	$sql->finish;
	return $return;
}

1;