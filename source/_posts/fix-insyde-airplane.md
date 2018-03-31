title: 修复Airplane Mode Hid设备异常
date: 2015-12-05 05:23:10
tags: [fix,windows]
---
设备管理器中Insyde Airplane Mode HID Mini-Driver有感叹号，硬件id为ACPI\VEN_PNP&DEV_C000

在[这里](http://answers.microsoft.com/ru-ru/windows/forum/windows8_1-hardware/%D1%81%D0%BE%D0%B2%D0%BC%D0%B5%D1%81%D1%82%D0%B8/7812d6a2-1cc6-4912-8344-8635b5356983?auth=1)找到解决问题的方案。

导入注册表
	```
	Windows Registry Editor Version 5.00
	;fix error code 10 (insyde airplane mode hid mini-driver) 
	
	[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\AirplaneModeHid\Parameters]
	"ECRAMBASE"=dword:ff700100
	```
仔细看了看应该是这个驱动的安装程序的锅…

此文章基于以下驱动版本完成:1.4.0.3

最新更新的1.4.0.4(签名日期2017-01-19)并未解决这个bug

*2018-03-31更新*
1.4.0.8(签名日期2017-06-28)已解决此问题 😏