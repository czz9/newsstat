程序及配套文件列表：
1、topic20061024.pl，主程序，程序中以下参数请修改
	my $destTopFile = "day"; 最终生成的文件
	my $news_group  = "~news/db/active"; #新闻组列表,仅在该列表中的有效记录被统计，其余忽略
	my $ovdb_comm   = "ovdb_stat";  #ovdb_stat程序路径

2、cnnews.list，数据文件，被topic20061024.pl读取
	其中所有以#开头的行为注释行，空行忽略，仅考虑以cn开头的行

3、funcs.pl，主要函数文件，以下参数请修改
	my $ovdb_command="ovdb_stat";

4、blacklist，该文件和以前一样，无变化
	
