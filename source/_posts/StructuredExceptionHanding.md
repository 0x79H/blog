---
title: SEH
date: 2019-01-16 19:03:10
tags: [windows,shellcode]
---

Structured Exception Handling,即SEH,是windows的异常处理机制.官方已不建议使用SEH,而是用ISO标准的c++异常处理.但是因为要向前兼容,所以在windows下SEH还是可以使用的,除了系统的代码大量使用以外,自己在一些特殊情况下,也是非常好用的.

也是一些基础啦.
<!--more-->

# SEH结构
SEH其实说穿了就是几个结构体,然后window根据结构体的信息来进行相应处理.
即定义SEH的结构体*ntdll!_EXCEPTION_REGISTRATION_RECORD*,与SEH处理异常接受异常信息的结构体*VCRUNTIME140!_EXCEPTION_RECORD*
大致既是:
*_EXCEPTION_REGISTRATION_RECORD->handle->_except_handler4->_except_handler4_common()->_EXCEPTION_RECORD*

```
//winseh.cpp
int main()
{
    std::cout << "Hello World!\n";
    __try
    {
        _asm {
            mov eax, 0
            mov [eax], 0
        };
    }
    __except(EXCEPTION_EXECUTE_HANDLER){
        MessageBox(NULL, NULL, NULL, NULL);
    }
}
----------
0:000> u winseh!main l40
winseh!main [c:\users\root\source\repos\winseh\winseh\winseh.cpp @ 9]:
010f1000 55              push    ebp
010f1001 8bec            mov     ebp,esp
010f1003 6afe            push    0FFFFFFFEh
010f1005 6838250f01      push    offset winseh!__rtc_tzz+0x4 (010f2538)
010f100a 6885130f01      push    offset winseh!_except_handler4 (010f1385)--+//seh->Handler
010f100f 64a100000000    mov     eax,dword ptr fs:[00000000h]---------------+//seh->Next
010f1015 50              push    eax                           <--push fs:[0]
010f1016 83ec08          sub     esp,8
010f1019 53              push    ebx
010f101a 56              push    esi
010f101b 57              push    edi
010f101c a104300f01      mov     eax,dword ptr [winseh!__security_cookie (010f3004)]
010f1021 3145f8          xor     dword ptr [ebp-8],eax
010f1024 33c5            xor     eax,ebp
010f1026 50              push    eax
010f1027 8d45f0          lea     eax,[ebp-10h]                <--0x010f1015
010f102a 64a300000000    mov     dword ptr fs:[00000000h],eax <--SEH链最后的结构地址
010f1030 8965e8          mov     dword ptr [ebp-18h],esp
010f1033 8b0d34200f01    mov     ecx,dword ptr [winseh!_imp_?coutstd (010f2034)]
010f1039 e852000000      call    winseh!std::operator<<<std::char_traits<char> > (010f1090)
010f103e c745fc00000000  mov     dword ptr [ebp-4],0
010f1045 b800000000      mov     eax,0 <----
010f104a c60000          mov     byte ptr [eax],0  
010f104d eb17            jmp     winseh!main+0x66 (010f1066)
010f104f b801000000      mov     eax,1
0:000> bp 010f1045
0:000> r
----------
//seh链 此处为fs:[0]->0x00b5fba0->0x00b5fc0c->0x00b5fc24->0xffffffff
//所对应的处理函数为: 0x010f1385->0x010f1385->0x77a186d0->0x77a25196
0:000> !exchain 
00b5fb58: winseh!_except_handler4+0 (010f1385) 
  CRT scope  0, filter: winseh!main+4f (010f104f)
                func:   winseh!main+55 (010f1055)
00b5fba0: winseh!_except_handler4+0 (010f1385)
  CRT scope  0, filter: winseh!__scrt_common_main_seh+127 (010f15a5)
                func:   winseh!__scrt_common_main_seh+13b (010f15b9)
00b5fc0c: ntdll!_except_handler4+0 (77a186d0)
  CRT scope  0, filter: ntdll!__RtlUserThreadStart+3c97b (77a42f79)
                func:   ntdll!__RtlUserThreadStart+3ca17 (77a43015)
00b5fc24: ntdll!FinalExceptionHandlerPad22+0 (77a25196)
Invalid exception stack at ffffffff
------------
0:000> dt ntdll!_EXCEPTION_REGISTRATION_RECORD
   +0x000 Next             : Ptr32 _EXCEPTION_REGISTRATION_RECORD //下一个SEH结构地址
   +0x004 Handler          : Ptr32     _EXCEPTION_DISPOSITION  //异常处理函数
------------
//手动验证一波
0:000> dg fs
                                  P Si Gr Pr Lo
Sel    Base     Limit     Type    l ze an es ng Flags
---- -------- -------- ---------- - -- -- -- -- --------
0053 00916000 00000fff Data RW Ac 3 Bg By P  Nl 000004f3
0:000> dt ntdll!_EXCEPTION_REGISTRATION_RECORD -l next poi(fs:[0])
next at 0x00b5fb58          //fs:[0]指向seh头
---------------------------------------------
   +0x000 Next             : 0x00b5fba0 _EXCEPTION_REGISTRATION_RECORD
   +0x004 Handler          : 0x010f1385     _EXCEPTION_DISPOSITION  winseh!_except_handler4+0

next at 0x00b5fba0
---------------------------------------------
   +0x000 Next             : 0x00b5fc0c _EXCEPTION_REGISTRATION_RECORD
   +0x004 Handler          : 0x010f1385     _EXCEPTION_DISPOSITION  winseh!_except_handler4+0

next at 0x00b5fc0c
---------------------------------------------
   +0x000 Next             : 0x00b5fc24 _EXCEPTION_REGISTRATION_RECORD
   +0x004 Handler          : 0x77a186d0     _EXCEPTION_DISPOSITION  ntdll!_except_handler4+0

next at 0x00b5fc24
---------------------------------------------
   +0x000 Next             : 0xffffffff _EXCEPTION_REGISTRATION_RECORD
   +0x004 Handler          : 0x77a25196     _EXCEPTION_DISPOSITION  ntdll!FinalExceptionHandlerPad22+0
----
```

# SEH异常处理函数
相关处理函数
```
0:000> u 77a25196 //SEH最终处理
ntdll!FinalExceptionHandlerPad22:
77a25196 90              nop
ntdll!FinalExceptionHandlerPad23:
77a25197 90              nop
ntdll!FinalExceptionHandlerPad24:
77a25198 90              nop
...more
77a251c0 e9f2b80500      jmp     ntdll!_FinalExceptionHandler (77a80ab7)


0:000> u 010f1385
winseh!_except_handler4 [d:\agent\_work\3\s\src\vctools\crt\vcstartup\src\eh\i386\chandler4gs.c @ 84]:
010f1385 55              push    ebp
010f1386 8bec            mov     ebp,esp
010f1388 ff7514          push    dword ptr [ebp+14h]
010f138b ff7510          push    dword ptr [ebp+10h]
010f138e ff750c          push    dword ptr [ebp+0Ch]
010f1391 ff7508          push    dword ptr [ebp+8]
010f1394 68a8130f01      push    offset winseh!__security_check_cookie (010f13a8)
010f1399 6804300f01      push    offset winseh!__security_cookie (010f3004)
010f139e e8370b0000      call    winseh!except_handler4_common (010f1eda) <----
010f13a3 83c418          add     esp,18h
010f13a6 5d              pop     ebp
010f13a7 c3              ret

0:000> x vcruntime140!_except_handler4_common
74fe4480          VCRUNTIME140!_except_handler4_common (
                              unsigned int *, //0x0 __security_cookie
                              <function> *, //0x4 __security_check_cookie
                              struct _EXCEPTION_RECORD *, //0x8  <----
                              struct _EXCEPTION_REGISTRATION_RECORD *, //0xc
                              struct _CONTEXT *,//0x10
                              void *//0x14 (DispatcherContent)
                          )
0:000> dt _EXCEPTION_RECORD
winseh!_EXCEPTION_RECORD
   +0x000 ExceptionCode    : Uint4B //Exception Code 错误代码
   +0x004 ExceptionFlags   : Uint4B //EstablisherFlags 
   +0x008 ExceptionRecord  : Ptr32 _EXCEPTION_RECORD //*ExceptionRecord
   +0x00c ExceptionAddress : Ptr32 Void //ExceptionAddress 出错地址
   +0x010 NumberParameters : Uint4B //# os Parameters
   +0x014 ExceptionInformation : [15] Uint4B
```


