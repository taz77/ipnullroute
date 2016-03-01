#!/usr/bin/perl -w

### Name:	 filtermaker.pl
### Author:	 Richard J. Hicks (richard.hicks@gmail.com)
### Date:	 2010-06-25 (Modified: 2013-06-10)
### Description: This program downloads raw data from SPAMHAUS, CYMRU, OKEAN,
###              and builds Cisco friendly null routes.


use strict;
use Switch;
### use feature qw/switch/;
use LWP;
use LWP::Simple;
use Getopt::Std;
use POSIX qw(strftime);
use Data::Dumper;

my $currentDate = strftime "%Y-%m-%d", localtime;
my $opt = 'abc';
my %opt;
getopts( $opt, \%opt );
my $ua = LWP::UserAgent->new;
my $agent = "my-lwp agent";
$ua->agent($agent);

### VARIABLES ###
my $spamhausURL  = "http://www.spamhaus.org/drop/drop.txt";
my $spamhausDesc = "SPAMHAUS-DROP-LIST_$currentDate";
my $cymruURL     = "http://www.team-cymru.org/Services/Bogons/bogon-bn-nonagg.txt";
my $cymruDesc    = "CYMRU-BOGON-LIST_$currentDate";
my $okeanURL     = "http://www.okean.com/chinacidr.txt";
my $okeanDesc    = "OKEAN-CHINA-LIST_$currentDate";
my $ipTableURL   = "http://www.ipdeny.com/ipblocks/data/aggregated/";

#ao-aggregated.zone
#################

# &printHelp unless ($opt{a} or $opt{b} or $opt{c});
if ($opt{a})
        {
                my $req = HTTP::Request->new(GET => $spamhausURL);
                $req->content_type('text/html');
                $req->protocol('HTTP/1.0');
                my $response = $ua->request($req);
                printRoutes(Dumper($response), $spamhausDesc);
        }
if ($opt{b}) { printRoutes(get($cymruURL), $cymruDesc); }
if ($opt{c}) { printRoutes(get($okeanURL), $okeanDesc); }







sub printHelp
{
        print "\n!!! USE THIS SCRIPT AT YOUR OWN RISK !!!\n";

	print "\nThis Perl script creates null routes that can be installed on Cisco routers.\n";
	print "When used in conjuction with uRPF, these filters provide an additional layer of SPAM, BOGON, and China filtering.\n";
	print "Cisco uRPF Info: http://www.cisco.com/web/about/security/intelligence/unicast-rpf.html\n";

        print "\nusage: $0 -a -b -c\n";
	print "Options:\n";
	print " -a  : Spamhaus DROP list data\n";
	print " -b  : CYMRU Bogons list data\n";
	print " -c  : OKEAN China Networks list\n";
	exit 1;
}




sub printRoutes
{
        if (!$_[0])
        {
                print "\nUnable to retrieve date from URL!\n";
                print "Please check the ### VARIABLES ### section of this script.\n";
        }
        else
        {
        	my @values = split(/\s/, $_[0]);
        	foreach my $val (@values)
        	{
        		if ($val =~ /^([\d]+)\.([\d]+)\.([\d]+)\.([\d]+)/)
        		{
        			print "ip add route blackhole " . $val . "\n";
        		}
        	}
        }
}
