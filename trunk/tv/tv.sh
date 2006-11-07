#!/bin/sh
DAY=$(date +%u)
rm -f $DAY.txt
lynx -width 160 -term linux -cmd_script concmd "http://ent.sina.com.cn/tv/g/$DAY.html" >/dev/null
#lynx -term linux -cmd_script concmd "http://all.163.com/entertainment/tv/$DAY.htm" >/dev/null

SEC1="新　闻"
NUM1=$(grep "   $SEC1" $DAY.txt -n|cut -d':' -f1)
SEC2="电视剧"
NUM2=$(grep "   $SEC2" $DAY.txt -n|cut -d':' -f1)
SEC3="电　影"
NUM3=$(grep "   $SEC3" $DAY.txt -n|cut -d':' -f1)
SEC4="综　艺"
NUM4=$(grep "   $SEC4" $DAY.txt -n|cut -d':' -f1)
SEC5="专　题"
NUM5=$(grep "   $SEC5" $DAY.txt -n|cut -d':' -f1)
SEC6="体　育"
NUM6=$(grep "   $SEC6" $DAY.txt -n|cut -d':' -f1)
NUM7=$(wc -l $DAY.txt|awk '{print $1}')

cd post
for i in *; do
	/bin/cp -f ../head $i
done
echo "Subject: [`date|colrm 11`] 全国电视节目收视指南(新闻类)" >>news;
echo >>news;
head -n $(($NUM2 - 1)) ../$DAY.txt|tail -n $(($NUM2 - $NUM1)) >>news
echo "Subject: [`date|colrm 11`] 全国电视节目收视指南(电视剧类)" >>series;
echo >>series;
head -n $(($NUM3 - 1)) ../$DAY.txt|tail -n $(($NUM3 - $NUM2)) >>series
echo "Subject: [`date|colrm 11`] 全国电视节目收视指南(电影类)" >>movie;
echo >>movie;
head -n $(($NUM4 - 1)) ../$DAY.txt|tail -n $(($NUM4 - $NUM3)) >>movie
echo "Subject: [`date|colrm 11`] 全国电视节目收视指南(综艺类)" >>ent;
echo >>ent;
head -n $(($NUM5 - 1)) ../$DAY.txt|tail -n $(($NUM5 - $NUM4)) >>ent
echo "Subject: [`date|colrm 11`] 全国电视节目收视指南(专题类)" >>special;
echo >>special;
head -n $(($NUM6 - 1)) ../$DAY.txt|tail -n $(($NUM6 - $NUM5)) >>special
echo "Subject: [`date|colrm 11`] 全国电视节目收视指南(体育类)" >>sport;
echo >>sport;
head -n $(($NUM7 - 1)) ../$DAY.txt|tail -n $(($NUM7 - $NUM6)) >>sport

for i in *; do
	~news/bin/inews -h $i
#	/bin/rm $i
done
