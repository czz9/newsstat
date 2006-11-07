#!/bin/sh
DAY=$(date +%u)
rm -f $DAY.txt
lynx -width 160 -term linux -cmd_script concmd "http://ent.sina.com.cn/tv/g/$DAY.html" >/dev/null
#lynx -term linux -cmd_script concmd "http://all.163.com/entertainment/tv/$DAY.htm" >/dev/null

SEC1="�¡���"
NUM1=$(grep "   $SEC1" $DAY.txt -n|cut -d':' -f1)
SEC2="���Ӿ�"
NUM2=$(grep "   $SEC2" $DAY.txt -n|cut -d':' -f1)
SEC3="�硡Ӱ"
NUM3=$(grep "   $SEC3" $DAY.txt -n|cut -d':' -f1)
SEC4="�ۡ���"
NUM4=$(grep "   $SEC4" $DAY.txt -n|cut -d':' -f1)
SEC5="ר����"
NUM5=$(grep "   $SEC5" $DAY.txt -n|cut -d':' -f1)
SEC6="�塡��"
NUM6=$(grep "   $SEC6" $DAY.txt -n|cut -d':' -f1)
NUM7=$(wc -l $DAY.txt|awk '{print $1}')

cd post
for i in *; do
	/bin/cp -f ../head $i
done
echo "Subject: [`date|colrm 11`] ȫ�����ӽ�Ŀ����ָ��(������)" >>news;
echo >>news;
head -n $(($NUM2 - 1)) ../$DAY.txt|tail -n $(($NUM2 - $NUM1)) >>news
echo "Subject: [`date|colrm 11`] ȫ�����ӽ�Ŀ����ָ��(���Ӿ���)" >>series;
echo >>series;
head -n $(($NUM3 - 1)) ../$DAY.txt|tail -n $(($NUM3 - $NUM2)) >>series
echo "Subject: [`date|colrm 11`] ȫ�����ӽ�Ŀ����ָ��(��Ӱ��)" >>movie;
echo >>movie;
head -n $(($NUM4 - 1)) ../$DAY.txt|tail -n $(($NUM4 - $NUM3)) >>movie
echo "Subject: [`date|colrm 11`] ȫ�����ӽ�Ŀ����ָ��(������)" >>ent;
echo >>ent;
head -n $(($NUM5 - 1)) ../$DAY.txt|tail -n $(($NUM5 - $NUM4)) >>ent
echo "Subject: [`date|colrm 11`] ȫ�����ӽ�Ŀ����ָ��(ר����)" >>special;
echo >>special;
head -n $(($NUM6 - 1)) ../$DAY.txt|tail -n $(($NUM6 - $NUM5)) >>special
echo "Subject: [`date|colrm 11`] ȫ�����ӽ�Ŀ����ָ��(������)" >>sport;
echo >>sport;
head -n $(($NUM7 - 1)) ../$DAY.txt|tail -n $(($NUM7 - $NUM6)) >>sport

for i in *; do
	~news/bin/inews -h $i
#	/bin/rm $i
done
