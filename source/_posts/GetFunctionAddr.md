title: 获取DLL的函数地址
date: 2019-01-08 23:22:56
tags: [windows,shellcode]
---

一些基础啦

# C语言的常规方法

使用*LoadLibrary*与*GetProcAddress*这两个API

```
PDWORD _addr = (PDWORD)GetProcAddress(LoadLibrary(<DllName>), <FunctionName>);
```
<!--more-->
## 隐藏 GetProcAddress

使用pe头,mz头->pe头->导出表->遍历->比较Name->获得NameOrdinals->取Functions,得到函数在内存中基地址的偏移量

```C
PDWORD _addr = nullptr;
_base_addrODULE _base_addr = LoadLibrary(<DllName>);
PIMAGE_DOS_HEADER pdh = (PIMAGE_DOS_HEADER)_base_addr;
PIMAGE_NT_HEADERS pnt = (PIMAGE_NT_HEADERS)(_base_addr + pdh->e_lfanew);
PIMAGE_EXPORT_DIRECTORY pexports = (PIMAGE_EXPORT_DIRECTORY)(_base_addr + 
                      pnt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress);
PDWORD _Functions = (PDWORD)(_base_addr + pexports->AddressOfFunctions);
PDWORD _Name = (PDWORD)(_base_addr + pexports->AddressOfNames);
PDWORD _NameOrdinals = (PWORD)(_base_addr + pexports->AddressOfNameOrdinals);

for (DWORD i = 0; i < pexports->NumberOfNames; i++) {
    //甚至你还可以用hash比较,来隐藏函数名的明文字符串,就像meterpreter
    //if (_hash_calc(_base_addr + _Name[i]) == _hash_calc(<FunctionName>)) {
    if (!strcmp(_base_addr + _Name[i], <FunctionName>)) {
        _addr = _base_addr + _Function[_NameOrdinals[i]];
        break;
    }
}
```

## 隐藏 LoadLibrary
这里只讨论获取已加载dll的基地址
### 通过fs获取
使用PEB头,TEB->PEB(fs:[30])->PEB_LDR_DATA(_LDR_DATA_TABLE_ENTRY-0x10)->遍历->BaseDllName/DllBase,取得基地址
```
ntdll!_PEB_LDR_DATA
   -0x00c Length           : Uint4B
   -0x008 Initialized      : UChar
   -0x004 SsHandle         : Ptr32 Void
ntdll!_LDR_DATA_TABLE_ENTRY
   +0x000 InLoadOrderLinks : _LIST_ENTRY    //第三个为kernel32
   +0x008 InMemoryOrderLinks : _LIST_ENTRY    //EnumProcessModules(hProcess,*lphModule,cb,lpcbNeeded)
   +0x010 InInitializationOrderLinks : _LIST_ENTRY    //CreateToolhelp32Snapshot(dwFlags,th32ProcessID)
   +0x018 DllBase          : Ptr32 Void     //基地址
   +0x01c EntryPoint       : Ptr32 Void
   +0x020 SizeOfImage      : Uint4B
   +0x024 FullDllName      : _UNICODE_STRING
   +0x02c BaseDllName      : _UNICODE_STRING  //dll名
   ...
   +0x0a4 SigningLevel     : UChar
```
当然,前提是dll需要被加载
```
PDWORD _base_addr;
LPWSTR _dll_name = nullptr;
PLIST_ENTRY pList;
__asm {
    mov eax, fs:[0x30]    //dt nt!_peb
    mov eax, [eax + 0x0c] //dt nt!_PEB_LDR_DATA
    add eax, 0x00c        //dt nt!_LDR_DATA_TABLE_ENTRY
    mov pList, eax
}
PDWORD pFlag = (PDWORD)(pList->Blink);
do
{
    pList = pList->Flink;
    _base_addr = (PDWORD)((DWORD)pList + 0x018);
    _dll_name = (LPWSTR)(*(PDWORD)((DWORD)pList + 0x2c + 0x4));
    if(!wcscmp(_dll_name,<DllName>))//hash?
    {
        break;
    }

} while (pFlag != (PDWORD)pList);
```
### 暴力搜索PE头
如果DLL被断链,据我了解,只能使用此种方法.
因为DLL被加载时,pe装载器会把DLL装载进内存的,所以我们只需要暴力搜索pe的文件头**MZ**,即可获取基地址.(当然,文件头不能被抹除)
又因为pe装载器内存是1k对齐的(SectionAlignment),所以我们只需要以1k为单位搜索即可.如果已知DLL内函数的地址,那就更容易搜索出来了.例如最外层SEH即指向kernel32.dll的
```
PDWORD addr = (PDWORD)GetProcAddress;
addr = (PDWORD)((DWORD)addr & 0xfffff000);
WORD _pe_flag = 0x0;
while (true)
{
    __try {
        _pe_flag = *(PWORD)addr;
    }
    __except (EXCEPTION_EXECUTE_HANDLER)
    {
        _pe_flag = 0x0;
    }
    if (_pe_flag == 0x5a4d)
    {
        break;
    }
    addr = (PDWORD)((DWORD)addr - 0x1000);
}
```
# ShellCode
随便找个分析下就有了

# 杂项
* 有说可以使用SEH搜索kernel32.dll,尝试后发现SEH调用的是ntdll的函数,搜索出来的是ntdll.dll的基地址
* 有说可以用poi(poi(poi(fs:0x18)+4)-0x1c)向上搜索,然而测试后发现所指的值为*0x0*.且*fs:0x18*所指处即为*fs*寄存器的值,多此一举.根本不知道这个操作是什么道理.
* 以上测试均在Win10 17763.253下进行

# <span style="font-size:14px">参考资料</span>
[InLoadOrderLinks第三个为kernel32](https://bbs.pediy.com/thread-149527.htm)
没读过不过差不多所有参考资料都有说的0day