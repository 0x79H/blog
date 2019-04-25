title: requests的post请求总是以get的方式提交
date: 2019-04-25 21:08:19
tags: [python]
---

# Q:
```
req=requests.post("http://www.example.com/post_it",cookies=_cookies,headers=_headers)
req.content
#{"status":"error","code":"不能以get的方式请求"}
```

# A:
求求你吧网址最后的**/**加上,网址写全了.

```
req=requests.post("http://www.example.com/post_it/",cookies=_cookies,headers=_headers)
req.content
#{"status":"ok"}
```