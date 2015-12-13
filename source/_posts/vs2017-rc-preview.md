title: vs2017 rc 初体验
date: 2016-12-04 20:07:28
tags: Misc
---
早几日听说vs2017 Rc已经可以[下载](https://www.visualstudio.com/vs/visual-studio-2017-rc/)了，今日下载了下来玩了下。
## 默认全部在线安装
![一个在线安装的安装程序](/uploads/2016-12-04_1.png "全新的在线安装的安装程序")
我已经开始了下载，并准备做好去蹲坑的准备,结果我刚拿上了纸就听到了下载完成的提示声音。
![837 kb](/uploads/2016-12-04_2.png "大小仅仅有837 kb")
<!--more-->
## 新的安装界面和选择组件方式
感觉vs2017外在改变最大的就是这个安装界面了，曾经有这么一个说法：vs是非常庞大(亦或者是臃肿?)的，不仅仅是他的功能强大，还有他强大的占用空间。有时候我们仅仅需要使用其来进行一个方向的开发，但是vs其默认安装总是安装一些我们一般并不需要的功能。这一点在2017中有了极大改善。新版安装界面比之前我用过的几个版本相比简直就是两个软件，改变了在我眼中vs一贯臃肿的看法。
![默认的分组](/uploads/2016-12-04_6.png "默认的分组")
![安装时下载的界面与速度](/uploads/2016-12-04_4.png "安装中...")
速度还是能看的，至少比android studio好多了，我安装的时候能把带宽跑满。

## 离线安装
官方提供了下载离线安装包的[方法](https://www.visualstudio.com/zh-CN/news/releasenotes/vs2017-relnotes#a-idwillow-anew-installation-experience)
  ```
  vs_enterprise.exe --layout c:\download_path\ --lang zh-CN
  ```
其中若不填写路径，则下载到当前路径。


## 还保留有windows XP support for c艹
![windows XP support for c++](/uploads/2016-12-04_5.png)
虽然对于xp，微软已经停止了发布补丁，但是我们仍然可以在最新版的vs2017中看到微软为了兼容旧版本所保修的组件。

