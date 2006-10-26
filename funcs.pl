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
	open(OVDB,"$ovdb_command -g $_[0] |") or die "Excute command failed!\n";
	while(<OVDB>){
		if(/.*groupstats:\s*low:\s*(\d+).*high:\s*(\d+).*count:\s+(\d+)/){
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

1;
