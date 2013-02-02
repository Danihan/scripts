#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use URI::Escape;


if(($#ARGV < 0) || ($ARGV[0] eq "")){
  print "$0: Usage: Enter a search string in quotes.\n";
  exit 1;
}

my $query = $ARGV[0];
$query =~ s/ /+/g;
my $url = "http://www.google.com/search?q=".$query;

sub pull_page{
    my $ua = new LWP::UserAgent(agent => 'Mozilla/5.0 (Windows; U;
                                          Windows NT 5.1; en-US; rv:1.8.0.5) 
                                          Gecko/20060719 Firefox/1.5.0.5');
    my $results = $ua->get($url);
    if ($results->is_success) {
        my $page = ($results->decoded_content);
        return $page;
    }
    else {
        print "Error: " . $results->status_line;
    }
}

my $results = pull_page();

my @content = split("<h3 class=\"r\">",$results);
my @blurbs = grep("url?q",@content);
my $last = (scalar @blurbs)-1;
$blurbs[$last] = substr($blurbs[$last],0,2000); #truncates the last result.
@blurbs = grep {length($_)<=3000} @blurbs; #removes thumbmail & sidebar inserts.

my $num = scalar @blurbs;
print "$num results\n";
for (my $i = 0; $i < $num; $i++){
    my ($url) = $blurbs[$i] =~ m/url\?q=(.*?)&amp/;
    $url = uri_unescape($url);
    print "$url\n";
}
