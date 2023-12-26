---
﻿title: Windows下好用的shell--msys2
date: 2017-07-15 22:40:26
tags: [linux,shell,windows，msys2]
---
对于我这个linux伪粉来说,Windows下的cmd真的难用.在对比了多种同类型的工具(Gow,cygwin等)后,我选择了msys2.
## 安装
国内镜像
http://mirrors.ustc.edu.cn/msys2/distrib/
官方源
http://repo.msys2.org/distrib/
<!--more-->
## 配置镜像以加速下载安装
于 /etc/pacman.d/mirrorlist.mingw32 文件开头添加：
```
Server = http://mirrors.ustc.edu.cn/msys2/mingw/i686```
于 /etc/pacman.d/mirrorlist.mingw64 文件开头添加：
```
Server = http://mirrors.ustc.edu.cn/msys2/mingw/x86_64```
于/etc/pacman.d/mirrorlist.msys 文件开头添加：
```
Server = http://mirrors.ustc.edu.cn/msys2/msys/$arch```
## 更新组件
msys2使用pacman来管理包,即
```
pacman -Syu```
第一次更新需要杀掉终端,重启后再更新一次

更新完成后使用pacman -Scc清理空间

## 替换默认bash为zsh
安装zsh
```
pacman -S zsh```

配置[Oh My Zsh](http://ohmyz.sh)

```
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
```

替换默认bash为zsh
于mingw32.ini/mingw64.ini/msys2.ini末尾添加
```
SHELL=/usr/bin/zsh```

## 安装中文man
```
wget https://www.archlinux.org/packages/community/any/man-pages-zh_cn/download/
pacman -U man-pages-zh_cn-1.6.3.3-1-any.pkg.tar.xz
```


## 其他杂项
于.bashrc内取消大部分注释
于pacman.conf内删除`CheckSpace`并添加`ILoveCandy`😄

## 参考链接
https://wiki.archlinux.org/index.php/Pacman
https://superuser.com/questions/961699/change-default-shell-on-msys2

