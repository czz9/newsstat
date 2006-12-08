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
$destTopFile{'day'}=["group_day_id","group_day_post","group_day_site"];
$destTopFile{'week'}=["group_week_id","group_week_post","group_week_site"];
$destTopFile{'month'}=["group_month_id","group_month_post","group_month_site"];
$destTopFile{'year'}=["group_year_id","group_year_post","group_year_site"];

#my $news_group	= "../active"; #This file keeps the news groups' name
my $news_group	= "/usr/local/news/db/active"; #This file keeps the news groups' name
#my $ovdb_comm	= "ovdb_stat";
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
    $timemax = timelocal( 0, 0, 0, 1, 0, $year );  #00:00:00  10
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
	
        open( RECO, "$ovdb_comm -r $record->{'low'}-$record->{'high'} $record->{'groupName'} |");
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

	    $record->{'name'}=$group_name;
	    $record->{'post_num'}++;
	    $record->{'id'}->{$tempname->{'author'}}++;
	    $record->{'site'}->{$tempname->{'from'}}++;

	}
        close(RECO);

	$record->{'id_num'}=keys(%{$record->{'id'}});
	$record->{'site_num'}=keys(%{$record->{'site'}});
        push ( @final, $record );
    }
    #output this group's data into a file named by the group name
    #end output

#add 8 hours
foreach (@total) {
    $_->{'date'} = &add8hours( $_->{'date'} );

}

 @temp = sort {
    ( $b->{'site_num'} <=> $a->{'site_num'} )
      or
    ( ( $b->{'site_num'} == $a->{'site_num'} ) and ( $b->{'post_num'} <=> $a->{'post_num'} ) )
      or
    ( ( $b->{'site_num'} == $a->{'site_num'} ) and ( $b->{'post_num'} == $a->{'post_num'} ) and ( $b->{'id_num'} <=> $a->{'id_num'}))
} @final;
my @last_sort_by_site;
@last_sort_by_site=@temp;

###sort by site
&top_group_site($type, \@last_sort_by_site, $destTopFile{$type}->[2] );
#####sort by id
 @temp = sort {
    ( $b->{'id_num'} <=> $a->{'id_num'} )
      or
    ( ( $b->{'id_num'} == $a->{'id_num'} ) and ( $b->{'site_num'} <=> $a->{'site_num'} ) )
      or
    ( ( $b->{'id_num'} == $a->{'id_num'} ) and ( $b->{'site_num'} == $a->{'site_num'} ) and ( $b->{'post_num'} <=> $a->{'post_num'}))
} @final;
my @last_sort_by_id;
@last_sort_by_id=@temp;

###sort by id
&top_group_id($type, \@last_sort_by_id, $destTopFile{$type}->[0] );

#####sort by post
 @temp = sort {
    ( $b->{'post_num'} <=> $a->{'post_num'} )
      or
    ( ( $b->{'post_num'} == $a->{'post_num'} ) and ( $b->{'site_num'} <=> $a->{'site_num'} ) )
      or
    ( ( $b->{'post_num'} == $a->{'post_num'} ) and ( $b->{'site_num'} == $a->{'site_num'} ) and ( $b->{'id_num'} <=> $a->{'id_num'}))
} @final;
my @last_sort_by_post;
@last_sort_by_post=@temp;

###sort by post
&top_group_post($type, \@last_sort_by_post, $destTopFile{$type}->[1] );
