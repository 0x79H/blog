title: qq邮箱三位短id
date: 2021-06-02 10:55:10
tags:
---
# 方法
```
api = "http://mail.qq.com/cgi-bin/register?check_tmpl=add_alias&sid={}&action=framecheck&alias={}&verifycode="
```
# 三位id结果统计
{% chart 90% 300 %}
{
  type: 'pie',
  data: {
    labels: ['可用', '保留', '已用'],
    datasets: [{
      label: '三位短id',
      data: [79 , 2696, 33728],
      backgroundColor: ['rgb(255, 99, 132)', 'rgb(54, 162, 235)', 'rgb(255, 205, 86)'],
      //hidden: [true, true, false]
    }]
  },
  options: {
    title: {
        display: true,
        text: "三位短id"
    }
  }
}
{% endchart %}
# 三位id可用列表
<!--more-->
<script src="https://gist.github.com/0x79H/81422cefb2f3d338c797294fd2de2fca.js"></script>