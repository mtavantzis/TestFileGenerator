#!/usr/bin/perl
use strict;
use warnings;
use POSIX;
use JSON;
my %csds;
my %n2ip;
my $halog;
my $phy = "/install/testdata/test.json";
open(PH, '<:encoding(UTF-8)', $phy);
my $count = 0;
while(<PH>)
{
        chomp;
        my $line = $_;
        $line =~ s/\r//g;

#        if(index($line,"Subject:" > -1))
 #       {
#            $line = readline(PH);
#            $line =~ s/\r//g;
  #         print "-------------------------------------$count-----------------------------------------\n";
   #        open(OUT1, '>', $count . "_email.txt");
    #       while(index($line,"Message-ID: <") == -1)
     #      {


      #          if((index($line,"X-") == -1) && (index($line,"Mime-Version") == -1) && (index($line,"Content-") == -1)&& (index($line,":") == -1) && (index($line,"<") == -1) && (index($line,"(") == -1)&& (index($line,"@") == -1)&& (index($line,"=") == -1))
       #         {
                    print "$line\n";
        #            print OUT1 "$line";
                }

         #       $line = readline(PH);
          #      $line =~ s/\r//g;
           #     $count++;
                
           # }
           # close(OUT1);

            
#        }
}

close(PH);
