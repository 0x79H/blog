title: PE结构
date: 2019-05-27 13:12:26
tags: [windows,pe]
---
# PE结构
也是一些基础啦
## 文件头
一开始DOS头的最后一个成员指向NT头.
NT头的中定义了加载地址,加载选项,入口地址.也在最后一个成员`IMAGE_DATA_DIRECTORY_ARRAY`定义了pe文件包含导入表、导出表、资源表、重定位表在内的、固定的15个表信息,包含RVA与大小信息.
NT头后的`IMAGE_SECTION_HEADER`定义了所有的区块(如.upx0、.upx1、.text等)的加载信息,包含RVA、名称、大小等信息。

## 导入表
先来看一波结构体,其中前置的有:`dos头->nt头->附加头->导入表--(对应区段地址)-->PIMAGE_IMPORT_DESCRIPTOR`
<!--more-->
```c
typedef struct _IMAGE_IMPORT_DESCRIPTOR {
union {
DWORD   Characteristics;
DWORD   OriginalFirstThunk; // 原始导入表(INT)的RVA (PIMAGE_THUNK_DATA)
} DUMMYUNIONNAME;
DWORD   TimeDateStamp;
DWORD   ForwarderChain;
DWORD   Name;       // 导入dll名称
DWORD   FirstThunk; // 导入表(IAT)的RVA (PIMAGE_THUNK_DATA)
} IMAGE_IMPORT_DESCRIPTOR;
typedef IMAGE_IMPORT_DESCRIPTOR UNALIGNED *PIMAGE_IMPORT_DESCRIPTOR;

typedef struct _IMAGE_THUNK_DATA32 {
union {
DWORD ForwarderString;
DWORD Function; // PDWORD
DWORD Ordinal;  // 序号
DWORD AddressOfData;// PIMAGE_IMPORT_BY_NAME
} u1;
} IMAGE_THUNK_DATA32;
typedef IMAGE_THUNK_DATA32 * PIMAGE_THUNK_DATA32;

typedef struct _IMAGE_IMPORT_BY_NAME {  
WORD    Hint;   //序号
CHAR   Name[1]; // 函数名
} IMAGE_IMPORT_BY_NAME, *PIMAGE_IMPORT_BY_NAME;
```
未加载的pe文件,IAT(Import Address Table)与INT(Import Name Table)内容一致,都为`PIMAGE_THUNK_DATA->AddressOfData`.
然而加载后,pe装载器会根据INT,将IAT所指向的`PIMAGE_THUNK_DATA->AddressOfData`更新为`PIMAGE_THUNK_DATA->Function`.

若使用序号导入,则不是`PIMAGE_THUNK_DATA->AddressOfData`,而是`PIMAGE_THUNK_DATA->Ordinal`.区别为查看该DWORD第一位是否为1.
这里设计的巧妙之处在于,即使只有31位来存储地址,也不可能超过2g的内存限制(指在32位非pae的情况下)

## 导出表
这边建议您查看之前的[获取 DLL 的函数地址](2019/01/08/GetFunctionAddr/)呢

## 重定位表
来看一波结构体,其中前置的有:`dos头->nt头->附加头->重定位表(BaseRelocationTable)--(对应区段地址,如.reloc)-->PIMAGE_BASE_RELOCATION`
```c
typedef struct _IMAGE_BASE_RELOCATION {
    DWORD   VirtualAddress;//以0x1000为单位块的RVA
    DWORD   SizeOfBlock;//重定位表中此结构体的大小 总是4的倍数
    WORD    TypeOffset[0];//包含重定位类型与重定位地址的两字节信息
} IMAGE_BASE_RELOCATION,* PIMAGE_BASE_RELOCATION;
```
TypeOffset中高4位(&0xf000)为重定位类型,低12位(&0x0fff+0x1000*n)为重定位地址.数量共`(SizeOfBlock-4*2)/2`个.
将重定位地址的值重定位为正确的位置即可.

## 资源表
三层导航啦,来看结构体,其中前置的有:`dos头->nt头->附加头->资源表(RelocTable)--(对应区段地址,如.rsrc)-->PIMAGE_RESOURCE_DIRECTORY`
```
typedef struct _IMAGE_RESOURCE_DIRECTORY {
    ULONG   Characteristics;
    ULONG   TimeDateStamp;
    USHORT  MajorVersion;
    USHORT  MinorVersion;
    USHORT  NumberOfNamedEntries;       //资源名
    USHORT  NumberOfIdEntries;          //序号
    //后跟IMAGE_RESOURCE_DIRECTORY_ENTRY
} IMAGE_RESOURCE_DIRECTORY, *PIMAGE_RESOURCE_DIRECTORY;

typedef struct _IMAGE_RESOURCE_DIRECTORY_ENTRY {
    ULONG   Name;           //名称或序号指针
    ULONG   OffsetToData;   //指向下一个PIMAGE_RESOURCE_DIRECTORY 
                            //或指向最终的PIMAGE_RESOURCE_DATA_ENTRY
} IMAGE_RESOURCE_DIRECTORY_ENTRY, *PIMAGE_RESOURCE_DIRECTORY_ENTRY;
//以上为一层导航
typedef struct _IMAGE_RESOURCE_DATA_ENTRY {
    ULONG   OffsetToData;   //资源的RVA
    ULONG   Size;
    ULONG   CodePage;
    ULONG   Reserved;
} IMAGE_RESOURCE_DATA_ENTRY, *PIMAGE_RESOURCE_DATA_ENTRY;
```

# 工具
010editor、stud_pe、pe-bear、x96dbg了解下

hwh不动啊，都是waf，当然是选择水一水博客喽😀