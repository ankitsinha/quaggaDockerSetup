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
my $clonePath = "\/ws\/$userName";
my $i = 0;
my $br = 0;
open(my $fh, '<:encoding(UTF-8)', $filename)
  or die "Could not open file '$filename' $!";
if ($arg eq "clean")
{
   while (my $row = <$fh>)
   {
      chomp $row;
      my @fields = split(/:/, $row);
      if (($fields[0] eq "DOCKERS") and ($fields[1] > 0))
      {
         print "Removing $fields[1] docker containers...\n";
         for(my $i=1; $i<=$fields[1] ;$i++)
         {
            my $cmd = "docker rm -f R$i";
            system "$cmd";
            print "Removed R$i.\n";
         }
      }
   }
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
          $clonePath = $givenPath;
          chdir $clonePath; 
       }
       else
       {
          print "Cloning to $clonePath...\n";
          chdir $clonePath;
       }
       my $cmd = "git clone http://git.savannah.gnu.org/cgit/quagga.git";
       system "$cmd";
       sleep(5);
    }
    elsif (($fields[0] eq "DOCKERS") and ($fields[1] > 0))
    {
       $numDockers = $fields[1];
    }
    if (($numDockers > 0) and ($dockerCreated))
    {
       my $size = @fields;
       print "Setting up bridge ...\n";
       for($i = 0; $i < $size; $i=$i+3)
       {
          print "br$br : $fields[$i]:$fields[$i+1]:$fields[$i+2]\n";
          my $cmd = "sudo ./pipework br$br -i $fields[$i+1] $fields[$i] $fields[$i+2]";
          system "$cmd";
       }
       printf "\n";
       $br++;
    }
    if (($numDockers > 0) and !$dockerCreated)
    {
       print "Pulling ankitsinha19/buildenv:latest docker image...\n";
       my $cmd = "docker pull ankitsinha19/buildenv";
       system "$cmd";
  
       print "Creating $numDockers docker containers...\n";
       for(my $numDock = 1; $numDock <= $numDockers; $numDock++)
       {
          my $cmd = "docker run --privileged -v $clonePath/quagga/:$clonePath/quagga --name R$numDock ankitsinha19/buildenv /sbin/my_init";
          system "$cmd &";
          sleep(5);
          print "Docker created R$numDock\n";
       }
       $dockerCreated = 1;
    }
  }
}
