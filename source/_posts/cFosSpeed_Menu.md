---
title: 如何在cfosspeed隱藏圖標+鼠標穿透的情況下調出菜單進行調整
date: 2017-03-30 23:56:10
tags: fix
---
编辑文件
C:\Users\<username>\AppData\Local\cFos\cFosSpeed\user_data.ini
```bash
...
[All]
ts_advice=10.22
autoarrange=3
hide_on_fullscreen=0
click_through=1   //鼠标穿透
trayicon=0    //托盘图标
...
```

或者直接带参数运行,调出菜单

```
cfosspeed.exe -context_menu
```
