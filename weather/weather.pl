#!/usr/bin/perl -w

my $title;
my $content;
my $count = 0;
my $hash  = {};

my $home      = ".";
#my $home      = "/usr/local/news/lists/weather";
my $datafile_china24_1 = "$home/china_24_1.html";
my $datafile_china24_2 = "$home/china_24_2.html";
my $datafile_china48_1 = "$home/china_48_1.html";
my $datafile_china48_2 = "$home/china_48_2.html";
my $datafile_china72_1 = "$home/china_72_1.html";
my $datafile_china72_2 = "$home/china_72_2.html";
my $datafile_world24_1 = "$home/world_24_1.html";
my $datafile_world24_2 = "$home/world_24_2.html";
my $datafile_world48_1 = "$home/world_48_1.html";
my $datafile_world48_2 = "$home/world_48_2.html";
my $datafile_travel24_1 = "$home/travel_24_1.html";
my $datafile_travel24_2 = "$home/travel_24_2.html";

#��ʱ�洢�ļ�
my $destfile1 = "$home/china24";      #���ڳ���24Сʱ����Ԥ��
my $destfile2 = "$home/china48";      #���ڳ���48Сʱ����Ԥ��
my $destfile3 = "$home/china72";      #���ڳ���72Сʱ����Ԥ��
my $destfile4 = "$home/world24";      #�������24Сʱ����Ԥ��
my $destfile5 = "$home/world48";      #�������48Сʱ����Ԥ��
my $destfile6 = "$home/travel24";     #���γ���24Сʱ����Ԥ��

#####define date
my %week = (
    0 => "Sun",
    1 => "Mon",
    2 => "Tue",
    3 => "Wed",
    4 => "Thu",
    5 => "Fri",
    6 => "Sat"
);
my %month = (
    1  => "Jan",
    2  => "Feb",
    3  => "Mar",
    4  => "Apr",
    5  => "May",
    6  => "Jun",
    7  => "Jul",
    8  => "Aug",
    9  => "Sep",
    10 => "Oct",
    11 => "Nov",
    12 => "Dec"
);
my @time = localtime();
$time[3]='0'.$time[3] if(length($time[3]) == 1);
my $date = $week{ $time[6] } . ' ' . $month{ ++$time[4] } . ' ' . $time[3];
####
if ( @ARGV != 1 ) {
    &usage;
}
if ( $ARGV[0] eq 'I24' ) {

    open( F, $datafile_china24_1 ) or die "file $datafile_china24_1 does not exist!\n";
    undef $/;
    $contents = <F>;

    #print $content,"\n";
    if ( $contents =~ /<table.*(��������̨.*?ʱ.*?ʱ.*?ʱ)(.*?)<\/table>/si ) {
        $title   = $1;
        $content = $2;
        $content =~s/&nbsp;//sg;
    }
    else {
        $content = "no";
    }
    close(F);
    &printheader( $destfile1, $date, "���ڳ���24Сʱ����Ԥ��" );

    open( OUT, ">>$destfile1" ) or die;

    #������
    $title =~ s/%\s*//;
    print OUT "\t", $title;
    print OUT "
���������������ש������������������ש������������ש�����������������������
�� ��      �� ��   �� �� �� ��    �� �� �ȣ�C�� ��     �� �� �� ��      ��
�ǩ������������贈�������ש��������贈�����ש����贈���������ש�����������
��            �� ҹ ��  �� �� ��  ���� �� ����ߩ�  ҹ  ��  ��  ��  ��  ��
�ǩ������������贈�������贈�������贈�����贈���贈���������贈����������
";
    close(OUT);

    while ( $content =~
/<tr.*?>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>.*?<\/tr>(.*?<tr>.*)/si
      )
    {

        #if($aa=~/<tr><td.*?><font.*?>\s*(.*?)\s*<\/font>.*?<\/td><\/tr>/si){
        #	print $1,$2,$3,$4,$5,$6,$7,"\n";
        $count++;
        $hash->{'city'}    = $1;
        $hash->{'night'}   = $2;
        $hash->{'day'}     = $3;
        $hash->{'h_temp'}  = $4;
        $hash->{'l_temp'}  = $5;
        $hash->{'night_w'} = $6;
        $hash->{'day_w'}   = $7;
        $content = $8;
	next if($hash->{'city'} =~/����/);
        &fmtprint( $hash, $destfile1 );
        $hash    = {};
        last if ( $count == 49 );
    }
    
#page I
    $count=0;
    open( F, $datafile_china24_2 ) or die "file $datafile_china24_2 does not exist!\n";
    undef $/;
    $contents = <F>;

    #print $content,"\n";
    if ( $contents =~ /<table.*(��������̨.*?ʱ.*?ʱ.*?ʱ)(.*?)<\/table>/si ) {
        $title   = $1;
        $content = $2;
        $content =~s/&nbsp;//sg;
    }
    else {
        $content = "no";
    }
    close(F);
    while ( $content =~
/<tr.*?>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>.*?<\/tr>(.*?<tr>.*)/si
      )
    {

        #if($aa=~/<tr><td.*?><font.*?>\s*(.*?)\s*<\/font>.*?<\/td><\/tr>/si){
        #	print $1,$2,$3,$4,$5,$6,$7,"\n";
        $hash->{'city'}    = $1;
        $hash->{'night'}   = $2;
        $hash->{'day'}     = $3;
        $hash->{'h_temp'}  = $4;
        $hash->{'l_temp'}  = $5;
        $hash->{'night_w'} = $6;
        $hash->{'day_w'}   = $7;
        $count++;
        $content = $8;
	next if($hash->{'city'} =~/����/);
        &fmtprint( $hash, $destfile1 );
        $hash    = {};
        last if ( $count == 34 );
    }
#page II

    &printfooter($destfile1);
    &clearit($destfile1);}
elsif ( $ARGV[0] eq 'I48' ) {
#################################

    open( F, $datafile_china48_1 ) or die "file $datafile_china48_1 does not exist!\n";
    undef $/;
    $contents = <F>;

    #print $content,"\n";
    if ( $contents =~ /<table.*(��������̨.*?ʱ.*?ʱ.*?ʱ)(.*?)<\/table>/si ) {
        $title   = $1;
        $content = $2;
        $content =~s/&nbsp;//sg;
    }
    else {
        $content = "no";
    }
    close(F);
    &printheader( $destfile2, $date, "���ڳ���48Сʱ����Ԥ��" );

    open( OUT, ">>$destfile2" ) or die;

    #������
    $title =~ s/%\s*//;
    print OUT "\t", $title;
    print OUT "
���������������ש������������������ש������������ש�����������������������
�� ��      �� ��   �� �� �� ��    �� �� �ȣ�C�� ��     �� �� �� ��      ��
�ǩ������������贈�������ש��������贈�����ש����贈���������ש�����������
��            �� ҹ ��  �� �� ��  ���� �� ����ߩ�  ҹ  ��  ��  ��  ��  ��
�ǩ������������贈�������贈�������贈�����贈���贈���������贈����������
";
    close(OUT);

    while ( $content =~
/<tr.*?>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>.*?<\/tr>(.*?<tr>.*)/si
      )
    {

        #if($aa=~/<tr><td.*?><font.*?>\s*(.*?)\s*<\/font>.*?<\/td><\/tr>/si){
        #	print $1,$2,$3,$4,$5,$6,$7,"\n";
        $count++;
        $hash->{'city'}    = $1;
        $hash->{'night'}   = $2;
        $hash->{'day'}     = $3;
        $hash->{'h_temp'}  = $4;
        $hash->{'l_temp'}  = $5;
        $hash->{'night_w'} = $6;
        $hash->{'day_w'}   = $7;
        $content = $8;
	next if($hash->{'city'} =~/����/);
        &fmtprint( $hash, $destfile2 );
        $hash    = {};
        last if ( $count == 49 );
    }
    
#page I
    $count=0;
    open( F, $datafile_china48_2 ) or die "file $datafile_china48_2 does not exist!\n";
    undef $/;
    $contents = <F>;

    #print $content,"\n";
    if ( $contents =~ /<table.*(��������̨.*?ʱ.*?ʱ.*?ʱ)(.*?)<\/table>/si ) {
        $title   = $1;
        $content = $2;
        $content =~s/&nbsp;//sg;
    }
    else {
        $content = "no";
    }
    close(F);
    while ( $content =~
/<tr.*?>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>.*?<\/tr>(.*?<tr>.*)/si
      )
    {

        #if($aa=~/<tr><td.*?><font.*?>\s*(.*?)\s*<\/font>.*?<\/td><\/tr>/si){
        #	print $1,$2,$3,$4,$5,$6,$7,"\n";
        $hash->{'city'}    = $1;
        $hash->{'night'}   = $2;
        $hash->{'day'}     = $3;
        $hash->{'h_temp'}  = $4;
        $hash->{'l_temp'}  = $5;
        $hash->{'night_w'} = $6;
        $hash->{'day_w'}   = $7;
        $count++;
        $content = $8;
	next if($hash->{'city'} =~/����/);
        &fmtprint( $hash, $destfile2 );
        $hash    = {};
        last if ( $count == 34 );
    }
#page II

    &printfooter($destfile2);
    &clearit($destfile2);}
##############################################start end####
elsif ( $ARGV[0] eq 'I72' ) {

    open( F, $datafile_china72_1 ) or die "file $datafile_china72_1 does not exist!\n";
    undef $/;
    $contents = <F>;

    #print $content,"\n";
    if ( $contents =~ /<table.*(��������̨.*?ʱ.*?ʱ.*?ʱ)(.*?)<\/table>/si ) {
        $title   = $1;
        $content = $2;
        $content =~s/&nbsp;//sg;
    }
    else {
        $content = "no";
    }
    close(F);
    &printheader( $destfile3, $date, "���ڳ���72Сʱ����Ԥ��" );

    open( OUT, ">>$destfile3" ) or die;

    #������
    $title =~ s/%\s*//;
    print OUT "\t", $title;
    print OUT "
���������������ש������������������ש������������ש�����������������������
�� ��      �� ��   �� �� �� ��    �� �� �ȣ�C�� ��     �� �� �� ��      ��
�ǩ������������贈�������ש��������贈�����ש����贈���������ש�����������
��            �� ҹ ��  �� �� ��  ���� �� ����ߩ�  ҹ  ��  ��  ��  ��  ��
�ǩ������������贈�������贈�������贈�����贈���贈���������贈����������
";
    close(OUT);

    while ( $content =~
/<tr.*?>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>.*?<\/tr>(.*?<tr>.*)/si
      )
    {

        #if($aa=~/<tr><td.*?><font.*?>\s*(.*?)\s*<\/font>.*?<\/td><\/tr>/si){
        #	print $1,$2,$3,$4,$5,$6,$7,"\n";
        $count++;
        $hash->{'city'}    = $1;
        $hash->{'night'}   = $2;
        $hash->{'day'}     = $3;
        $hash->{'h_temp'}  = $4;
        $hash->{'l_temp'}  = $5;
        $hash->{'night_w'} = $6;
        $hash->{'day_w'}   = $7;
        $content = $8;
	next if($hash->{'city'} =~/����/);
        &fmtprint( $hash, $destfile3 );
        $hash    = {};
        last if ( $count == 49 );
    }
    
#page I
    $count=0;
    open( F, $datafile_china72_2 ) or die "file $datafile_china72_2 does not exist!\n";
    undef $/;
    $contents = <F>;

    #print $content,"\n";
    if ( $contents =~ /<table.*(��������̨.*?ʱ.*?ʱ.*?ʱ)(.*?)<\/table>/si ) {
        $title   = $1;
        $content = $2;
        $content =~s/&nbsp;//sg;
    }
    else {
        $content = "no";
    }
    close(F);
    while ( $content =~
/<tr.*?>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>.*?<\/tr>(.*?<tr>.*)/si
      )
    {

        #if($aa=~/<tr><td.*?><font.*?>\s*(.*?)\s*<\/font>.*?<\/td><\/tr>/si){
        #	print $1,$2,$3,$4,$5,$6,$7,"\n";
        $hash->{'city'}    = $1;
        $hash->{'night'}   = $2;
        $hash->{'day'}     = $3;
        $hash->{'h_temp'}  = $4;
        $hash->{'l_temp'}  = $5;
        $hash->{'night_w'} = $6;
        $hash->{'day_w'}   = $7;
        $count++;
        $content = $8;
	next if($hash->{'city'} =~/����/);
        &fmtprint( $hash, $destfile3 );
        $hash    = {};
        last if ( $count == 34 );
    }
#page II

    &printfooter($destfile3);
    &clearit($destfile3);

}
elsif ( $ARGV[0] eq 'E24' ) {#start          �����������Ԥ��


    open( F, $datafile_world24_1 ) or die "file $datafile_world24_1 does not exist!\n";
    undef $/;
    $contents = <F>;

    #print $content,"\n";
    if ( $contents =~ /<table.*(��������̨.*?ʱ.*?ʱ.*?ʱ)(.*?)<\/table>/si ) {
        $title   = $1;
        $content = $2;
        $content =~s/&nbsp;//sg;
    }
    else {
        $content = "no";
    }
    close(F);
    &printheader( $destfile4, $date, "�������24Сʱ����Ԥ��" );

    open( OUT, ">>$destfile4" ) or die;

    #������
    $title =~ s/%\s*//;
    print OUT "\t", $title;
    print OUT "
���������������ש������������������ש������������ש�����������������������
�� ��      �� ��   �� �� �� ��    �� �� �ȣ�C�� ��     �� �� �� ��      ��
�ǩ������������贈�������ש��������贈�����ש����贈���������ש�����������
��            �� ҹ ��  �� �� ��  ���� �� ����ߩ�  ҹ  ��  ��  ��  ��  ��
�ǩ������������贈�������贈�������贈�����贈���贈���������贈����������
";
    close(OUT);

    while ( $content =~
/<tr.*?>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>.*?<\/tr>(.*?<tr>.*)/si
      )
    {

        #if($aa=~/<tr><td.*?><font.*?>\s*(.*?)\s*<\/font>.*?<\/td><\/tr>/si){
        #	print $1,$2,$3,$4,$5,$6,$7,"\n";
        $count++;
        $hash->{'city'}    = $1;
        $hash->{'night'}   = $2;
        $hash->{'day'}     = $3;
        $hash->{'h_temp'}  = $4;
        $hash->{'l_temp'}  = $5;
        $hash->{'night_w'} = $6;
        $hash->{'day_w'}   = $7;
        $content = $8;
	next if($hash->{'city'} =~/����/);
        &fmtprint( $hash, $destfile4 );
        $hash    = {};
        last if ( $count == 49 );
    }
    
#page I
    $count=0;
    open( F, $datafile_world24_2 ) or die "file $datafile_world24_2 does not exist!\n";
    undef $/;
    $contents = <F>;

    #print $content,"\n";
    if ( $contents =~ /<table.*(��������̨.*?ʱ.*?ʱ.*?ʱ)(.*?)<\/table>/si ) {
        $title   = $1;
        $content = $2;
        $content =~s/&nbsp;//sg;
    }
    else {
        $content = "no";
    }
    close(F);
    while ( $content =~
/<tr.*?>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>.*?<\/tr>(.*?<tr>.*)/si
      )
    {

        #if($aa=~/<tr><td.*?><font.*?>\s*(.*?)\s*<\/font>.*?<\/td><\/tr>/si){
        #	print $1,$2,$3,$4,$5,$6,$7,"\n";
        $hash->{'city'}    = $1;
        $hash->{'night'}   = $2;
        $hash->{'day'}     = $3;
        $hash->{'h_temp'}  = $4;
        $hash->{'l_temp'}  = $5;
        $hash->{'night_w'} = $6;
        $hash->{'day_w'}   = $7;
        $count++;
        $content = $8;
	next if($hash->{'city'} =~/����/);
        &fmtprint( $hash, $destfile4 );
        $hash    = {};
        last if ( $count == 40 );
    }
#page II

    &printfooter($destfile4);
    &clearit($destfile4);

}
	
elsif ( $ARGV[0] eq 'E48' ) {
#################################

    open( F, $datafile_world48_1 ) or die "file $datafile_world48_1 does not exist!\n";
    undef $/;
    $contents = <F>;

    #print $content,"\n";
    if ( $contents =~ /<table.*(��������̨.*?ʱ.*?ʱ.*?ʱ)(.*?)<\/table>/si ) {
        $title   = $1;
        $content = $2;
        $content =~s/&nbsp;//sg;
    }
    else {
        $content = "no";
    }
    close(F);
    &printheader( $destfile5, $date, "�������48Сʱ����Ԥ��" );

    open( OUT, ">>$destfile5" ) or die;

    #������
    $title =~ s/%\s*//;
    print OUT "\t", $title;
    print OUT "
���������������ש������������������ש������������ש�����������������������
�� ��      �� ��   �� �� �� ��    �� �� �ȣ�C�� ��     �� �� �� ��      ��
�ǩ������������贈�������ש��������贈�����ש����贈���������ש�����������
��            �� ҹ ��  �� �� ��  ���� �� ����ߩ�  ҹ  ��  ��  ��  ��  ��
�ǩ������������贈�������贈�������贈�����贈���贈���������贈����������
";
    close(OUT);

    while ( $content =~
/<tr.*?>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>.*?<\/tr>(.*?<tr>.*)/si
      )
    {

        #if($aa=~/<tr><td.*?><font.*?>\s*(.*?)\s*<\/font>.*?<\/td><\/tr>/si){
        #	print $1,$2,$3,$4,$5,$6,$7,"\n";
        $count++;
        $hash->{'city'}    = $1;
        $hash->{'night'}   = $2;
        $hash->{'day'}     = $3;
        $hash->{'h_temp'}  = $4;
        $hash->{'l_temp'}  = $5;
        $hash->{'night_w'} = $6;
        $hash->{'day_w'}   = $7;
        $content = $8;
	next if($hash->{'city'} =~/����/);
        &fmtprint( $hash, $destfile5 );
        $hash    = {};
        last if ( $count == 49 );
    }
    
#page I
    $count=0;
    open( F, $datafile_world48_2 ) or die "file $datafile_world48_2 does not exist!\n";
    undef $/;
    $contents = <F>;

    #print $content,"\n";
    if ( $contents =~ /<table.*(��������̨.*?ʱ.*?ʱ.*?ʱ)(.*?)<\/table>/si ) {
        $title   = $1;
        $content = $2;
        $content =~s/&nbsp;//sg;
    }
    else {
        $content = "no";
    }
    close(F);
    while ( $content =~
/<tr.*?>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>.*?<\/tr>(.*?<tr>.*)/si
      )
    {

        #if($aa=~/<tr><td.*?><font.*?>\s*(.*?)\s*<\/font>.*?<\/td><\/tr>/si){
        #	print $1,$2,$3,$4,$5,$6,$7,"\n";
        $hash->{'city'}    = $1;
        $hash->{'night'}   = $2;
        $hash->{'day'}     = $3;
        $hash->{'h_temp'}  = $4;
        $hash->{'l_temp'}  = $5;
        $hash->{'night_w'} = $6;
        $hash->{'day_w'}   = $7;
        $count++;
        $content = $8;
	next if($hash->{'city'} =~/����/);
        &fmtprint( $hash, $destfile5 );
        $hash    = {};
        last if ( $count == 40 );
    }
#page II

    &printfooter($destfile5);
    &clearit($destfile5);
}
##############################################start end####
elsif ( $ARGV[0] eq 'T24' ) {


    open( F, $datafile_travel24_1 ) or die "file $datafile_travel24_1 does not exist!\n";
    undef $/;
    $contents = <F>;

    #print $content,"\n";
    if ( $contents =~ /<table.*(��������̨.*?ʱ.*?ʱ.*?ʱ)(.*?)<\/table>/si ) {
        $title   = $1;
        $content = $2;
        $content =~s/&nbsp;//sg;
    }
    else {
        $content = "no";
    }
    close(F);
    &printheader( $destfile6, $date, "���γ���24Сʱ����Ԥ��" );

    open( OUT, ">>$destfile6" ) or die;

    #������
    $title =~ s/%\s*//;
    print OUT "\t", $title;
    print OUT "
���������������ש������������������ש������������ש�����������������������
�� ��      �� ��   �� �� �� ��    �� �� �ȣ�C�� ��     �� �� �� ��      ��
�ǩ������������贈�������ש��������贈�����ש����贈���������ש�����������
��            �� ҹ ��  �� �� ��  ���� �� ����ߩ�  ҹ  ��  ��  ��  ��  ��
�ǩ������������贈�������贈�������贈�����贈���贈���������贈����������
";
    close(OUT);

    while ( $content =~
/<tr.*?>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>\s*<td.*?>\s*(.*?)\s*<\/td>.*?<\/tr>(.*?<tr>.*)/si
      )
    {

        #if($aa=~/<tr><td.*?><font.*?>\s*(.*?)\s*<\/font>.*?<\/td><\/tr>/si){
        #	print $1,$2,$3,$4,$5,$6,$7,"\n";
        $count++;
        $hash->{'city'}    = $1;
        $hash->{'night'}   = $2;
        $hash->{'day'}     = $3;
        $hash->{'h_temp'}  = $4;
        $hash->{'l_temp'}  = $5;
        $hash->{'night_w'} = $6;
        $hash->{'day_w'}   = $7;
        $content = $8;
	next if($hash->{'city'} =~/����/);
        &fmtprint( $hash, $destfile6 );
        $hash    = {};
        last if ( $count == 49 );
    }
    
    &printfooter($destfile6);
    &clearit($destfile6);

}

else {
    &usage;
}

#########################################################################
sub fmtprint {

    format FORMATLINE1 =
��@<<<<<<<<<<<��@<<<<<<<��@<<<<<<<��@<<<<<��@<<<��@<<<<<<<<<��@<<<<<<<<<��
	        $_[0]->{'city'},$_[0]->{'day'},$_[0]->{'night'},$_[0]->{'h_temp'},$_[0]->{'l_temp'},$_[0]->{'night_w'},$_[0]->{'day_w'}
.
    format FORMATLINE2 =
�ǩ������������贈�������贈�������贈�����贈���贈���������贈����������
.
    open( F, ">>$_[1]" ) or die;
    select F;
    $~ = "FORMATLINE1";
    write;
    $~ = "FORMATLINE2";
    write;
    close(F);

}

sub printfooter {
    my $footer = "��Programmed by qxb<qxb at smth> 2005/03/10,Modified by qxb,2006/11/10\n";
    open( F, ">>$_[0]" ) or die;
    print F
"���������������ߩ��������ߩ��������ߩ������ߩ����ߩ����������ߩ�����������\n";
    print F $footer;
    close(F);
}

sub printfooter2 {
    my $footer = "\n��Programmed by qxb<qxb at smth> 2005/03/10, Modified by qxb, 2006/11/10\n";
    open( F, ">>$_[0]" ) or die;
    print F $footer;
    close(F);
}

sub usage {
    print "$0 [I24|I48|I72|E24|E48|Ig|I10|E3]\n";
    print "\tI24\t����24Сʱ����Ԥ��\n";
    print "\tI48\t����48Сʱ����Ԥ��\n";
    print "\tI72\t����72Сʱ����Ԥ��\n";
    print "\tE24\t����24Сʱ����Ԥ��\n";
    print "\tE48\t����48Сʱ����Ԥ��\n";
    print "\tT24\t��Ҫ���γ���24Сʱ����Ԥ��\n";
    exit;
}

sub printheader {

    #&printtitle($file,$date,$type)
    my $file  = shift;
    my $date  = shift;
    my $title = shift;
    open( OUT, ">$file" ) or die;
    print OUT "From: lists\@cn-bbs.org (cn.bbs.*�Զ�����ϵͳ)\n";
    print OUT "Subject: [$date] $title\n";
    print OUT "Newsgroups: cn.bbs.admin.lists.weather\n";
    print OUT "Approved: control\@cn-bbs.org\n";
    print OUT "Mime-Version: 1.0\n";
    print OUT "Content-Type: text/plain; charset=\"gb2312\"\n";
    print OUT "Content-Transfer-Encoding: 8bit\n\n";
    close(OUT);
}
sub clearit{
#clearit($filename)
        my $temp="/tmp/weather";
        my $char1="�ǩ������������贈�������贈�������贈�����贈���贈���������贈����������";
        my $char2="��            ��        ��        ��      ��    ��          ��          ��";
        my $char3="���������������ߩ��������ߩ��������ߩ������ߩ����ߩ����������ߩ�����������";

        undef $/;
        open(FILE,$_[0]) or die "adsfjsd";
        open(FILE2,">$temp") or die "asdfsdfsdfdsfds";
        my $content=<FILE>;
       # $content=~s/$char1\s+$char2\s+$char1/$char1/g;
        $content=~s/$char1\s+$char2\s+//g;
        $content=~s/$char1\s+$char3/$char3/;
        print FILE2 $content;
        close(FILE);
        close(FILE2);
        unlink($_[0]);
        system("mv -f $temp $_[0]");
        return 1;
}
