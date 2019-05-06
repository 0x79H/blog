title: requests的post请求总是以get的方式提交
date: 2019-04-25 21:08:19
tags: [python,301,http_code]
---

# Q:
```
req=requests.post("http://www.example.com/post_it",data=_data,headers=_headers)
req.content
#{"status":"error","code":"不能以get的方式请求"}
```

# A:
求求你吧网址最后的**/**加上,网址写全了.

```
req=requests.post("http://www.example.com/post_it/",data=_data,headers=_headers)
req.content
#{"status":"ok"}
```
# why:

访问**http://www.example.com/post_it**,服务器自动301到**http://www.example.com/post_it/**了.于是requests就跟随了.
<!--more-->
然而301会将post请求变成get请求(准确的说是get请求resp的header中的Location).
如果使用的是Nginx的reweite总会产生301相应.所以这时候需要将post的请求用proxy_pass来代理一下.

至于为啥这个界面会301呢.别问,问就是django.