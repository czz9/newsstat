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
my $destTopFile	= "day";
my $news_group	= "cnnews.list"; #This file keeps the news groups' name
my $ovdb_comm	= "ovdb_stat";
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
    $timemin = $time - 8 * 3600 - 86400;                           #16:00:00  9
#    $timemin = $time - 8 * 3600 - 25*86400;                           #16:00:00  9
    $timemax = $time - 8 * 3600;                                   #16;00:00 10
}

###############################end deal with date arguments ########################
#
###############################         Get news groups      #######################
open (NEWSGROUPS,"$news_group") or die "News Groups Data file $news_group open failed!\n";
while(<NEWSGROUPS>){
	next if(/^#/);
        next if(/^$/);
        next if(/^[^cn]/);
	my $tempname=$_;
	chomp($tempname);
	push(@newsGroups,$tempname);
}
close(NEWSGROUPS);

###############################      End Get news groups     #######################

foreach $group_name (@newsGroups) {

	my $record={};
	&getBeginEndNum($group_name,0,0,$record);

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
	#Èç¹û¸Ã±êÌâÒÑ¾­±»±£´æ£¬Ôò·µ»ØÎ»ÖÃ£¬·ñÔò·µ»Ø-1
	 
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
      ( ( $b->{'nums'} == $a->{'nums'} ) and ( $b->{'secs'} <=> $a->{'secs'} ) )
      or (  ( $b->{'nums'} == $a->{'nums'} )
        and ( $b->{'secs'} == $a->{'secs'} )
        and ( $b->{'group'} cmp $a->{'group'} ) )
} @total;
my @last;
&sort2( \@temp, \@last );

&topn( 10, \@last, $destTopFile );

sub sort2 {
    my @array;
    my $i;
    my $j;

    for ( $i = 0 ; $i < @{ $_[0] } ; $i++ ) {
        if ( $_[0][$i]->{'fromNum'} >= 2 ) {
            push ( @{ $_[1] }, $_[0][$i] );
        }
        else {
            push ( @array, $_[0][$i] );
        }
    }

    push ( @{ $_[1] }, @array );
}

sub indexof {
    my $i;

    for ( $i = 0 ; $i < @{ $_[1] } ; $i++ ) {
        my $title_ = quotemeta( ${ $_[1][$i] }{'title'} );
        return $i if ( $_[0] =~ /^(Re:\s)?$title_/ );
    }
    return -1;
}

sub indexof0 {
    my $i;

    for ( $i = 0 ; $i < @{ $_[1] } ; $i++ ) {
        my $title_ = quotemeta( $_[1][$i] );
        return $i if ( $_[0] =~ /$title_/ );
    }
    return -1;
}

sub indexof1 {
    my $i;

    for ( $i = 0 ; $i < @{ $_[1] } ; $i++ ) {
        my $title_ = quotemeta( $_[1][$i] );
        return $i if ( $_[0] =~ /^\s*$title_\s*$/ );
    }
    return -1;
}

sub sort {
    my $rarray = shift;
    my @array  = @$rarray;
    my $i;
    my $j;
    my %rhash;

    for ( $i = 0 ; $i < @array - 1 ; $i++ ) {
        for ( $j = $i + 1 ; $j < @array ; $j++ ) {
            if ( $array[$i]->{'nums'} < $array[$j]->{'nums'} ) {
                %rhash = %{ $array[$i] };
                %{ $array[$i] } = %{ $array[$j] };
                %{ $array[$j] } = %rhash;
            }
            elsif ( ( $array[$i]->{'nums'} == $array[$j]->{'nums'} )
                and ( $array[$i]->{'secs'} < $array[$j]->{'secs'} ) )
            {
                %rhash = %{ $array[$i] };
                %{ $array[$i] } = %{ $array[$j] };
                %{ $array[$j] } = %rhash;
            }
            elsif ( ( $array[$i]->{'nums'} == $array[$j]->{'nums'} )
                and ( $array[$i]->{'secs'} == $array[$j]->{'secs'} )
                and ( $array[$i]->{'group'} lt $array[$j]->{'group'} ) )
            {
                %rhash = %{ $array[$i] };
                %{ $array[$i] } = %{ $array[$j] };
                %{ $array[$j] } = %rhash;

            }
        }
    }
}

sub topn {
    my $num    = shift;
    my $rarray = shift;
    my $file   = shift;
    my @array  = @{$rarray};
    my $i;
    my $now    = localtime( time() );
    my $footer = "¡ùProgrammed by qxb<qianxb\@tsinghua.org.cn> 2002/01/16, Modified on 2006/10/24";

    format FORMATHEADER =
                [1;34m-----[37m===== [31mÈ«[33m¹ú[35mÊ®[34m´ó[32mÈÈ[36mÃÅ[33m»°[31mÌâ [37m=====[34m-----[0m
.
    format FORMATHEADER1 =
                        [4mhttp://www.cn-bbs.org/[0m
.

    format FORMATLINE1 =
[1;37mµÚ[33m@## [37mÃû ÐÅÇø : [35m@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[32m@<<<<<<<<<<<<<<<<<<<<<<<<<<[0m
	$i+1,$array[$i]->{'group'},$array[$i]->{'author'}
.
    format FORMATLINE2 =
[1;44m  @>>ÈË¡ú±êÌâ : @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<[0m
	  $array[$i]->{'nums'},$array[$i]->{'title'}
.
    format FORMATLINE3 =
     ×÷Õß : @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	  $array[$i]->{'authorN'}
.
    format FORMATLINE4 =
     ÈËÊý : @<<<<
	  $array[$i]->{'nums'}

.
    format FORMATFOOT =
                      (@<<<<<<<<<<<<<<<<<<<<<<<)
	      $now
.

    open( FILE2, ">$file" ) or die "Cant *write* file $file,Please check it!\n";
    select(FILE2);
    $~ = "FORMATHEADER";
    write;
    $~ = "FORMATHEADER1";
    write;
    for ( $i = 0 ; $i < $num ; $i++ ) {

        $~ = "FORMATLINE1";
        write;
        $~ = "FORMATLINE2";
        write;

        #		$~="FORMATLINE3";
        #		write;
        #		$~="FORMATLINE4";
        #		write;
    }
    $~ = FORMATFOOT;
    write;
    close(FILE2);
    select(STDOUT);
    return 1;
}

sub getFilter {

    #&getFilter($confile,\%filters)
    open( FILTER, $_[0] ) or die "Cant find file $_[0],Please check it!\n";
    while (<FILTER>) {
        next if (/^\s*#/);
        my ( $key, $values ) = split (/=/);
        next if ( !defined($values) );
        my @value = split ( /\s+/, $values );
        $_[1]->{$key} = \@value;
    }
    close(FILTER);
}

1;

