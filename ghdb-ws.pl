#!/usr/bin/perl -w
#
# GHWS
# Google Hacking Web Scraper is a Perl script that imports 
# Dorks search terms from exploit-db and saves them to a file.
#
# If you have problems using LWP::UserAgent with a SOCKS Proxy
# you more that likely need to install the LWP::Protocol::socks
# module
#
# License: BSD-2 
#					      by xor-function


use strict;
use LWP::UserAgent;
use HTML::LinkExtor;
use HTML::Selector::XPath;
use HTML::TreeBuilder::XPath;


##################################################################################
#
# This Script can be easily modified to crawl other websites.
#
# To do this just create and load a URL array with other domains you 
# wish to crawl and change the manner the html_source is parsed 
# and used.
#
# 
# do not run this with more than one URL un-commented at the same time.
#

my $site;

#----------------=[ Vulnerable servers 
# $site = "https://www.exploit-db.com/google-hacking-database/6/";

#----------------=[ Sensitive directories
# $site, "https://www.exploit-db.com/google-hacking-database/3/";

#----------------=[ Vulnerable Files
# $site, "https://www.exploit-db.com/google-hacking-database/5/";

#----------------=[ Files containing juicy info
# $site, "https://www.exploit-db.com/google-hacking-database/8/";

#----------------=[ Various online devices
# $site = "https://www.exploit-db.com/google-hacking-database/13/";



##################################################################################




#---------------------=[ main 


    banner();

    if( !defined($site)) { 
        die "\n[!] You need to activate a URL, see README.\n\n";
    }

    # The name of the output log file  
    my $filename = 'results'; 

    print "\n[!] Initating scrape of $site\n";

    getlinktxt(harvest_urls($site));

    print "\n[!] Done with $site\n";


#----=[ End of main 



sub banner {


	my $info = <<EOF;

	GHDB-WS

	GHDB Web Scraper is a Perl script that scrapes Google Dork 
	search terms from a single expliot-db web page and saves 
	them to a file named "results".

	For more info see the README.md

	This script will wait a minute between each page request 
	in order to prevent any abuse of server resources.

	So if it's slow, know that it's a feature and leave the 
	code responsible for this as it is.

	xor-function eq null
	\@nighowlconsulting.com

EOF

	print "$info\n";

} 


# Sub fetches html source of the specified website URL for parsing.
# constructor in subroutine for LWP::UserAgent that sets up a custom user agent 
# and enables the use of a socks proxy on local host, made to work with TOR.
#
# ex getdata($url)

sub getdata {

        # I M P O R T A N T #
	sleep(60);

	my $urlnk = $_[0];

        my $ua = LWP::UserAgent->new( agent => q{GHDB-WS/0.1});
        # $ua->proxy( [qw/ http https /] => 'socks://localhost:8080');
        $ua->timeout( 20 );
        $ua->max_redirect(5);

        my $get = $ua->get($urlnk);
        my $warning = $get->headers->header('Client-Warning');

        if ( $get->is_success ) {
            print "\n[*] dumping html source from link...";
        }
         elsif ( $warning eq 'Internal response') {
                    print "\n client side error:" .  $get->status_line;
        } else { print "\n server error:" . $get->status_line; }

        my $html_src = $get->decoded_content;

	return $html_src;


}



# Subroutine for Link Extraction.
#
# Subroutine requires an array of URLs to be tested against a Base URL
# this is to insure that any external domains detected are dropped from processing.
#
# additionally any links that are found to belong to target domain are then checked
# for links to downloadable media, which if they are are also ignored. 
#
# Returns an array that has been filtered with the specified parameters

sub exlinks { 

	my $parse   = $_[0];
	my $fullurl = $_[1];


	# Recommended regex from perl URI module to decode a full URL

        my($scheme, $authority, $path, $query, $fragment) =
                $fullurl =~ m|(?:([^:/?#]+):)?(?://([^/?#]*))?([^?#]*)(?:\?([^#]*))?(?:#(.*))?|;
        my $baseurl = $scheme . '://' . $authority;
	

        #   For HTML::LinkExtor the links are stored in $p->links 
        #   as you can see above the links were loaded into the array @urls
        #     
        #   The values set by the module uses anonymous arrays[ $url->[0||1||2] ],
	#   select the one that contains the data your after.
        #
        #   example : [$tag, $attr => $url1, $attr2 => $url2,...]


        my $p = HTML::LinkExtor->new(undef);
                   $p->parse($parse);
                   $p->eof;
        my @urls = $p->links;

	# For generic crawling create a log of excluded links for evaluation. 
	# init new array
	my @rmedia;
        foreach my $url (@urls) {
           if ( $url->[1] eq 'href' ) {
                if ( $url->[2] =~ /(jpg|png|css|mp4|avi|flv|pdf|doc|exe|xml|msi|tar|gz|tgz|bz2)/igm ) {
                        next;
                }
                else
                 {
                     if ( $url->[2] =~ /$baseurl/ ) {
                               # print $url->[2] . "\n";
	                       push(@rmedia, $url->[2]);
                     }
                 }
           }  else { next; }

        }


	# The following code block can be removed since it only applies to the website in question.
	# if you want to use this as a base for a generic crawler change the regex to common
	# directories "link paths" you wouldn't want your bot crawling.

	# init final new array
	my @chkd;
	foreach my $chk (@rmedia) {

		if ( $chk =~ /\/ghdb\// ) { push(@chkd, $chk); }
		  else { next; }

	}

	return @chkd;

}


# Requires name to specify name of log created.
# Requires an array of URLs in order to visit each then parse out
# link text associated with '<title> </title>' then saves any 
# results found to disk. 
#
# example getlinktxt(\@urlarray, $filename);
#
# For best result make sure the supplied array has already passed
# filters to insure only desired URLs are present.

sub getlinktxt {

	
	my @totalurls = @_;

	my $log = 'results';

        foreach my $turl (@totalurls) {


                my $tree = HTML::TreeBuilder::XPath->new;
                $tree->ignore_unknown(0);
                $tree->parse(getdata($turl));
                $tree->eof;

                my $sel = HTML::Selector::XPath->new('title');
                my $xpath = $sel->to_xpath;
                my @nodes = $tree->findnodes($xpath);


                my @links;
                foreach my $node (@nodes) {

                        push (@links, $node->as_text);

                }

                foreach my $link (@links) {


			# Only save <title> that match the regex but also delete the matching string before
			# writing the selected title to disk. 

			if ( $link =~ /\- Exploits Database/ ) {

                		$link =~ s/\- Exploits Database$//s;

                		open(my $fh, '+>>', "$log" ) or die "Could not open file $!";
               			print $fh "\n$link";
                		close $fh;


			} else { next; }

 
                }       



	}


}


# Once seed URLS are obtained by initial URL and provided to this sub routine
# as an array it fetches more html source by listing each link in the array and
# appending all html source for parsing. 
# 
# Example crawl(@array_of_links);  

sub crawl {

	my $allsrc;
        foreach (@_) {
		
        	$allsrc .= getdata($_);
        }
	
	return $allsrc;

} 

# Filter array for uniqueness, requires array variable as parameter.
# Insures no URLS are visited more that once.

sub filter_url {

	my %seen;
	$seen{$_}++ for @_;

	return keys %seen;

}


# Requires URL of website to be crawled
# performs thorough scanning to 

sub harvest_urls {  


	my $query = $_[0];
	
        my @baseurls = exlinks(getdata($query), $query);
	my @init_urls = filter_url(@baseurls);

	print "\n[!] URLs found.";
	foreach (@init_urls) { print "\n $_";  }

	return @init_urls;


}

