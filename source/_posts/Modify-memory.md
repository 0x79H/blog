title: 查找并修改游戏的内存数据
date: 2018-04-11 05:02:16
tags: [security,windows,game]
---

身为一个手残，小时候玩游戏经常不能通关，于是各种修改器即是我的选择。小时候会用一些什么金山游侠之类的本土修改器，但是使用过程中往往有一个问题：游戏重新开始，或者软件关了重开后上次搜索出来的结果就不能再次使用了。当时也是对这类问题一头雾水，只好使用别人做好的修改器。

</p><iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width="330" height="52" src="//music.163.com/outchain/player?type=2&id=28138236&auto=0&height=32"></iframe><p>


<!--more-->

# 使用Cheat Engine查找并修改数据


是个人都会的搜索-->改变数值-->继续搜索-->改变数值-->再搜索-->找到地址。

关键的步骤来了：找到正确地址后，通过下内存读取/内存写入断点找到修改此资源的汇编语句，通过该汇编语句寻找该地址的基地址与偏移量，并在此地址附近寻找有关资源数据。

## 寻找资源地址的基地址与偏移量

比如说，通过搜索寻找到了目标地址为 _0x6937d54_ ，通过下断点的方式找到了写入的汇编语句为 __movss [eax+0x04],xmm2__ ，其中 _eax=0x6937d54_。 那么这个eax的值即可能是基址，0x04即是偏移量。而这个eax是每个游戏进程，甚至每一局游戏都是不一样的，那么需要找到指向eax的指针，来确定新游戏中eax的值是多少，而不用每一局新游戏都进行一轮搜索了。

![经过多次重复上述步骤后的结果](/uploads/2018-04-11_1.png)

一般游戏的一类资源都是存在同一个结构体中，所以我们可以观察不同偏移量的内存数值是否即是我们需要寻找的其他数值，从而进行下一步操作。

## 在此地址附近寻找有关资源数据

![所要寻找的其他资源](/uploads/2018-04-11_2.png)

如图所示，我们即可很方便的寻找到此游戏的资源所在内存，并进行修改。

# 修改游戏流程实现自定义功能


搞定在CE内修改后，我们需要实现一些更智能的功能。我们可以控制流程来使得原本减少的变成不变不减少的，甚至可以增加。如上图在内存中patch了 *可用人口* 的代码，使得可用人口不变。

## 直接patch文件

直接修改文件，实现硬补丁。一般常见于游戏的"未加密版"与软件的"无限制版"上。

## 使用调试函数来进行内存的修改

即是使用如下三个函数

- OpenProcess
- ReadProcessMemory
- WriteProcessMemory

获取该程序运行后的基地址可以使用[这个办法](https://stackoverflow.com/questions/14467229/get-base-address-of-process)

## 通过注入DLL到进程来进行相关操作

注入了DLL后既可以修改内存，还可以调用游戏内现有的功能CALL。简直就是为所欲为。

我使用过的注入方法只有```CreateRemoteThread --> LoadLibrary```和```SetWindowsHookEx```

更多的注入方法有：NtCreateThreadEx/QueueUserAPC/RtlCreateUserThread/SetThreadContext/反射式DLL

```CreateRemoteThread --> LoadLibrary```就是字面意思，给指定进程创建一个新的线程，新的线程里进行载入DLL的操作

```SetWindowsHookEx```也是字面意思，在系统层面hook住相关函数，从而操作指定进程的流程。


# <p style="font-size:16px">参考资料</p>


[injectAllTheThings](https://github.com/fdiskyou/injectAllTheThings)

[CE Forum](http://forum.cheatengine.org/)