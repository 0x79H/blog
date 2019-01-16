title: 获取DLL的函数地址
date: 2019-01-08 23:22:56
tags: [windows,shellcode]
---

一些基础啦

# 常规方法

使用*LoadLibrary*与*GetProcAddress*

```
PDWORD _addr = (PDWORD)GetProcAddress(LoadLibrary(<DllName>), <FunctionName>);
```
<!--more-->
## 隐藏 GetProcAddress

使用pe头,mz头->pe头->导入表->遍历->比较Name->获得NameOrdinals->取Functions,得到函数在内存中基地址的偏移量

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

使用PEB头,TEB->PEB(fs:[30])->PEB_LDR_DATA(_LDR_DATA_TABLE_ENTRY-0x10)->遍历->BaseDllName/DllBase,取得基地址
当然,前提是dll需要被导入
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
    if(!wcscmp(_dll_name,<DllName>))
    {
        break;
    }

} while (pFlag != (PDWORD)pList);
```


# <span style="font-size:14px">参考资料</span>

