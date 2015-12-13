title: 基于sh的简单爬虫
date: 2017-07-20 23:31:46
tags: Misc
---
对于我这种买不起vps的穷逼来说,免费$$不失为一个很好的解决方案.然而大部分在飞机场里的免费$$都是隔一段时间变更一下端口和密码.

爬虫什么的用py做的比较多一点,然而在路由器上那点可怜的空间并不足以装上py.遂查了资料上了shell的爬虫.
<!--more-->
多话不说.

    wget -t 1 -T 5 -q -O /tmp/auto_change_ss_xz https://xsjs.yhyhd.org/free-ss/
    select=`tr -cd 1-3 </dev/urandom | head -c 1`
    xhead='ss-body'
    xend='modal-footer'
    sed -i -e "1,/$xhead/d" -e "/$xend/,$ d" -e 's/&nbsp;/\n/g' /tmp/auto_change_ss_xz
    ss_server=$(cat /tmp/auto_change_ss_xz|sed "$(($select*13-9))p" -n|awk -F '[<>]' '{print $3}')
    ss_server_port=$(cat /tmp/auto_change_ss_xz|sed "$(($select*13-7))p" -n|awk -F '[<>]' '{print $3}')
    ss_method=$(cat /tmp/auto_change_ss_xz|sed "$(($select*13-5))p" -n|awk -F '[<>]' '{print $3}')
    ss_key=$(cat /tmp/auto_change_ss_xz|sed "$(($select*13-3))p" -n|awk -F '[<>]' '{print $3}')
    
核心代码就是这么多,其中遇到的几个问题:
2. sed/awk/grep就最后一个用过,前两个几乎没有用过,查了半天文档
1. 路由器上的shell不支持 `<<<`,最后用```$(...)```来代替了
3. wget默认重试和超时非常坑,在默认直接 `wget Url` 的情况下会默认重试 `900s*20次` .