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
老早之前记得看过有人用pipe来将抓包的数据实时重定向到wireshark,找了找,发现了[这篇文章](https://www.freebuf.com/articles/wireless/6517.html).既是用ADVsock2pipe来将Android转发来的socket重定向为一个pipe,让wireshark认为是一个设备.
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

交叉编译未完待续(其实是菜没交叉编译过

# 结果
那破apk协议走的是udp,怪不得抓不到.