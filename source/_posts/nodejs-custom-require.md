---
title: nodejs的require载入自定义类型文件
date: 2019-09-27 17:27:13
tags: [nodejs, docker]
---
tl;dr
> 参考require的函数内部流程,通过`require.extensions['ext']`可以自定义require的流程


简单来说,就是因为有个程序有bug,懒得反馈官方,我朋友让我大概在半年前看了个nodejs写的东西.

该程序是用docker一键搭建的,使用`docker exec -it <id> bash`进入容器查看相关信息.大部分源码可见,但是一些关键功能的源码却不可见.

<!--more-->

稍微跟了下,发现启动点是`node node_modules/ep_etherpad-Iite/node/server.js online`,使用debug单步启动后,活用`debugger`,使用二分法,发现了在载入了某个文件后,`windows`全局变量中存在可用的目标函数.

继续跟踪,  踩了很多坑后, 发现在载入`log4js`模块后即可载入特殊后缀的文件,发现有:
```javascript
var teakkl = require('teakkl_express');
var ext = ['.t', 'e', 'a', 'k', 'kl'].join('');
var kky = ['ex', 'ten', 'si', 'ons'].join('');
var kky2 = ['_', 'co', 'mp', 'ile'].join('');
var fs = require('fs');
var a = {
  ha() {
      var me = this;
      require[kky][ext] = function (m, filename) {
        var content = teakkl.de(fs.readFileSync(filename, 'utf-8'));
        m[kky2](content, filename);
      };
  }
};
a.ha();
```
搜了搜,发现这里是关键. 参考[这里](http://nodejs.cn/api/modules/require_extensions.html), 发现这里动态对require的某一个特殊后缀的文件载入函数进行了重写. 很好用(但是从`nodejs v0.10.6`起被弃用)

参考流程与解密函数,发现key为一看上去像是正常js的文件(...),编写脚本对所有特殊后缀的文件使用aes-256-cbc算法进行解密.此时发现可找到相关函数.至此结束.

另外大概看了看,发现该程序有两个与外部通信的通道:一个是/proBuy:看名字应该是联网校验cdkey,一个是/proMonitor:看名字应该是合法上报服务器信息吧.



