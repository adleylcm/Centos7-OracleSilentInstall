#!/bin/bash
YUMPATH=/etc/yum.repos.d;
mkdir /mnt/cdrom 
mount /dev/cdrom /mnt/cdrom
rm -rf $YUMPATH/*
echo "
[CentOS7]                  
name=CentOS-local          
baseurl=file:///mnt/cdrom      
enabled=1                  
gpgcheck=1             
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7 "> $YUMPATH/CentOS-local.repo;
yum clean all
yum makecache
yum list
exit 0
