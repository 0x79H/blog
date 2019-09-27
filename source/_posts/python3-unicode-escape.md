title: python3中unicode编码解码
date: 2019-08-31 15:53:09
tags: [python,unicode]
---
tl;dr
> 之前的解决方法是使用字节去读取目标字符串,然后使用函数或正则手动解析unicode编码.现在找到了更好更简单的方法:使用`unicode_escape`相互转换处理即可

举个例子:
```awk
http-title: \xE7\x99\xBE\xE5\xBA\xA6
```
此处的`\xE7\x99\xBE\xE5\xBA\xA6`既是字符串的UTF-8编码,那么
```awk
In [1]: b"\xE7\x99\xBE\xE5\xBA\xA6".decode("utf-8")
Out[1]: '百度'
```
然而对于格式不是byte的字符串来说,python3的默认的编码是utf-8,导致encode出的是utf-8编码,此时只需要手动指定latin1方式解码为byte即可
```awk
In [2]: u"\xE7\x99\xBE\xE5\xBA\xA6".encode()
Out[2]: b'\xc3\xa7\xc2\x99\xc2\xbe\xc3\xa5\xc2\xba\xc2\xa6'

In [3]: u"\xE7\x99\xBE\xE5\xBA\xA6".encode("latin1")
Out[3]: b'\xe7\x99\xbe\xe5\xba\xa6'

In [4]: u"\xE7\x99\xBE\xE5\xBA\xA6".encode("latin1").decode("utf-8")
Out[4]: '百度'
```

<!--more-->

对于使用默认方式从文本中读出的字符串来说,`\`为了防止转义会变成`\\`,此时需要使用`unicode_escape`相互转换处理即可.(这里让我搞了许久,之前的解决方法是上正则匹配`\x`与`\u`开头的字符串)
```awk
In [11]: x1=""
    ...: with open(r"d:\u.txt") as f:
    ...:     x1=f.read()
    ...:     print(x1)
    ...:
\xE7\x99\xBE\xE5\xBA\xA6\xE4\xB8\x80\xE4\xB8\x8B\xEF\xBC\x8C\xE4\xBD\xA0\xE5\xB0\xB1\xE7\x9F\xA5\xE9\x81\x93

In [12]: x
Out[12]: '\\xE7\\x99\\xBE\\xE5\\xBA\\xA6'

In [13]: x.encode()
Out[13]: b'\\xE7\\x99\\xBE\\xE5\\xBA\\xA6'

In [19]: u"\xE7\x99\xBE\xE5\xBA\xA6".encode("unicode_escape")
Out[19]: b'\\xe7\\x99\\xbe\\xe5\\xba\\xa6'

In [14]: x.encode().decode("unicode_escape").encode("latin1")
Out[14]: b'\xe7\x99\xbe\xe5\xba\xa6'

In [15]: x1.encode().decode("unicode_escape").encode("latin1").decode("utf-8")
Out[15]: '百度一下，你就知道'

```