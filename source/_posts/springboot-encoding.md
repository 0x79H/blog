---
title: SpringBoot 中文乱码
date: 2019-06-10 08:54:34
tags: [java,fix]
---
idea测试不乱码，`mvn clean package`打包后运行乱码。是因为java的默认编码不是UTF8。
直接运行`java -Dfile.encoding=utf-8 -jar springboot_demo.jar`；或者设置变量`JAVA_TOOL_OPTIONS`为`-Dfile.encoding=utf-8`后直接运行即可。

