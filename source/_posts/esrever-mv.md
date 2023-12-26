---
title: esrever-mv
date: 2019-06-23 18:22:56
tags: [asm,linux]
---
简单来说，就是被丢了道vm的题，说没writeup。搜了搜确实没有，于是摸了摸，发现适合入门。
# 查看调用栈
程序读取输入时，查看调用
```
(gdb) bt
#0  0x00000000004402b0 in ?? ()
#1  0x0000000000400ae1 in ?? ()
#2  0x00000000004010ba in ?? ()
#3  0x0000000000400659 in ?? ()
#4  0x0000000000401e26 in ?? ()
#5  0x000000000040201a in ?? ()
#6  0x0000000000400969 in ?? ()
```

# 分析流程
拖入ida
<!--more-->
- #0 0x00000000004402b0
    - 发现是_read
- #1 0x0000000000400ae1
    - 发现是判断`[rdi+10008h]`为0或1来进行read或write
- #2 0x00000000004010ba
    - 逻辑图看起来像是vm解析执行的函数
    - 发现字符串`"[MESSAGE] vm halt\n"`
    - case为29(0x1d)
- #3 0x0000000000400659
    - 发现分支中含有字符串`"Failed to create vm"`
    - 上方调用了两个静态变量，猜测为虚拟机代码、flag数据
- #4 0x0000000000401e26
    - libc

## 详细分析
### 分析#3所在的函数
分析#3所在函数`sub_4005F0`所调用的五个函数(#3为调用的第4个函数)
- 都调用了*[rsp+28h+var_18]*，猜测var_18为vm
- #3之上的两个函数功能是将两个静态变量复制到0x4000与0x6000.
- #3最上方的函数之后有判断是否成功，且失败会提示`"Failed to create vm"`，则猜测为创建vm的函数
- #3之下的函数判断为销毁虚拟机

### 分析#2所在的虚拟机执行函数
分析#2所在的虚拟机执行函数
- `[rbx+10026h]`自增4，推断为ip.且由此判断vm指令为定长，长度为4.
- 发现循环判断`rdi+8`.推断为解释器执行内存位置
- 推断指令为`db opcode,db args[1],dw args[2]`，其中args[1]的高四位为一个参数(r8b)，低四位为一个参数(r10d)，args[2]为一个参数(r11d)
- 分析opcode为0x1时发现，`[rdi+10018h]`为vm寄存器首地址
    
```asm
.text:0000000000400FBB 48 8D AF 18 00+                lea     rbp, [rdi+10018h]
.......
.text:0000000000400FB4 4C 8D 6F 10                    lea     r13, [rdi+10h]  ; r13=base_addr
.......
.text:0000000000400FF0                loc_400FF0:
.text:0000000000400FF0 83 EE 01                       sub     esi, 1
.text:0000000000400FF3 0F B7 83 26 00+                movzx   eax, word ptr [rbx+10026h]
.text:0000000000400FFA 66 83 F8 FC                    cmp     ax, 0FFFCh
.text:0000000000400FFE 0F 87 BC 05 00+                ja      loc_4015C0
.text:0000000000401004 0F B7 F8                       movzx   edi, ax         ; rdi=ip
.text:0000000000401007 4C 01 EF                       add     rdi, r13
.text:000000000040100A 4C 8D 4F 08                    lea     r9, [rdi+8]     ; base_addr+8+ip
.text:000000000040100E 41 0F B6 51 01                 movzx   edx, byte ptr [r9+1]  ;args[1]
.text:0000000000401013 41 0F B7 49 02                 movzx   ecx, word ptr [r9+2]  ;args[2]
.text:0000000000401018 41 89 D0                       mov     r8d, edx
.text:000000000040101B 41 89 D2                       mov     r10d, edx
.text:000000000040101E 41 89 CB                       mov     r11d, ecx
.text:0000000000401021 41 C0 E8 04                    shr     r8b, 4          ; t1 = args[1] >> 4;
.text:0000000000401025 41 83 E2 0F                    and     r10d, 0Fh       ; t2 = args[1] & 0xf
.text:0000000000401029 41 83 E3 07                    and     r11d, 7         ; t3 = args[2] & 7
.......
.text:0000000000401080 83 C0 04                       add     eax, 4          ; [rbx+10026h]+=4
.text:0000000000401083 83 FE 00                       cmp     esi, 0
.text:0000000000401086 66 89 83 26 00+                mov     [rbx+10026h], ax
.text:000000000040108D 0F 8F 5D FF FF+                jg      loc_400FF0
```

# 分析opcode
## 分析调用的0x1d
简单来说就是判断[rdi+10008h]的值
- 为1，则将[rdi+1000Ah]的值调用write输出
- 为0，则将调用read，并将输入的值填充到[rbx+10018h].

```asm
.text:00000000004010B0                loc_4010B0:                             ; CODE XREF: _zz_execute+A7↑j
.text:00000000004010B0                                                        ; DATA XREF: .rodata:off_4A23C0↓o
.text:00000000004010B0 89 74 24 0C                    mov     [rsp+38h+var_2C], esi ; jumptable 0000000000401047 case 29
.text:00000000004010B4 4C 89 EF                       mov     rdi, r13              ;
.text:00000000004010B7 FF 53 08                       call    qword ptr [rbx+8]     ;调用#1所在函数
.text:00000000004010BA 8B 74 24 0C                    mov     esi, [rsp+38h+var_2C]
.text:00000000004010BE 66 89 83 18 00+                mov     [rbx+10018h], ax      ;返回值->[rbx+10018h]
.text:00000000004010C5 0F B7 83 26 00+                movzx   eax, word ptr [rbx+10026h]
.text:00000000004010CC EB B2                          jmp     short loc_401080 ; jumptable 0000000000401047 case 0
```

## 分析0x1
简单来说就是: *[rdi+10018h+t1*2]=-*[rdi+10018h+t2*2]
```asm
.text:0000000000400FBB 48 8D AF 18 00+                lea     rbp, [rdi+10018h]
......
.text:0000000000401510                loc_401510:                             ; CODE XREF: _zz_execute+A7↑j
.text:0000000000401510                                                        ; DATA XREF: .rodata:off_4A23C0↓o
.text:0000000000401510 45 0F B6 D2                    movzx   r10d, r10b      ; jumptable 0000000000401047 case 1
.text:0000000000401514 45 0F B6 C0                    movzx   r8d, r8b
.text:0000000000401518 42 0F B7 44 55+                movzx   eax, word ptr [rbp+r10*2+0]
.text:000000000040151E F7 D8                          neg     eax             ; 取反
.text:0000000000401520 66 42 89 44 45+                mov     [rbp+r8*2+0], ax
.text:0000000000401526 0F B7 83 26 00+                movzx   eax, word ptr [rbx+10026h]
.text:000000000040152D E9 4E FB FF FF                 jmp     loc_401080      ; jumptable 0000000000401047 case 0
```

## 分析其他
同上，以此类推。根据执行的vm代码，只需要分析`0x1e,0x17,0x03,0x13,0x1d,0x19,0x18,0x0f,0x03,0x01,0x0a,0x11`这12个opcode即可。

# 分析vm代码
vm数据段(vm:0x6000)(.data:00000000006CC0A0)
vm代码段(vm:0x4000)(.data:00000000006CC0E0)
```asm
case_0x1e, t0__t0, 0       ;t0=rand()                    \
case_0x17, t0__t0, 8       ;if t0 == 0 then ip+2*4        |
case_0x03, t0__t0, 0FFFFh  ;t0 = t0 + 0xffff              |
case_0x03, IP__IP, 0FFF4h  ;IP = IP + 0xfff4 = IP - 3*4  /
case_0x03, IP__IP, 0Ch     ;IP = IP + 3*4 (to 0x9)
case_0x13, t0__t0, 1       ;t0 = 1
case_0x1d, t0__t0, 0       ;write(STDOUT_FILENO,t1,1)(cauz t0=1)
case_0x19, t0__t0, 0       ;
case_0x13, t1__t0, 49h     ;t1=0x49("I")
case_0x18, t0__t0, 0FFECh  ;CALL 0xffec= ip + 0xffec = ip - 5*4 (to 0x6)
......
case_0x18, t0__t0, 0FF94h  ;[9-32]"Input flag:"(0x49,0x6E,0x70,0x75,0x74,0x20,0x66,0x6C,0x61,0x67,0x3A,0x20)
case_0x13, t4__t0, 0       ;t4=0
case_0x0f, t1__t4, 6000h   ;t1=&data[0x3C]+t4                               -- loop start
case_0x03, t4__t4, 1       ;t4=t4+1 -> t4++
case_0x03, t1__t1, 0FFh    ;t1=t1&0xff
case_0x17, t1__t0, 88h     ;if t1 == 0 then ip + 34*4                       -- right
case_0x13, t0__t0, 0       ;t0=0                       \
case_0x1d, t0__t0, 0       ;read(STDIN_FILENO,&t0)     /
case_0x01, t0__t0, 0       ;t0=-t0
case_0x03, t0__t0, 0FFh    ;t0=t0&0xff
case_0x0a, t0__t0, 1       ;t0=t0^t1
case_0x17, t0__t0, 0FFD8h  ;if t0 == 0 then ip +0xffd8 = ip-10*4 (to 34)    -- loop 
case_0x13, t1__t0, 42h     ;t1=0x42("B")
case_0x13, t0__t0, 1       ;t0=0x1
......
case_0x1d, t0__t0, 0       ;[44-70]"Bad flag"(0x42,0x61,0x64,0x20,0x66,0x6C,0x61,0x67,0x0A)
case_0x11, t0__t0, 0       ;------
case_0x13, t1__t0, 47h     ;t1=0x47("G")
case_0x13, t0__t0, 1       ;t0=0x1
case_0x1d, t0__t0, 0       ;write(STDOUT_FILENO,t1,1)
......
case_0x1d, t0__t0, 0       ;[72-99]"Good flag"(0x47,0x6F,0x6F,0x64,0x20,0x66,0x6C,0x61,0x67,0x0A)
case_0x11, t0__t0, 0       ;------
;print("".join([chr(0x100-i) for i in _data]))
```

# 其他
然而，差不多搞完了才发现作者把writeup都丢到脸上了:[gayhub](https://github.com/Inndy/zzvm)

