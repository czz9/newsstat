#!/bin/sh
DAY=`date +%u`
rm -f $DAY.txt
lynx -display_charset=gb2312 -cmd_script=concmd "http://ent.sina.com.cn/tv/g/$DAY.html" >/dev/null

SEC1="新　闻"
SEC2="电视剧"
SEC3="电　影"
SEC4="综　艺"
SEC5="专　题"
SEC6="体　育"
for i in `seq 1 6`; do
	eval NUM$i=\`awk \"/   \$SEC$i / {print NR}\" $DAY.txt\`
done
NUM7=`awk '/^     _/ {print NR}' $DAY.txt`

cd post
for i in `seq 1 6`; do
	cp -f ../head $i
	eval printf \"Subject: [\`date\|colrm 11\`] 全国电视节目收视指南\(\$SEC$i\)\\n\\n\" >>$i
	eval awk \" NR == \$NUM$i { print }\" ../$DAY.txt | eval sed -e \"s/\$SEC$i //g\" >>$i
	eval awk \" \( NR \> \$NUM$i \) \&\& \( NR \< \$NUM$((i+1)) \) { print }\" ../$DAY.txt >>$i
	/usr/local/news/bin/inews -h $i
done
