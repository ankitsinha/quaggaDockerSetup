###
#
# @author : Ankit Kumar Sinha
# This script creates docker network based on config file given
#
###

use strict;
use warnings;
my $arg = $ARGV[0];
my $givenPath = $ARGV[1];
my $filename = 'config';
my $doClone = 0;
my $numDockers = 0;
my $dockerCreated = 0;
my $userName =  $ENV{'LOGNAME'};
my $clonePath = "\/users\/$userName";
my $i = 0;
my $br = 0;
open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";
if ($arg eq "clean")
{
   print "Not implemented...\n";
}
elsif ($arg eq "make")
{
  while (my $row = <$fh>) 
  {
    chomp $row;
    my @fields = split(/:/, $row);
    if (($fields[0] eq "CLONE") and ($fields[1] eq "yes"))
    {
       $doClone = 1;
       if(-e $givenPath and -d $givenPath)
       {
          print "Cloning to $givenPath...\n";
          chdir $givenPath; 
       }
       else
       {
          print "Cloning to $clonePath...\n";
          chdir $clonePath;
       }
       my $return = `git clone http://git.savannah.gnu.org/cgit/quagga.git`;
       sleep(5);
    }
    elsif (($fields[0] eq "DOCKERS") and ($fields[1] > 0))
    {
       $numDockers = $fields[1];
       printf "Creating $numDockers docker containers...\n";
    }
    if (($numDockers > 0) and ($dockerCreated))
    {
       my $size = @fields;
       print "Setting up bridge ...\n";
       for($i = 0; $i < $size; $i=$i+3)
       {
          print "br$br : $fields[$i]:$fields[$i+1]:$fields[$i+2]\n";
          my $return = `sudo pipework br$br -i $fields[$i+1] $fields[$i] $fields[$i+2]`;
       }
       printf "\n";
       $br++;
    }
    if (($numDockers > 0) and !$dockerCreated)
    {
       for(my $numDock = 1; $numDock <= $numDockers; $numDock++)
       {
          my $cmd = "docker run --privileged -v $clonePath/quagga/:/quagga --name R$numDock ankitsinha19/buildenv /sbin/my_init";
          system "$cmd &";
          sleep(5);
          print "Docker created R$numDock\n";
       }
       $dockerCreated = 1;
    }
  }
}
