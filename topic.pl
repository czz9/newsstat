#!/usr/bin/perl -w
#
#use strict;
#Writen by qxb@smth
#Any advice,contact qxb@smth
#$Id: welcome.pl,v 1.35 2005/03/03 12:10:42 czz Exp $
use Time::Local;

########################################Define some variables#######################
my ( $year, $month, $day );
my ( $timemin, $timemax );
my %month;
my $datDir      = "/usr/local/news/spool/overview/c/b/";
my $destTopFile = "/usr/local/news/public_html/day";

#my $invalid="badtitle.conf";
#my @badtitles;
my @datFiles;        #This is used to keep all the DAT files
my $datfile;
my $destFileName;    #This is used to keep all the DAT files
my @final;           #This is used to keep all the record
my @total;
my $index;
my $i;
my $line;
my $time;

#add filter start
my $filter = "filter.conf";
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
    $timemax = $time - 8 * 3600;                                   #16;00:00 10
}

#$time=timelocal(0,0,0,12,11,2001);  #00:00:00  10
#$timemin=$time-8*3600-86400;	#16:00:00  9
#$timemax=$time-8*3600; #16;00:00 10

#end check argu
#define the date
%month = (
    "1", "Jan", "2",  "Feb", "3",  "Mar", "4",  "Apr",
    "5", "May", "6",  "Jun", "7",  "Jul", "8",  "Aug",
    "9", "Sep", "10", "Oct", "11", "Nov", "12", "Dec"
);

#$day="$day" if(length($day) == 1);
#$dateString="$day $month{$month} $year";
#end define
###############################end deal with date arguments ########################
#
###############################Begin deal with the data file #######################
@datFiles = `find $datDir -name "cn.bbs.*.dat" -o -name "cn.bbs.*.DAT"`;
chomp(@datFiles);
foreach $datfile (@datFiles) {
    if ( $datfile =~ /^.*\/(.*)\.[dD][aA][tT]$/i ) {
        $destFileName = $1;
    }

    open( FILE, $datfile ) or die "Cant find file $datfile,Please check it!\n";

    #code for read record and compare it with the fianl data
    while ( $line = <FILE> ) {    #Read the DAT file line by line
        my $tempname = {};
        chomp($line);
        $time = &getTime($line);
        next if ( ( $time < $timemin ) or ( $time > $timemax ) );

        #		next if($line!~/$dateString/);#read next if the date dont match

        &getInfo( $line, $tempname );

        #
        if ( defined( @{ $filter{'titleFilter'} } ) ) {
            next
              if ( &indexof0( $tempname->{'title'}, $filter{'titleFilter'} ) !=
                -1 );
        }
        if ( defined( @{ $filter{'title'} } ) ) {
            next
              if ( &indexof1( $tempname->{'title'}, $filter{'title'} ) != -1 );
        }

        #

        #		next if(&invalid(\@badtitles,$tempname->{'title'}));

        $index = &indexof( $tempname->{'title'}, \@final );
        $temp = quotemeta( $tempname->{'author'} );
        if ( $index == -1 ) {
            $tempname->{'group'}      = $destFileName;
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
    close(FILE);

    #output this group's data into a file named by the group name
    @total = ( @total, @final );
    undef(@final);

    #end output

}

#add 8 hours
foreach (@total) {
    $_->{'date'} = &add8hours( $_->{'date'} );
}

#

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

sub getInfo {
    my @info = split ( /\t/, $_[0] );

    ( ( $info[1] =~ /^Re:\s(.*)$/ ) and $_[1]->{'title'} = $1 )
      or $_[1]->{'title'} = $info[1];
    ( ( $info[2] =~ /^\s*(.*)\s+\(.*$/ ) and $_[1]->{'author'} = $1 )
      or $_[1]->{'author'} = $info[2];
    $_[1]->{'authorN'}     = $info[2];
    $_[1]->{'otherAuthor'} = $_[1]->{'author'};
    if ( $info[3] =~ /^\s*(\w+,)?\s*(.*?\d\d:\d\d:\d\d)\s+.*$/ ) {
        $_[1]->{'date'} = $2;
        $_[1]->{'secs'} = &getTime_($2);
    }
    $_[1]->{'id'} = $info[4];
    ( $info[4] =~ /.*?@(.*)>$/ ) and $_[1]->{'from'} = $1;
    $_[1]->{'nums'} = 1;

    return 1;
}

sub indexof {
    my $i;

    for ( $i = 0 ; $i < @{ $_[1] } ; $i++ ) {
        $title_ = quotemeta( ${ $_[1][$i] }{'title'} );
        return $i if ( $_[0] =~ /^(Re:\s)?$title_/ );
    }
    return -1;
}

sub indexof0 {
    my $i;

    for ( $i = 0 ; $i < @{ $_[1] } ; $i++ ) {
        $title_ = quotemeta( $_[1][$i] );
        return $i if ( $_[0] =~ /$title_/ );
    }
    return -1;
}

sub indexof1 {
    my $i;

    for ( $i = 0 ; $i < @{ $_[1] } ; $i++ ) {
        $title_ = quotemeta( $_[1][$i] );
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
    my $footer = "¡ùProgrammed by qxb<qianxb\@tsinghua.org.cn> 2002/01/16";

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

sub getTime {
    my $line  = shift;
    my $time  = {};
    my %month = (
        "Jan", 0, "Feb", 1, "Mar", 2, "Apr", 3, "May", 4,  "Jun", 5,
        "Jul", 6, "Aug", 7, "Sep", 8, "Oct", 9, "Nov", 10, "Dec", 11
    );
    my @info = split ( /\t/, $line );

    if ( $info[3] =~ /^\s*(\w+,)?\s*(.*?\d\d:\d\d:\d\d)\s+.*$/ ) {
        $info[3] = $2;
    }
    (
        $time->{'day'},  $time->{'month'}, $time->{'year'},
        $time->{'time'}, $time->{'temp'}
      )
      = split ( /\s+/, $info[3] );
    ( $time->{'hour'}, $time->{'min'}, $time->{'sec'} ) =
      split ( /:/, $time->{'time'} );
    $time->{'month'} = $month{ $time->{'month'} };
    return timelocal(
        $time->{'sec'}, $time->{'min'},   $time->{'hour'},
        $time->{'day'}, $time->{'month'}, $time->{'year'}
    );
}

sub add8hours {
    my $line = shift;
    my $time = {};
    my $seconds;
    my %month = (
        "Jan", 0, "Feb", 1, "Mar", 2, "Apr", 3, "May", 4,  "Jun", 5,
        "Jul", 6, "Aug", 7, "Sep", 8, "Oct", 9, "Nov", 10, "Dec", 11
    );
    my %month1 = (
        "0", "Jan", "1", "Feb", "2",  "Mar", "3",  "Apr",
        "4", "May", "5", "Jun", "6",  "Jul", "7",  "Aug",
        "8", "Sep", "9", "Oct", "10", "Nov", "11", "Dec"
    );
    ( $time->{'day'}, $time->{'month'}, $time->{'year'}, $time->{'time'} ) =
      split ( /\s+/, $line );
    ( $time->{'hour'}, $time->{'min'}, $time->{'sec'} ) =
      split ( /:/, $time->{'time'} );
    $time->{'month'} = $month{ $time->{'month'} };
    $seconds = timelocal(
        $time->{'sec'}, $time->{'min'},   $time->{'hour'},
        $time->{'day'}, $time->{'month'}, $time->{'year'}
    );
    $seconds += 8 * 3600;
    (
        $time->{'sec'},   $time->{'min'},  $time->{'hour'}, $time->{'day'},
        $time->{'month'}, $time->{'year'}, $time->{'temp'}
      )
      = localtime($seconds);
    $time->{'min'}  = "0$time->{'min'}"  if ( length( $time->{'min'} ) == 1 );
    $time->{'hour'} = "0$time->{'hour'}" if ( length( $time->{'hour'} ) == 1 );
    $time->{'sec'}  = "0$time->{'sec'}"  if ( length( $time->{'sec'} ) == 1 );
    $time->{'year'} += 1900;
    $time->{'month'} = $month1{ $time->{'month'} };
    return
"$time->{'day'} $time->{'month'} $time->{'year'} $time->{'hour'}:$time->{'min'}:$time->{'sec'}";
}

sub getTime_ {
    my $line  = shift;
    my $time  = {};
    my %month = (
        "Jan", 0, "Feb", 1, "Mar", 2, "Apr", 3, "May", 4,  "Jun", 5,
        "Jul", 6, "Aug", 7, "Sep", 8, "Oct", 9, "Nov", 10, "Dec", 11
    );
    (
        $time->{'day'},  $time->{'month'}, $time->{'year'},
        $time->{'time'}, $time->{'temp'}
      )
      = split ( /\s+/, $line );
    ( $time->{'hour'}, $time->{'min'}, $time->{'sec'} ) =
      split ( /:/, $time->{'time'} );
    $time->{'month'} = $month{ $time->{'month'} };
    return timelocal(
        $time->{'sec'}, $time->{'min'},   $time->{'hour'},
        $time->{'day'}, $time->{'month'}, $time->{'year'}
    );
}

sub invalid {
    my $i;
    my $title;

    for ( $i = 0 ; $i < @{ $_[0] } ; $i++ ) {
        $title = quotemeta( ${ $_[0] }[$i] );
        if ( $_[1] =~ /^\s*$title\s*$/ ) {
            return 1;
        }
    }

    return 0;
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

