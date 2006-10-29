# Copyright (c) 2006, Xiubin Qian
# All rights reserved.
#
# This program is to generate top 10 hot topics of cn.bbs.* in the last 24 hours from
# ovdb of innd.   Blacklists for word and author are also supported.
# $Id$

use Time::Local;

my $ovdb_command="ovdb_stat";

sub getBeginEndNum{
	#&getBeginEndNum($newsgroup,$timebegin,$timeend,\%record);
	open(OVDB,"$ovdb_command -c $_[0] |") or die "Excute command failed!\n";
	while(<OVDB>){
		if(/.*counted:\s*low:\s*(\d+).*high:\s*(\d+).*count:\s+(\d+)/){
			$_[3]->{'groupName'}=$_[0];
			$_[3]->{'low'}=($1>$2)?$2:$1;
			$_[3]->{'high'}=$2;
			$_[3]->{'count'}=$3;
			
		}else{
			$_[3]->{'groupName'}=$_[0];
			$_[3]->{'low'}=0;
			$_[3]->{'high'}=0;
			$_[3]->{'count'}=0;
		}
	}
}

sub getInfo {
#czz@newsmth.net-SPAM.no (czz)   25 May 2006 08:40:57 GMT<4OHL2K$g0Q@newsmth.net>  
#<statistics@address.invalid>     Mon, 04 Sep 2006 00:00:01 +0800   <edfjdh$kog$26@news.yaako.com> 
    my @info = split ( /\t/, $_[0] );

    ( ( $info[1] =~ /^Re:\s(.*)$/ ) and $_[1]->{'title'} = $1 )
      or $_[1]->{'title'} = $info[1];
    ( ( $info[2] =~ /^\s*(.*)\s+\(.*$/ ) and $_[1]->{'author'} = $1 )
      or $_[1]->{'author'} = $info[2];
    $_[1]->{'authorN'}     = $info[2];
    $_[1]->{'otherAuthor'} = $_[1]->{'author'};
    if ( $info[3] =~ /(\d{1,2}\s+\w\w\w\s+\d{4}\s+\d{1,2}:\d{1,2}:\d{1,2})/ ) {
        $_[1]->{'date'} = $1;
        $_[1]->{'secs'} = &getTime_($1);
    }
    $_[1]->{'id'} = $info[4];
    ( $info[4] =~ /.*?@(.*)>$/ ) and $_[1]->{'from'} = $1;
    $_[1]->{'nums'} = 1;

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

    #26 Sep 2006 01:13:31 GMT
    #Tue, 26 Sep 2006 07:15:02
    if( $info[3] =~ /(\d{1,2}\s+\w\w\w\s+\d{4}\s+\d{1,2}:\d{1,2}:\d{1,2})/ ) {
        $info[3] = $1;
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
    ( $time->{'day'}, $time->{'month'}, $time->{'year'}, $time->{'time'} ) = split ( /\s+/, $line );
    ( $time->{'hour'}, $time->{'min'}, $time->{'sec'} ) = split ( /:/, $time->{'time'} );
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
