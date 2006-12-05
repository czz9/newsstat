#!/usr/local/bin/perl  -w
# Copyright (c) 2006, Xiubin Qian
# All rights reserved.
#
# This program is to generate top 10 hot topics of cn.bbs.* in the last 24 hours from
# ovdb of innd.   Blacklists for word and author are also supported.
# $Id$

use Time::Local;
require "funcs.pl";
#use strict;

########################################Define some variables#######################
my $destTopFile	= "/usr/local/news/public_html/day";
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

#add filter stop
########################################Begin deal with date arguments################
#check the arguments
if ( @ARGV != 0 ) {
    print "Usage:$0\n";
    exit 1;
}
if ( @ARGV == 0 ) {
    $time = time();    #example 01:00:00 11
    my @time = localtime($time);    #01:00:00 10
    ( $hour, $day, $month, $year ) =
      ( $time[2], $time[3], $time[4] + 1, $time[5] + 1900 );    #(10,1,2002)
    $time    = timelocal( 0, 0, $hour, $day, $month - 1, $year );  #00:00:00  10
    $timemin = $time - 86400;                           #16:00:00  9
#$timemin = $time - 8 * 3600 - 86400;                           #16:00:00  9
#    $timemin = $time - 8 * 3600 - 25*86400;                           #16:00:00  9
    $timemax = $time;                                   #16;00:00 10
    #$timemax = $time - 8 * 3600;                                   #16;00:00 10
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
	
    open( RECO, "$ovdb_comm -r $record->{'low'}-$record->{'high'} $record->{'groupName'} |") ;
    #code for read record and compare it with the fianl data
    while ( $line = <RECO> ) {    #Read the DAT file line by line
        my $tempname = {};
        chomp($line);
        $time = &getTime($line);
        next if ( ( $time < $timemin ) or ( $time > $timemax ) );

        &getInfo( $line, $tempname );
	
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
            $tempname->{'group'}      = $record->{'groupName'};
	    #$tempname->{'group'}      = $destFileName;
            $tempname->{'froms'}->[0] = $tempname->{from};
            $tempname->{'fromNum'}    = 1;
            push ( @final, $tempname );
        }
        elsif ( $final[$index]->{'otherAuthor'} !~ /$temp/ ) {
            $final[$index]->{'nums'}++;
            $final[$index]->{'otherAuthor'} .= $tempname->{'author'};
            my $tempfrom = $tempname->{'from'};
            if ( grep( /^$tempfrom$/, @{ $final[$index]->{froms} } ) ) {
                next;
            }
            else {
                push ( @{ $final[$index]->{froms} }, $final[$index]->{from} );
                $final[$index]->{fromNum}++;
            }

	    if($tempname->{'secs'} < $final[$index]->{'secs'} ){
		    $final[$index]->{'from'}=$tempname->{'from'};
		    $final[$index]->{'secs'}=$tempname->{'secs'};
	    }
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

#&sort(\@total);

my @temp = sort {
    ( $b->{'nums'} <=> $a->{'nums'} )
      or
      ( ( $b->{'nums'} == $a->{'nums'} ) and ( $b->{'group'} cmp $a->{'group'} ) )
      or (  ( $b->{'nums'} == $a->{'nums'} )
        and ( $b->{'group'} eq $a->{'group'} ) 
        and ( $b->{'secs'} == $a->{'secs'} ) )
} @total;
my @last;
&sort2( \@last, \@temp,3 );
#@last=@temp;

&topn( 10, \@last, $destTopFile );

