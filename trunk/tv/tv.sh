#!/bin/sh
DAY=`date +%u`
rm -f $DAY.txt
lynx -display_charset=gb2312 -cmd_script=concmd "http://ent.sina.com.cn/tv/g/$DAY.html" >/dev/null

SEC1="�¡���"
SEC2="���Ӿ�"
SEC3="�硡Ӱ"
SEC4="�ۡ���"
SEC5="ר����"
SEC6="�塡��"
for i in `seq 1 6`; do
	eval NUM$i=\`awk \"/   \$SEC$i / {print NR}\" $DAY.txt\`
done
NUM7=`awk '/^     _/ {print NR}' $DAY.txt`

cd post
for i in `seq 1 6`; do
	cp -f ../head $i
	eval printf \"Subject: [\`date\|colrm 11\`] ȫ�����ӽ�Ŀ����ָ��\(\$SEC$i\)\\n\\n\" >>$i
	eval awk \" NR == \$NUM$i { print }\" ../$DAY.txt | eval sed -e \"s/\$SEC$i //g\" >>$i
	eval awk \" \( NR \> \$NUM$i \) \&\& \( NR \< \$NUM$((i+1)) \) { print }\" ../$DAY.txt >>$i
	/usr/local/news/bin/inews -h $i
done
