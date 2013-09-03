#################################
# Module: LX::Easycrawl         #
# Version: V1.00                #
# Author: Aseel Akhtar Noor     #
# Copyright (c): 2012 PSS-Noida #
#################################
package LX::Easycrawl;
$VERSION = "1.00";
use 5.005;
use strict;
use warnings;

sub new
{
	my $class=shift;
	my $self = {};
	bless $self, $class;
    return $self;
}


sub getPage
{
	my $self= shift;
	my ($url, $headerFname, $cookFile, $cookRS) = @_; 
	my $curlStr = qq{curl  --compressed -A 'Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)' }; 
	$url =~ /^\s+|\s+$/g; 
	if($headerFname){ 
		if($cookRS eq "S"){ 
			$curlStr .= qq{-k -L -c $cookFile -D '$headerFname' }; 
		}else{ 
			$curlStr .= qq{-k -L -b $cookFile -c $cookFile -D '$headerFname' }; 
		} 
	} 
	$curlStr.= qq{'$url'};
	return `$curlStr`;
}


sub postPage
{
	my $self= shift;
	my ($url, $content, $headerFname, $cookFile,$cookRS) = @_;
	my $curlStr = qq{curl  --compressed -A 'Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)' }; 
	$url =~ /^\s+|\s+$/g; 
	if($headerFname){ 
		if($cookRS eq "S"){ 
			$curlStr .= qq{-k -L -z 10 -c $cookFile -D '$headerFname' }; 
		}else{ 
			$curlStr .= qq{-k -L -z 10 -b $cookFile -c $cookFile -D '$headerFname' }; 
		} 
	} 
	if($content){ 
		$curlStr .= qq{-d '$content' }; 
	}
	$curlStr.= qq{'$url'};
	return `$curlStr`;
}

#################Read Function#####################
sub readFile
{
	my $self= shift;
	my ($myFile)=@_;
	my $return;
	open(FILE1,$myFile) or die "Can't read file $myFile [$!]\n";  
	while(<FILE1>){
		$return.= $_;
	}
	close (FILE1);
	return $return;
}

#################Write Function#####################
sub writeFile
{
	my $self=shift;
    my ($fileName,$content)=@_;
	open OUT, ">:utf8", $fileName or die "Cannot open $fileName for write :$!";
	print OUT "$content";
	close OUT;
}

#################Write Function#####################
sub appendFile
{
	my $self=shift;
    my ($fileName,$content)=@_;
	open OUT, ">>", $fileName or die "Cannot open $fileName for write :$!";
    print OUT "$content";
    close OUT;
}

#################GET-Time Function#####################
sub mytime
{
	my @mytime = localtime();
	$mytime[4]=$mytime[4]+1;
	for(my $i=0;$i<$#mytime;$i++){
		if(length($mytime[$i]) eq 1){$mytime[$i]="0".$mytime[$i];}
	}
	$mytime[5] = 1900 + $mytime[5];
	my $time = "$mytime[5]-$mytime[4]-$mytime[3] $mytime[2]:$mytime[1]:$mytime[0]";
	return $time;
}

#################Parse Form Function###################
sub parseFormData
{
	my $self=shift;
	my ($resultFile,$formData)=@_;
	my $nm;
	while($resultFile=~/<(select|input)/is)
	{
		my $tempFile;
		$resultFile=$';
		$tempFile=$';
		if($1 eq "Input" or $1 eq "input" or $1 eq "INPUT")
		{
			$tempFile=~/(.+?>)/is;
			$tempFile=$1;
			if(!(($tempFile=~/type\W+button/i) or ($tempFile=~/type\W+image/i)))
			{
				if($tempFile=~/\bname\W+(.*?["'])/is){
					$nm=$1;
					$nm=~s/\W\z//i;
					if(!(($tempFile=~/type\W+radio/i) or ($tempFile=~/type\W+checkbox/i))) 
					{
						if($tempFile=~/value.*?["'](.*?["'])/i)
						{
							$tempFile=$1;
							$tempFile=~s/\W\z//i;
						}
						elsif($tempFile=~/value\s*=(.+?[\s|>])/i)
						{
							$tempFile=$1;
							$tempFile=~s/\W\z//i;
						}
						else
						{
							$tempFile="";
						}
						if(exists($$formData{$nm}))
						{
							$$formData{$nm}=$$formData{$nm}."&".$nm."=".$tempFile;
						}
						else
						{
							$$formData{$nm}=$tempFile;
						}
					}
					elsif($tempFile=~/type\W+checkbox/i and $tempFile=~/checked/i)
					{
						$$formData{$nm}="1";
					}
					elsif($tempFile=~/type\W+checkbox/i)
					{
						$$formData{$nm}=""; 
					}
				}
			}
		}
		elsif($1 eq "Select" or $1 eq "select" or $1 eq "SELECT") 
		{ 
			$tempFile=~/(.+?>)/is;
			$tempFile=$1;
			if($tempFile=~/name\W+(.*?["'|>])/is)
			{ 
				$nm=$1;
				$nm=~s/\W\z//i;
				$resultFile=~/<\/select/is; 
				$resultFile=$';
				$tempFile=$`."</select";
				if($tempFile=~/.*(<option.*selected.*?>)/is)
				{
					$tempFile=$1;
					if($tempFile=~/value="(.*?")/i)
					{
						$tempFile=$1;
						$tempFile=~s/\W\z//i;
					}
					elsif($tempFile=~/value='(.*?')/i)
					{
						$tempFile=$1;
						$tempFile=~s/\W\z//i;
					}
					elsif($tempFile=~/value=(.+?[\s|>])/i)
					{
						$tempFile=$1;
						$tempFile=~s/\W\z//i;
					}
					else
					{
						$tempFile="";
					}
				}
				elsif($tempFile=~/(<option.*?>)/is)
				{
					$tempFile=$1;
					if($tempFile=~/value="(.*?")/i)
					{
						$tempFile=$1;
						$tempFile=~s/\W\z//i;
					}
					elsif($tempFile=~/value='(.*?')/i)
					{
						$tempFile=$1;
						$tempFile=~s/\W\z//i;
					}
					elsif($tempFile=~/value=(.+?[\s|>])/i)
					{
						$tempFile=$1;
						$tempFile=~s/\W\z//i;
					}
					else
					{
						$tempFile="";
					}
				}
				else
				{
					$tempFile="";
				}
				$$formData{$nm}=$tempFile;
			}
		}
		$nm = ""; 
	}
}
1;