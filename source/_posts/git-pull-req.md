---
title: Git 合并两个不同的仓库
date: 2019-03-13 19:36:43
tags: git
---
# why?
Github上看到了被Fork的仓库,因为种种原因pull requests主仓库没有接受,并且还往后更新了.需要在本地合并两个仓库.

# how?

```sh
git clone https://github.com/A/git.git
git remote add other https://github.com/B/git.git
#git remote add -t remote-branch remote-name remote-url
git fetch other master 
#git branch -a
git merge other/master
```

