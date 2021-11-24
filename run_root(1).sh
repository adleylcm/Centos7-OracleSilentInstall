#!/bin/bash
#Editd by FranckLee
#root用户/home目录下执行该脚本，首先要把zip安装包存放在home目录下
#根据实际情况配置把172.16.1.110更改为本机实际的IP
echo "172.16.1.110 orcl orcl"  >> /etc/hosts
cat >> /etc/sysconfig/network <<EOF
network=yes
hostname=orcl
EOF
#安装依赖文件，并配置基础文件
yum install -y binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel glibc glibc-common glibc-devel gcc gcc-c++ libaio-devel libaio libgcc libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel ksh numactl-devel zip unzip > /dev/null
#优化OS内核参数
cat >> /etc/sysctl.conf <<EOF
fs.file-max = 6815744
fs.aio-max-nr = 1048576
#内核参数kernel.shmall，内存16G时建议设为4194304类推8G应为2097152,类似4G:1048576
kernel.shmall = 1048576
#kernel.shmmax设置为物理内存的一半,8G:4294967296计算方式为4*1024*1024*1024，所以4G应为2147483648
kernel.shmmax = 2147483648
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 4194304
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF
#使参数生效
sysctl -p
#限制oracle用户可以使用的最大文件数，最大线程，最大内存等资源使用量。
cat >> /etc/security/limits.conf <<EOF
oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536
EOF
#用来验证登陆用的配置文件,pam验证，验证的规则就是在这里面定义的，如果符合才让你登陆。
cat >> /etc/pam.d/login <<EOF
session required /lib/security/pam_limits.so
session required pam_limits.so
EOF
#系统的变量相关。这里修改会对所有用户起作用。
cat >> /etc/profile <<EOF
if [ $USER = "oracle" ]; then
if [ $SHELL = "/bin/ksh" ]; then
ulimit -p 16384
ulimit -n 65536
else
ulimit -u 16384 -n 65536
fi
fi
EOF
#设置生效
source /etc/profile
#添加oracle用户组和用户
groupadd oinstall
groupadd dba
useradd -g oinstall -G dba oracle
#如果需要设置用户密码则跑这一句 passwd oracle(oracle)

#创建oracle安装目录
mkdir -p /u01/app/oracle/product/11.2.0/db_1
mkdir -p /u01/app/oracle/oradata
mkdir -p /u01/app/oraInventory
mkdir -p /u01/app/oracle/fast_recovery_area
chown -R oracle:oinstall /u01/app/oracle
chown -R oracle:oinstall /u01/app/oraInventory
chmod -R 755 /u01/app/oracle
chmod -R 755 /u01/app/oraInventory
#关闭防火墙
systemctl disable firewalld
systemctl stop firewalld
setenforce 0
sed -i 's/=enforcing/=disabled/g' /etc/selinux/config
#修改以下文件名为实际的安装包名,进入oracle目录后执行第二个脚本
mv /home/linux.x64_11gR2_database_1of2.zip /home/oracle
mv /home/linux.x64_11gR2_database_2of2.zip /home/oracle
mv run_oracle(2).sh /home/oracle
cd /home/oracle





