title: 实时抓取Android上的网卡数据包
date: 2019-03-25 17:08:03
tags: [linux,Android,arm64,wireshark,tcpdump]
---
# 缘由
一个apk,上burp死活抓不到数据包,应用还正常.
想开wifi热点抓,结果我那破红米不支持5g,win10的热点老是开到5g上,行不通,只能想其他方法.

# 非实时
tcpdump直接抓
但是不够优雅,不能实时反应过来,而且也没wireshark易用

# 实时
## wifi热点法
垃圾红米手机和win10配不上.

## 管道法
老早之前记得看过有人用pipe来将抓包的数据实时重定向到wireshark.
<!--more-->
找了找,发现了[这篇文章](https://www.freebuf.com/articles/wireless/6517.html).既是用ADVsock2pipe来将Android转发来的socket重定向为一个pipe,让wireshark认为是一个设备.
```
tcpdump -nn -w - -U -s 0 -i wlan0 | nc <ip> 6666
ADVsock2pipe.exe -pipe=pipeName -port 6666
< choose \\.\pipe\pipeName in wireshark >
```


## socket法
就是把pipe换成了nc接受后重定向
```
tcpdump -n -s 0 -i wlan0 -w -| nc -l -p 7101
adb forward tcp:6100 tcp:7101
D:\backup\tools\msys64\usr\bin\nc.exe 127.0.0.1 6100 | "C:\Program Files\Wireshark\wireshark.exe" -k -S -i -
```

## RPCAP协议法
在wireshark里发现了**[Remote Capture Interfaces](https://www.wireshark.org/docs/wsug_html_chunked/ChCapInterfaceRemoteSection.html)**,直接填tcpdump重定向过来的socket是不行的,查了查,发现是用了一种叫做[rpcap](http://rpcap.sourceforge.net/)的玩意.直接交叉编译相应的版本丢过去运行就ok了.
分别找到并尝试了以下版本
```
# winpcap (libpcap1.0.0)
wget https://www.winpcap.org/install/bin/WpcapSrc_4_1_3.zip
unzip -a WpcapSrc_4_1_3.zip
cd winpcap/wpcap/libpcap
# tcpdump lastest version (libpcap 1.9.0)
wget https://www.tcpdump.org/release/libpcap-1.9.0.tar.gz
tar -xzvf libpcap-1.9.0.tar.gz
cd libpcap-1.9.0 
# github (libpcap 1.10.0-PRE-GIT) 20190418
git clone https://github.com/the-tcpdump-group/libpcap.git
cd libpcap
```

### ubuntu x86_64
```
sudo apt-get install libbluetooth-dev -y 
cd winpcap/libpcap
./configure && make 
cd rpcap
sed -i -e 's/\(-ldbus-1\)/\1 -lcrypt/g' -e 's/\.\(\.\/rpcap\)/\1/g' \
    -e 's/\.\(\.\/sockut\)/\1/g' -e 's/\.\(\.\/sslut\)/\1/g' Makefile
make
./rpcap
```

理论上可以用*configure*来直接设置好*Makefile*的内容,但是**--with-libs**只能解决一部分问题,其余不清楚怎么解决.索性直接上sed了.
**直接在./configure的时候加上--enable-remote即可**

### arm
选择arm编译器:
- [ ] gcc-arm-linux-androideabi
- [x] gcc-arm-linux-gnueabi

指定host就完事了
```
apt-get install gcc-arm-linux-gnueabi g++-arm-linux-gnueabi
./configure --host=arm-linux-gnueabi --enable-remote
make
```
dynamically linked的rpcapd
```
0x79h@ubuntu:~/work/libpcap/rpcapd$ file rpcapd
rpcapd: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.3,\
  for GNU/Linux 3.2.0, BuildID[sha1]=1510cf4facd84b9e9bbb325f0e94313a1733b73e, not stripped

riva:/data/local/tmp # ./rpcapd4
/system/bin/sh: ./rpcapd4: No such file or directory
```
此时并不能运行,偷一下Makefile编译的命令行,然后上static静态编译即可
```
0x79h@ubuntu:~/work/libpcap/rpcapd$arm-linux-gnueabi-gcc -fvisibility=hidden -g -O2 -o rpcapd daemon.o \
    fileconf.o log.o rpcapd.o ../rpcap-protocol.o ../sockutils.o ../fmtutils.o ../sslutils.o ../libpcap.a\
    -lcrypt -lpthread -static
0x79h@ubuntu:~/work/libpcap/rpcapd$ file rpcapd
rpcapd: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), statically linked, for GNU/Linux 3.2.0,\
    BuildID[sha1]=aefc4fd77f1c82b86f103ec4f926b5af2fad787a, not stripped
0x79h@ubuntu:~/work/libpcap/rpcapd$ upx rpcapd
                       Ultimate Packer for eXecutables
                          Copyright (C) 1996 - 2013
UPX 3.91        Markus Oberhumer, Laszlo Molnar & John Reiser   Sep 30th 2013

        File size         Ratio      Format      Name
   --------------------   ------   -----------   -----------
   2078356 ->    901764   43.39%   linux/armel   rpcapd                        

Packed 1 file.


riva:/data/local/tmp # ./x -n -D
Press CTRL + C to stop the server...
```


# 结果
那破apk协议走的是udp,怪不得抓不到.