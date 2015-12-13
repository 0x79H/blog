title: Steam Web Tools 与 Steam Economy Enhancer 共存
date: 2018-01-16 14:04:46
tags: blog
---
steam常用脚本Steam Web Tools和Steam Economy Enhancer一起使用时,库存页面显示有冲突.此时仅需要将
```html
"<style>.checkedForSend{background:#366836!important}.itemcount{background:#292929;color:#FFF;font-weight:700;position:absolute;right:0;top:0}.swt_icon{position:absolute;top:0;left:0}.swt_icon-st{background:#CF6A32;color:#fff}.swt_icon-t{background:#FDEC14;color:#000}#inventory_logos{display:none}.swt_hidden{display:none}</style>"
```
修改为
```html
'<style>.checkedForSend{background:#366836!important}.itemcount{background:#292929;color:#FFF;font-weight:700;position:absolute;right:0;bottom:0}.swt_icon{position:absolute;top:0;left:0}.swt_icon-st{background:#CF6A32;color:#fff}.swt_icon-t{background:#FDEC14;color:#000}#inventory_logos{}.swt_hidden{display:none}</style>'
```
即可