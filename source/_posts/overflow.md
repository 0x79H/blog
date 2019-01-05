title: PWN学习
date: 2018-12-31 22:53:11
tags: [security,asm]
---
# 前言

简单来说，pwn既是使用某种方法，修改内存中的数据，劫持程序的执行流程(即改变eip)，使程序执行我们的shellcode。shellcode可以简单理解为一串汇编代码对应的机器码，因为它通常就是用机器代码编写的。

对于*call _fun*与*jmp _fun*他们都会使*eip*变为对于_fun的地址；而对于*ret*它实际上就是*pop eip*，如果此时栈顶的数据为我们的shellcode的地址，就可以实现pwn。

而如何修改内存中的数据呢？大概主要就是字符读取的函数函数*gets()*和*scanf()*与其类似的函数、字符串处理函数*strcpy()*和*strcat()*等函数，所造成的缓冲区溢出，从而覆盖返回地址/对内存地址进行赋值操作了。

<!--more-->
# 一般方法

如果程序内有相应的功能函数，直接将*ret*时的栈顶esp，改为所选函数机器码开始的地址即可。

若没有相应的函数，则可将shellcode输入到堆栈内，并使*ret*时的栈顶esp改为shellcode开始的地址即可。其中shellcode的地址可通过*printf()*函数来泄露。

对于linux有PLT/POT表，对照结构，修改内存，可修改对应call的函数。

对于继承的class有一个叫做vptr的东西，根据其结构，修改内存中的函数地址，可修改所对应call的函数。

对于一些结构体(如链表)，通过uaf，也可修改指定内存位置的内容。

# DEP/NX

处理器和Linux系统有一种叫做NX(No eXecute)的技术，windows上对应的技术叫做DEP(Data Execution Prevention)，使得一些内存不能拥有*RWX*中的**X**执行属性。若尝试在不能执行的内存(如堆栈)中执行，则报错。

此时，可使用ROP(Return-oriented programming)技术。具体操作为寻找以*ret*结尾，有*pop/lea/mov*的内存地址。以*ret*为主体，构造一个ROP链接，达到修改寄存器并调用指定call的目的。

# ASLR/PIE
Linux系统有一种叫做PIE(Position-independent executables)的技术，windows上对应的技术叫做ALSR，使得程序中的内存地址不再固定，变得随机化了。同一个程序每次运行的内存地址，都会发生改变。

在ctf中一般通过地址泄露来获得相应的地址。

而在实际中，可使用一种叫做堆喷射(Heap Spraying)的技术。这种技术通过申请大量的内存空间，填充一些无意义的滑行指令，并将shellcode放到申请的内存空间的末端。这样，只要eip落到所申请的空间内，即可在执行一串无意义的滑行指令后，执行我们的shellcode。
典型的例子有：使用0x0c0c0c0c来填充内存空间，而其对应的汇编恰好为无意义的指令
```x86asm
0C0C0C0C | 0C 0C                | or      al, 0xC                    |
0C0C0C0E | 0C 0C                | or      al, 0xC                    |
```

# GS/Canaries
有一种叫做stack-protector 的技术，Linux系统中的gcc称之为为Canaries，windows上的cl称之为GS。即是在*return*前，检查堆栈上的一个于函数之前生成的随机数是否被改变。
要么在*return*前调用shellcode，要么通过泄露此随机数来使得检测通过。

有时候程序不退出，你甚至还能用这个来泄露地址。

# 杂项
使用*alpha_mixed*的encoders可生成由字母组成的shellcode，使用*--bad-chars*可排除一些字符

# <span class="_link" style="font-size:14px">参考资料</span>
[Pwn Overview](https://ctf-wiki.github.io/ctf-wiki/pwn/readme/)