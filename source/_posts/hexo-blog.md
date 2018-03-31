title: 搭了个博客
date: 2015-11-18 05:23:10
tags: blog
---
简单说一说我是怎么搭建这个博客的吧
由于hexo是基于node.js的，所以需要先安装node.js
由于我是架设在github.io上的，所以我们需要git(还支持heroku/rsync/openshift)
## 安装node.js
	```bash
	git clone git://github.com/joyent/node.git
	git checkout v0.12.7-release
	./configure && make && make install
	node -v
	npm -v
	```
若提示命令不存在，则
	```bash
	where node
	ln -s 原位置 错误提示的位置
	```
<!--more-->
## hexo的安装
新建了个目录
./blog/
在目录中
	```bash
	npm install -g hexo
	hexo init
	hexo g
	hexo s
	```
这时访问*http://localhost:4000/*应该就可以看到你的博客了

## github的推送设置
首先安装组件
```bash
npm install hexo-deployer-git
```
然后设置git仓库信息
```
deploy:
type: git
repo: git@github.com:XXX:XXX.github.io.git
branch: master
message: update
```
这样就可以用**hexo d**来推送到github了(其实本质就是<!--2018-03-31修改--> ~~推送./public/的所有文件~~**复制./public/的文件到./.deploy_git/并推送**到github)

## 域名绑定:
暂时是直接
```bash
echo blog.qwerdf.com >./blog/public/CNAME
```
然后设置A记录到github
## 平时怎么用?

```bash
hexo new "标题"
vim ./blog/source/_posts/标题.md
```

然后

```bash
hexo clean
hexo g
hexo d
```

## 常用hexo命令
```bash
hexo s --debug
hexo clean&&hexo g&&hexo g&&hexo d
```
使用两次**hexo g**是因为有时生成的主页[有问题](https://github.com/iissnan/hexo-theme-next/issues/482),首页仅显示一篇文章。

最后表示终于**有时间**来干这事了

