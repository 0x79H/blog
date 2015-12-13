title: Socxel | Pixel Soccer
date: 2017-07-19 15:41:11
tags: game
---
今天随机到的游戏是Socxel | Pixel Soccer
<iframe src="https://store.steampowered.com/widget/586190/" style="border:none;height:190px;width:100%;max-width:646px;"></iframe>
开发商是 BUG-Studio 😄 这名字好啊.
<!--more-->
## 0x01 简单游玩
游戏支持最大4人同时在一台电脑上游戏.

![进入游戏](https://steamuserimages-a.akamaihd.net/ugc/836958712904374506/CDFF35FB840FE8005A79B9033A4064DBA3660AB0/?pic1.jpg "进入游戏")

下面可以更改操控键位设置,并不是常见的wasd控制方向什么的,而是...

![啥都不做都赢了](https://steamuserimages-a.akamaihd.net/ugc/836958712904376477/21F5B11383251C1780C429311A7057A4EE1E2DF3/?pic2.jpg "啥都不做居然还能赢了")

btw,开了吧`1 vs AI`,摸索了半天都不知道用什么操控.然而我居然赢了...电脑经常把球踢进自己球门.所以这破游戏啥都不动只要是欧皇,对电脑怎么都赢了.

![按键](https://steamuserimages-a.akamaihd.net/ugc/836958712904378919/8B1A1F937B7690D771B009D8417FD8887E57943A/?pic3.jpg "按键提示")

这游戏丧心病狂的只用一个按键(图中有提示)来操作,如果你不按任何按键的话,游戏内的任务会在原地转圈;而当你按下游戏一开始提示的按键的话,游戏中的人物将向前冲,并改变转向.

## 0x02 意外发现
在游戏中准备用f12截图,却意外的发现打开了`Devtools` ,难道这游戏直接是用HTML5开发的嘛?

带着疑问大概看了下代码,发现了个关键字`c2canvasdiv` ,Google了下发现是一个游戏引擎 [Construct 2](https://www.scirra.com) . 

`Construct`是一个HTML5的游戏引擎,类似于`GameMaker`,但是相比感觉前者更强大一些.类似的我只知道unity3d可以导出为web格式,但是前两者拥有所见即所得的简单编辑模式,只需要动动手拖动一下就可以很轻易的制作一些简单的游戏.简单易用的程度也表现在,我甚至在网上找到了面向14岁+开展的培训班.

顺便一提,[Construct 2](http://store.steampowered.com/app/227240/)居然也在steam商店上架了.