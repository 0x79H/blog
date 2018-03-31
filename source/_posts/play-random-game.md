title: 凭本事买的游戏为什么要玩
date: 2017-07-16 09:22:07
tags: [Steam,game]
---
当今年steam夏季促销完成后,随着身体的一阵抖动,顿时感觉索然无味了起来.

看着库里各种慈善包/免费领取的喜加一,想着这破博客的更新频率,我决定搞一个一个喜加一小游戏的游玩记录,玩玩各种"多半差评"的神奇游戏.

~~使用[steamdb.info](https://steamdb.info/calculator/)页面下方提供的"i'm feeling lucky"来实现.~~
<!--more-->
然而并不行,随机的只是在几个游戏中随机...

访问[steam](https://store.steampowered.com/dynamicstore/userdata/)获得账户游戏信息.其中rgOwnedApps即为所拥有游戏.

```python
from random import choice as roll
from os import system as shell
rgOwnedApps = [10,20,30,40,50,60,.....,635780]
shell('"C:/Program Files/Internet Explorer/iexplore.exe" \"steam://run/'+str(roll(rgOwnedApps))+'\"')
```