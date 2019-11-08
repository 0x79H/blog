title: 部署Office Web Apps
date: 2019-11-08 11:59:03
tags: [windows,domain]
---
工作需要部署OfficeWebApps(OWA),于是部署了下.
# 安装
环境: `WindowsServer2008R2`
需要的文件:

软件|文件名
--|--
.Net Framework4.5(.1)|NDP451-KB2858728-x86-x64-AllOS-ENU.exe
PowerShell V3(Windows Management Framework 3.0)|Windows6.1-KB2506143-x64.msu
office web apps server 2013|cn_office_web_apps_server_2013_with_sp1_x64_dvd_3832995.iso

安装需要在非dc的ad域中
```
Import-Module ServerManager
Add-WindowsFeature Web-Server,Web-WebServer,Web-Common-Http,Web-Static-Content,`
    Web-App-Dev,Web-Asp-Net,Web-Net-Ext,Web-ISAPI-Ext,Web-ISAPI-Filter,`
    Web-Includes,Web-Security,Web-Windows-Auth,Web-Filtering,`
    Web-Stat-Compression,Web-Dyn-Compression,Web-Mgmt-Console,Ink-Handwriting,`
    IH-Ink-Support,NET-Framework,NET-Framework-Core,NET-HTTP-Activation,`
    NET-Non-HTTP-Activ,NET-Win-CFAC

Import-Module -Name OfficeWebApps
New-OfficeWebAppsFarm -InternalURL "http://127.0.0.1" `
    -ExternalURL "http://<IP_Address_There>" -AllowHTTP -EditingEnabled
```
安装后在该服务器访问127.0.0.1按照提示即可预览测试.
安装后发现好像没有方便的方式去修改80端口
<!--more-->
# 报错解决
## 错误0
Office Web Apps装好后发现,多个界面报错,错误为`处理程序 “PageHandlerFactory-Integrated” 在其模块列表中有一个错误模块 “ManagedPipelineHandler”`,搜索后发现,这一问题的原因为.net框架在iis前安装:
```
C:\Windows\Microsoft.NET\Framework\v4.0.30319\aspnet_regiis.exe -i
```
运行上述命令即可解决

## 错误1
Office Web Apps安装好后发现,word/excel都可以正常使用,但是powerpoint不能正常使用,提示错误.查看位于的日志后发现抛出了以下异常

Timestamp|Process|TID|Area
--|--|--|--|--|--|--|--|--
PowerPoint Front End|a22x|Medium|WacConversionResultErrorInfo; ItemRetrivalStatus: ConversionError; ErrorCode: ErrorWacConversionWorkerException; ConversionResult: WorkerException;
Office Viewing Architecture|al1c3|Medium|AsyncResult::SetCompleted - Completed with unthrown exception Microsoft.Office.Server.Powerpoint.Pipe.Interface.PipeApplicationException: Exception of type 'Microsoft.Office.Server.Powerpoint.Pipe.Interface.PipeApplicationException' was thrown. at Microsoft.Office.Server.Powerpoint.Pipe.Web.WacViewServices.EndGetItem(IAsyncResult asyncResult) at Microsoft.Office.Server.Powerpoint.Pipe.Interface.ResourceRequest.End(IAsyncResult asyncResult) at Microsoft.Office.Server.Powerpoint.Pipe.Interface.PipeManager.OnRequestComplete(IAsyncResult result)WacConversionResultErrorInfo; ItemRetrivalStatus: ConversionError; ErrorCode: ErrorWacConversionWorkerException; ConversionResult: WorkerException;
PowerPoint Web Services|a23u|Monitorable|Pipe application exception caught when executing web method handler: Microsoft.Office.Server.Powerpoint.Pipe.Interface.PipeApplicationException: Exception of type 'Microsoft.Office.Server.Powerpoint.Pipe.Interface.PipeApplicationException' was thrown. at Microsoft.Office.Web.Common.AsyncResult`1.WaitForCompletion() at Microsoft.Office.Server.Powerpoint.Web.Services.PptViewingService.EndGetPresentationInternal(IAsyncResult result) at Microsoft.Office.Server.Powerpoint.Web.Services.WebMethodExecuteHandler.<>c__DisplayClass7`1.<ExecuteSkipEnabledCheck>b__6() at Microsoft.Office.Server.Powerpoint.Web.Services.WebMethodExecuteHandler.ExecuteInternal(HttpContext context, Func`1 webMethodHandler, IPerfEventHandler perfEventHandler, Boolean fCheckWebIsEnabled, Boolean fSetAffinity)...
PowerPoint Web Services|a23u|Monitorable|...WacConversionResultErrorInfo; ItemRetrivalStatus: ConversionError; ErrorCode: ErrorWacConversionWorkerException; ConversionResult: WorkerException;

以`Microsoft.Office.Server.Powerpoint.Pipe.Interface.PipeApplicationException`为关键字搜索,发现
```
rd /s /q "C:\ProgramData\Microsoft\OfficeWebApps\Working\d\"
rd /s /q "C:\ProgramData\Microsoft\OfficeWebApps\Working\waccache\LocalCacheStore\NT AUTHORITY_NETWORK SERVICE\"
;echo UseGDIPlus=(System.Boolean)true >> ^
        "c:\Program Files\Microsoft Office Web Apps\PPTConversionService\Settings_Service.ini"
```
运行上述命令即可解决.至此,可以正常预览使用



# 参考链接
[Deploy Office Web Apps Server](https://docs.microsoft.com/en-us/webappsserver/deploy-office-web-apps-server)
[error0](https://blog.csdn.net/mazhaojuan/article/details/7660657)
[error1](https://www.wavecoreit.com/blog/serverconfig/office-webapps-server-fails-to-render-powerpoint-in-skype-for-business/)