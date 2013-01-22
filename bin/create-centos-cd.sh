#!/bin/bash
# Mahyuddin Susanto <udienz@gmail.com>

LIST=$(mktemp)
TARGET=$(mktemp)

echo "finding iso"
find /ftp/centos/ -name '*.iso' | grep '[x86_64,i386].iso' > $LIST
#sed -e 's/\/ftp\/centos/\/ftp\/iso\/centos/g' $LIST > /tmp/coba

cat $LIST | while read isos
	do
	echo "subtitute"
	target=$(echo $isos | sed -e 's/\/ftp\/centos/\/ftp\/iso\/centos/g')	
	echo "linking $isos to $target"
	ln -s $isos $target
done
#/ftp/pub/mirror.centos.org/6.3/isos/x86_64/CentOS-6.3-x86_64-netinstall.iso
#ln -s . ftp

rm $LIST
