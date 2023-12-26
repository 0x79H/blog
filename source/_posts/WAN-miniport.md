---
title: 修复由于WAN_Miniport导致的网络问题
date: 2016-02-04 13:58:09
tags: [windows,fix]
---
在硬件管理器中出现了’WAN_Miniport（\*）'，这六个理论上应该是 ~~隐藏的，~~ 没有错误的，但是有时候就会莫名其妙的出现好几个 WAN Miniport (IPv6 L2TP Network_Monitor PPPOE PPTP SSTP)，出现的原因很多，不过我见过的最多的就是xxx加速器/校园宽带客户端引起的。

修复方法:
1.打开设备管理器，右键WAN_Miniport，选择更新驱动。
2.选择下面那个”浏览我的计算机xxxxxxx”
3.点下面那个”兼容设备”
4.勾掉”显示xxx”的复选框
5.左边选”Microsoft”，右边选”Microsoft KM-TEST Loopback Adapter“或者”Generic Mobile Broadband Adapter“
6.确定，完成。然后右键WAN_Miniport，卸载。
7.重复以上步骤，直到将所有WAN_Miniport都做一遍。
8.重启电脑。
9.打开设备管理器，扫描硬件。
10.完成

或者

[下载我](http://download.microsoft.com/download/D/9/2/D923C013-E9AD-4BBE-A52C-AC1F16685036/MicrosoftFixit20114.mini.diagcab)

