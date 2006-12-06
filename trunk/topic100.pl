#!/usr/local/bin/perl  
# Copyright (c) 2006, Xiubin Qian
# All rights reserved.
#
# This program is to generate top 10 hot topics of cn.bbs.* in the last 24 hours from
# ovdb of innd.   Blacklists for word and author are also supported.
# $Id: top10.pl 20 2006-10-30 04:45:50Z qianxb2000 $
use Time::Local;
use Getopt::Std;
require "funcs.pl";
#use strict;p

getopts("hc:t:");
&usage('topic') if($opt_h);
&usage('topic') if (!$opt_t);

$type=$opt_t;

########################################Define some variables#######################
my %destTopFile;
$destTopFile{'day'}=["topic_day_id","topic_day_post","topic_day_site"];
$destTopFile{'week'}=["topic_week_id","topic_week_post","topic_week_site"];
$destTopFile{'month'}=["topic_month_id","topic_month_post","topic_month_site"];
$destTopFile{'year'}=["topic_year_id","topic_year_post","topic_year_site"];

my $news_group	= "/usr/local/news/db/active"; #This file keeps the news groups' name
my $ovdb_comm	= "/usr/local/news/bin/ovdb_stat";
######################################End Define some variables#####################

my ( $year, $month, $day );
my  ( $hour );
my ( $timemin, $timemax );

my @newsGroups;        #This is used to keep all the DAT files

my @total;
my @final;
my $index;
my $i;
my $line;
my $time;

#add filter start
my $filter = "blacklist";
my %filter;

&getFilter( $filter, \%filter );
if($type =~/day/){

    $time = time();    #example 01:00:00 11
    my @time = localtime($time);    #01:00:00 10
    ( $hour, $day, $month, $year ) =
      ( $time[2], $time[3], $time[4] + 1, $time[5] + 1900 );    #(10,1,2002)
    $time    = timelocal( 0, 0, 0, $day, $month - 1, $year );  #00:00:00  10
    $timemin = $time - 86400;                           #16:00:00  9
    $timemax = $time;                                   #16;00:00 10
}elsif($type =~/week/){
    my @time=localtime(time());
    my $week=$time[6];
    $time=time()-$week*86400;
    @time=localtime($time);
    $time=timelocal(0,0,0,$time[3],$time[4],$time[5]);#last sunday 00:00:00
    $timemin=$time-6*86400;#last last monday 8:00:00
    $timemax=$time+86400;#last sunday 16:00:00

}elsif($type =~/month/){
    $time = time();    #example 01:00:00 11
    my @time = localtime($time);    #01:00:00 10
    ( $hour, $day, $month, $year ) =
      ( $time[2], $time[3], $time[4] + 1, $time[5] + 1900 );    #(10,1,2002)
      #$timemin = timelocal( 0, 0, 0, 1, $month - 1 -1, $year );  #00:00:00  10
    $timemin = timelocal( 0, 0, 0, 1, $month - 1 -1, $year );  #00:00:00  10
    $timemax = timelocal( 0, 0, 0, 1, $month - 1 , $year);  #00:00:00  10
    #$timemax = timelocal( 0, 0, 0, 1, $month - 1 , $year );  #00:00:00  10
}elsif($type =~/year/){
    $time = time();    #example 01:00:00 11
    my @time = localtime($time);    #01:00:00 10
    ( $hour, $day, $month, $year ) =
      ( $time[2], $time[3], $time[4] + 1, $time[5] + 1900 );    #(10,1,2002)
    $timemin = timelocal( 0, 0, 0, 1, 0, $year-1 );  #00:00:00  10
    $timemax = timelocal( 0, 0, 0, 1, 0, $year+1 );  #00:00:00  10
    #$timemax = timelocal( 0, 0, 0, 1, 0, $year );  #00:00:00  10
}

    ###############################end deal with date arguments ########################
    #
    ###############################         Get news groups      #######################
    open (NEWSGROUPS,"$news_group") or die "News Groups Data file $news_group open failed!\n";
    while(<NEWSGROUPS>){
	next if(/^#/);
        next if(/^$/);
        next if(/^[^cn]/);
	if(/^(cn.bbs.*?)\s+/){
		my $tempname=$1;
		chomp($tempname);
		push(@newsGroups,$tempname);
	}
    }
    close(NEWSGROUPS);
    ###############################      End Get news groups     #######################

    foreach $group_name (@newsGroups) {

	my $record={};
	&getBeginEndNum($group_name,0,0,$record);

	next if($record->{'count'} == 0);
	
        open( RECO, "$ovdb_comm -r $record->{'low'}-$record->{'high'} $record->{'groupName'} |") or die "aaa\n";
        #code for read record and compare it with the fianl data
        while ( $line = <RECO> ) {  
            my $tempname = {};
            chomp($line);

            &getInfo( $line, $tempname );

            next if ( ( $tempname->{'secs'} < $timemin ) or ( $tempname->{'secs'} > $timemax ) );
	
            if ( defined( @{ $filter{'titleFilter'} } ) ) {
                next if ( &indexof0( $tempname->{'title'}, $filter{'titleFilter'} ) != -1 );
            }
            if ( defined( @{ $filter{'title'} } ) ) {
                next if ( &indexof1( $tempname->{'title'}, $filter{'title'} ) != -1 );
            }

	##read here 2006.10.24
        $index = &indexof( $tempname->{'title'}, \@final );
	#如果该标题已经被保存，则返回位置，否则返回-1
        my $temp = quotemeta( $tempname->{'author'} );
        if ( $index == -1 ) { 
	#New Topics
            $tempname->{'group'}      = $record->{'groupName'};
            $tempname->{'froms'}->[0] = $tempname->{'from'};

            $tempname->{'nums_post'}    = 1;
            $tempname->{'nums_site'}    = 1;
            $tempname->{'nums_id'}      = 1;

            $tempname->{'lastdate'}   = $tempname->{'date'};

	    $tempname->{'author'}->{'first'}=$tempname->{'author'};
	    $tempname->{'author'}->{'last'}=$tempname->{'author'};

            push ( @final, $tempname );
        }else{

            $final[$index]->{'nums_post'}++;

            if ( $final[$index]->{'otherAuthor'} !~ /$temp/ ) {

            	$final[$index]->{'nums_id'}++;
            	$final[$index]->{'otherAuthor'} .= $tempname->{'author'};
	    }

            my $tempfrom = $tempname->{'from'};
            if ( grep( /^$tempfrom$/, @{ $final[$index]->{'froms'} } ) ) {
		    #next;
            } else {
                	push ( @{ $final[$index]->{'froms'} }, $tempname->{'from'} );
                	$final[$index]->{'nums_site'}++;
            }

	    if($tempname->{'secs'} < $final[$index]->{'secs'} ){
		    $final[$index]->{'from'}=$tempname->{'from'};
		    $final[$index]->{'secs'}=$tempname->{'secs'};
	    }
#	    print $final[$index]->{'title'},"\t",$final[$index]->{'nums'}->{'post'},"\t",$final[$index]->{'nums'}->{'id'},"\t",$final[$index]->{'nums'}->{'site'},"\n";
	}

    }
    close(RECO);
    #output this group's data into a file named by the group name
    @total = ( @total, @final );
    undef(@final);

    #end output
}
#add 8 hours
foreach (@total) {
    $_->{'date'} = &add8hours( $_->{'date'} );

}

 @temp = sort {
    ( $b->{'nums_post'} <=> $a->{'nums_post'} )
      or
      ( ( $b->{'nums_post'} == $a->{'nums_post'} ) and ( $b->{'nums_site'} <=> $a->{'nums_site'} ) )
      or
      ( ( $b->{'nums_post'} == $a->{'nums_post'} ) and ( $b->{'nums_site'} == $a->{'nums_site'} ) and ( $b->{'nums_id'} <=> $a->{'nums_id'}))
      or 
      ( ( $b->{'nums_post'} == $a->{'nums_post'} ) and ( $b->{'nums_site'} == $a->{'nums_site'} ) and ( $b->{'nums_id'} == $a->{'nums_id'}) and ( $b->{'secs'} <=> $a->{'secs'} ) )
} @total;
my @last_sort_by_topics;
#&sort2( \@temp, \@last );
@last_sort_by_topics=@temp;
###sort by id
&topn_topic($type, 100, \@last_sort_by_topics, $destTopFile{$type}->[1] );

@temp = sort {
    ( $b->{'nums_id'} <=> $a->{'nums_id'} )
      or
      ( ( $b->{'nums_id'} == $a->{'nums_id'} ) and ( $b->{'nums_site'} <=> $a->{'nums_site'} ) )
      or
      ( ( $b->{'nums_id'} == $a->{'nums_id'} ) and ( $b->{'nums_site'} == $a->{'nums_site'} ) and ( $b->{'nums_post'} <=> $a->{'nums_post'}))
      or 
      ( ( $b->{'nums_id'} == $a->{'nums_id'} ) and ( $b->{'nums_site'} == $a->{'nums_site'} ) and ( $b->{'nums_post'} == $a->{'nums_post'}) and ( $b->{'secs'} <=> $a->{'secs'} ) )
} @total;
my @last_sort_by_id;
#&sort2( \@temp, \@last );
@last_sort_by_id=@temp;
&topn_id($type, 100, \@last_sort_by_id, $destTopFile{$type}->[0] );

@temp = sort {
    ( $b->{'nums_site'} <=> $a->{'nums_site'} )
      or
      ( ( $b->{'nums_site'} == $a->{'nums_site'} ) and ( $b->{'nums_post'} <=> $a->{'nums_post'} ) )
      or
      ( ( $b->{'nums_site'} == $a->{'nums_site'} ) and ( $b->{'nums_post'} == $a->{'nums_post'} ) and ( $b->{'nums_id'} <=> $a->{'nums_id'}))
      or 
      ( ( $b->{'nums_site'} == $a->{'nums_site'} ) and ( $b->{'nums_post'} == $a->{'nums_post'} ) and ( $b->{'nums_id'} == $a->{'nums_id'}) and ( $b->{'secs'} <=> $a->{'secs'} ) )
} @total;
my @last_sort_by_site;
#&sort2( \@temp, \@last );
@last_sort_by_site=@temp;
&topn_site($type, 100, \@last_sort_by_site, $destTopFile{$type}->[2] );
