title: msys2替换ncurses为pdcurses后更新失败
date: 2019-06-03 15:14:48
tags: [fix,msys2,windows]
---
解决msys2提示`替换 mingw-w64-i686-ncurses 为 mingw32/mingw-w64-i686-pdcurses 吗 ？`后失败的问题
```bash
➜  ~ pacman -Syyu
:: Synchronizing package databases...
 mingw32         545.2 KiB   822K/s 00:01 [------------------------------------------------------------------------] 100%
 mingw32.sig     119.0   B  5.81K/s 00:00 [------------------------------------------------------------------------] 100%
 mingw64         546.4 KiB  3.38M/s 00:00 [------------------------------------------------------------------------] 100%
 mingw64.sig     119.0   B  9.68K/s 00:00 [------------------------------------------------------------------------] 100%
 msys            180.4 KiB  5.68M/s 00:00 [------------------------------------------------------------------------] 100%
 msys.sig        119.0   B  11.6K/s 00:00 [------------------------------------------------------------------------] 100%
:: Starting core system upgrade...
 there is nothing to do
:: Starting full system upgrade...
warning: mingw-w64-i686-binutils: local (2.31.1-1) is newer than mingw32 (2.30-6)
:: Replace mingw-w64-i686-ncurses with mingw32/mingw-w64-i686-pdcurses? [Y/n] y
:: Replace mingw-w64-i686-termcap with mingw32/mingw-w64-i686-pdcurses? [Y/n] y
warning: mingw-w64-x86_64-binutils: local (2.31.1-1) is newer than mingw64 (2.30-6)
:: Replace mingw-w64-x86_64-ncurses with mingw64/mingw-w64-x86_64-pdcurses? [Y/n] y
:: Replace mingw-w64-x86_64-termcap with mingw64/mingw-w64-x86_64-pdcurses? [Y/n] y
resolving dependencies...
looking for conflicting packages...
error: failed to prepare transaction (could not satisfy dependencies)
:: installing mingw-w64-i686-gcc (9.1.0-2) breaks dependency 'mingw-w64-i686-gcc=7.4.0-1' required by mingw-w64-i686-gcc-ada
:: installing mingw-w64-i686-gcc (9.1.0-2) breaks dependency 'mingw-w64-i686-gcc=7.4.0-1' required by mingw-w64-i686-gcc-objc
:: installing mingw-w64-x86_64-gcc (9.1.0-2) breaks dependency 'mingw-w64-x86_64-gcc=8.3.0-2' required by mingw-w64-x86_64-gcc-ada
:: installing mingw-w64-x86_64-gcc (9.1.0-2) breaks dependency 'mingw-w64-x86_64-gcc=8.3.0-2' required by mingw-w64-x86_64-gcc-objc
```
查找资料，发现已将`*-ncurses`与`*-termcap`替换为`*-pdcurses`,但这不是导致错误的原因.导致错误的原因是`ada`与`objc`已经被[弃用](https://github.com/msys2/MINGW-packages/issues/5434#issuecomment-497053126)，需要手动移除`ada`与`objc`.
`pacman -R --noconfirm mingw-w64-i686-gcc-ada mingw-w64-i686-gcc-objc mingw-w64-x86_64-gcc-ada mingw-w64-x86_64-gcc-objc`,然后`pacman -Syyu`问题解决
