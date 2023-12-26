---
title: Android安全
date: 2019-02-22 14:32:48
tags: [android,Xposed,frida,llvm]
---
年前疯狂更了一波博客,是因为准备换工作了,说不定可以拿博客出去吹一吹.然而这么菜,根本没有勇气拿出来吹.本来是打算搞搞windows内核那些东西,结果感觉自己菜的一笔,没勇气干,还是面的Web.最终在年前,面上了某家的渗透测试(实质上是安服),工作后就莫名其妙偏了点移动方面的安全,于是就又捡起来以前的东西搞了搞.这一搞,不但发现了之前绕的弯路,也发现了一大堆有意思的东西:frida, llvm, etc...

# 基础的前置工具
到现在依旧好用的apktools, signapk.jar, dex2jar, jd-gui, jeb, ida;以及最近发现的jadx, Luytan

## apktools
哪一部分出错了就删哪一部分, 再出错了再尝试修复.有时候甚至你用--no-res会出现问题,不使用却没问题.

## ida
*Shift + F11*直接导入头文件即可,*JNIEnv*和*JavaVM*给你自动识别还有啥不满足的,还要啥自行车.
*Alt + G*修改ARM工作模式,这还是之前做pwnable.kr的题知道的.

## Android Studio
没错!是AS!这玩意可以直接解包apk,配合smalidea,设置为*code*目录即可直接开始调试.

# 基础工具
## Xposed
简单来说,Xposed仅仅用findAndHookMethod就可以搞定99%的应用场景.
Xposed最近读了一遍它的源码,过了一遍Xposed的流程.
<!--more-->
Xposed的实现原理,既是在Android系统的Zygote进程启动之前,使用了de.robv.android.Xposed.XposedInit.hookResources()来注入自身框架.因此,由Zygote启动的所有app进程都会包含Xposed框架的相关文件.
Xposed在启动时调用了de.robv.android.Xposed.XposedInit.loadModules(),由此来加载所有启用的Xposed模块.此过程在有且仅有一次调用.
之后Xposed框架会在应用启动后,以启动app的相关信息作为参数,回调Xposed模块中Xposed_int文件定义的类的handleLoadPackage(final XC_LoadPackage.LoadPackageParam loadPackageParam)方法.Xposed模块根据传入的参数,来进行相关操作.

### Xposed免重启更改Xposed模块
因为Xposed只是在loadModules()的时候加载Xposed模块到内存中,此过程只进行一次.Xposed模块的怎么更新也不会影响到内存中的数据,除非通过反射,或修改bridage源码的方式再调用loadModules()重新载入Xposed模块.
因为Xposed模块的方法不可变,我们只需要在Xposed模块中手动*动态调用*其他可更新的方法即可.其中Class由PathClassLoader来通过File获取.

### Xposed MutiDex hook
在app有多dex的情况下,Xposed去hook某函数可能会出现ClassNotFound的异常.这是因为Xposed默认的classLoader只会获取到app主要dex下的方法.
我们只需要手动替换classLoader为Content.classLoader即可.而Content据开发者在[某issue](https://github.com/rovo89/xposedbridge/issues/30#issuecomment-68488797)中提示,对android.app.Application.Attach(Context)进行hook即可取到Content.
```
@Override
public void handleLoadPackage(final XC_LoadPackage.LoadPackageParam lpparam) throws Throwable{
  XposedHelpers.findAndHookMethod(Application.class,"attach", Context.class, new XC_MethodHook() {
      if (loadPackageParam.packageName.equal('com.example.test')){
      @Override
      protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
          Context context=(Context) param.args[0];
          lpparam.classLoader = context.getClassLoader();
          XposedHelpers.findAndHookMethod("con.example.test.test_class",lpparam.classLoader,new XC_MethodHook() {
              //TODO :D
          });
      }
  });
}
```

# frida
跨平台的,爽的1b的.
javascript直接一把梭就是了,破js是弱类型的,绝对不会报错.

对于Android的java层,对于知道类型的直接Java.use和Java.cast就可以直接用Class的参数和成员变量.从一般函数到构造函数(因为*.$new() = .alloc() + .init()*)无所不能. *Java.choose*甚至可以让你实时监测*onMatch*和*onComplete*.
对于Android的so,你需要的一切都在*Module.findExportByName("<so_name>.so","<func_name>")*中.*Interceptor.attach()*的*onEnter*和*onLeave* 既是 *Java.choose* 的翻版.

简单改了下[house](https://github.com/nccgroup/house/wiki/Overview), 在获取到的参数类型为Object的情况下, 通过getClass()和getDeclaredFields()来解析Object内容,并显示到log中. 
让house的历史脚本兼容了下windows:将houseSock.py中的四个path的末尾加个*\*即可.


# LLVM
虚拟机, 简单来说就是跨平台的VMProtect
虽然说知道原理,但是连windows下的VMP都不能手脱.真是菜的抠脚
LLVM和vmp一样,被我加入到了清单列表中.

# 调试与反调试
理论上可以通过修改android源码来bypass掉,但是又没钱买谷歌亲儿子,又不会做适配.
mprop真是神器,直接改ro判断,思路真是猥琐至极,是大佬.
反反调试只知道一些简单的常规的,姿势还是不够多.

