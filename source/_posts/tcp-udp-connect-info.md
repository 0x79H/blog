---
title: 获取pid对应Tcp与Udp连接的信息
date: 2018-11-23 18:23:51
tags: [code,windows]
---
最近疯狂的在肝[Warframe](https://store.steampowered.com/app/230410/)，疯狂的挂生存模式，但是在开多人后总有人瞎玩搞乱，为了把他们踢出房间，我需要获取他们的ip。

# 简单？

一开始用过*ipip.net*出的一个工具，能够获取到tcp与udp连接的源地址、目的地址与PID。但是有个问题，就是他那个工具用着用着就莫名其妙卡死了，所以遂决定自己造个一样的轮子。

<!--more-->
google之，发现了Microsoft已为我们准备好了*GetExtendedTcpTable*与*GetExtendedUdpTable*,照着文档写了写

```c
#pragma comment(lib, "iphlpapi.lib")
{
	DWORD dwSize = 0;
	PMIB_TCPTABLE_OWNER_PID pTcpTable = (PMIB_TCPTABLE_OWNER_PID)malloc(sizeof(PMIB_TCPTABLE_OWNER_PID));
	GetExtendedTcpTable(pTcpTable, &dwSize, TRUE, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0);
	GetExtendedTcpTable(pTcpTable, &dwSize, TRUE, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0);
	for (DWORD i = 0; i < pTcpTable->dwNumEntries; i++)
	{
		std::cout << (DWORD)pTcpTable->table[i].dwState << std::endl;
		std::cout << (DWORD)pTcpTable->table[i].dwLocalAddr << std::endl;
		std::cout << (DWORD)pTcpTable->table[i].dwLocalPort << std::endl;
		std::cout << (DWORD)pTcpTable->table[i].dwRemoteAddr << std::endl;
		std::cout << (DWORD)pTcpTable->table[i].dwRemotePort << std::endl;
		std::cout << (DWORD)pTcpTable->table[i].dwOwningPid << std::endl;
		std::cout << "======================================" << std::endl;
	}
}
```
以上是tcp的获取方式，其中代码忽略了错误判断(一点都不健壮)。udp的获取方式也是差不多的，使用udp的函数即可。

# 不简单！

然而我还是太天真，写udp的时候发现了一个问题：微软给的*GetExtendedUdpTable*返回的结构体中并不包含目的地址与端口，只包含本地地址与端口。返回的结构体如下：
```c
typedef struct _MIB_UDPROW_OWNER_PID {
  DWORD dwLocalAddr;
  DWORD dwLocalPort;
  DWORD dwOwningPid;
} MIB_UDPROW_OWNER_PID, *PMIB_UDPROW_OWNER_PID;
```
我以为是我找错了API，然而换了*GetUdpTable*也不行，TCPView、ProcessHacker 甚至 *netstat -ano* 都没有提示udp的远程地址。又搜了搜，发现能够使用抓包的方式来获得远程的地址与端口，甚至有人修改了WINPCAP的驱动与wireshark，使得wireshark可以显示数据包的pid。

最后，我找到了LiveTcpUdpWatch，发现它能够实现之前提出的要求。他使用了Windows Event Track的技术，获取Windows Kernel中Tcp/Udp的日志，从而得到包含进程的pid、进程链接的本地与远程的地址与端口。大致代码如下(其实就是抄了抄官方给的[源码](https://docs.microsoft.com/en-us/windows/desktop/etw/using-tdhformatproperty-to-consume-event-data))：

```c
#define INITGUID
#pragma comment(lib, "tdh.lib")
DEFINE_GUID( /* bf3a50c5-a9c9-4988-a005-2df0b7c80f80 */
	UdpIpGuid,
	0xbf3a50c5,
	0xa9c9,
	0x4988,
	0xa0, 0x05, 0x2d, 0xf0, 0xb7, 0xc8, 0x0f, 0x80
);
int main(){
    //------------开启ETW
    EVENT_TRACE_PROPERTIES* event_trace_prop = nullptr; 
    TCHAR logger_name[] = KERNEL_LOGGER_NAME;   //内核
    TRACEHANDLE trace_handler = NULL;     //handle
    const auto buffer_size = sizeof(EVENT_TRACE_PROPERTIES) + sizeof(logger_name);
    event_trace_prop = (EVENT_TRACE_PROPERTIES *)malloc(buffer_size);
    memset(event_trace_prop, 0, buffer_size);
    
    EVENT_TRACE_PROPERTIES* event_trace_prop;
    event_trace_prop->Wnode.BufferSize = buffer_size;
    event_trace_prop->Wnode.Guid = SystemTraceControlGuid;
    event_trace_prop->Wnode.ClientContext = 2;
    event_trace_prop->Wnode.Flags |= WNODE_FLAG_TRACED_GUID;
    event_trace_prop->LogFileMode = EVENT_TRACE_REAL_TIME_MODE;
    event_trace_prop->EnableFlags = EVENT_TRACE_FLAG_NETWORK_TCPIP;
    event_trace_prop->LogFileNameOffset = NULL;
    event_trace_prop->LoggerNameOffset = sizeof(EVENT_TRACE_PROPERTIES);
    
    StartTrace(&trace_handler, logger_name, event_trace_prop);  //start
    //------------关闭ETW
    //ControlTrace(NULL, logger_name, event_trace_prop, EVENT_TRACE_CONTROL_STOP);  //stop
    //-----------打开ETW的日志
    TDHSTATUS status = ERROR_SUCCESS;
    EVENT_TRACE_LOGFILE trace;
    TRACE_LOGFILE_HEADER* pHeader = &trace.LogfileHeader;
    ZeroMemory(&trace, sizeof(EVENT_TRACE_LOGFILE));
    trace.LogFileName = NULL;
    trace.LoggerName = (LPWSTR)KERNEL_LOGGER_NAME;
    trace.EventRecordCallback = (PEVENT_RECORD_CALLBACK)(ProcessEvent);   //CallBack函数
    trace.ProcessTraceMode = PROCESS_TRACE_MODE_EVENT_RECORD | PROCESS_TRACE_MODE_REAL_TIME;
    g_hTrace = OpenTrace(&trace);
    ProcessTrace(&g_hTrace, 1, 0, 0);
}

VOID WINAPI ProcessEvent(PEVENT_TRACE pEvent);
//在callback函数中，pEvent为传入的日志
//IsEqualGUID(pEvent->Header.Guid, UdpIpGuid) 用日志的GUID来判断日志的具体类型
//在函数中使用TDH(TdhFormatProperty)来格式化pEvent
//或MOF(GetPropertyQualifierSet)来获取事件的内容
//
//在此处用pid为关键字，循环获取匹配日志并打印出来即可
```

# 其他
hook掉相应程序WS2_32.dll的网络相关的api也可以，不过因为我这是游戏，所以就没敢这么搞了。

