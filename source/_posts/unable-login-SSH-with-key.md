title: 记一次诡异的ssh密钥登录失败
date: 2018-03-31 01:21:55
tags: [linux,shell]
---
问基友要了台服务器,密码与密钥均不能登陆.改了密码后可以登陆,但密钥依然不能登陆.

```bash
[root@VM_19_31_centos ~]# ls -al                               
total 80                                                       
drwxrwxrwx.  3 root root  4096 Mar 30 23:50 .                  
dr-xr-xr-x. 24 root root  4096 Mar 30 23:51 ..
-rwxrwxrwx   1 root root   790 Mar 31 00:07 .bash_history      
-rwxrwxrwx.  1 root root    18 May 20  2009 .bash_logout       
-rwxrwxrwx.  1 root root   176 May 20  2009 .bash_profile      
-rwxrwxrwx.  1 root root   176 Sep 23  2004 .bashrc            
-rwxrwxrwx.  1 root root   100 Sep 23  2004 .cshrc             
-rwxrwxrwx.  1 root root 12754 Dec 25  2014 install.log        
-rwxrwxrwx.  1 root root  5520 Dec 25  2014 install.log.syslog      
drwxrwxrwx   2 root root  4096 Mar 30 23:50 .ssh               
-rwxrwxrwx.  1 root root   129 Dec  4  2004 .tcshrc            
-rwxrwxrwx   1 root root  1005 Mar 30 23:50 .viminfo           
[root@VM_19_31_centos ~]# cd .ssh/
[root@VM_19_31_centos .ssh]# ls -al                            
total 12                                                       
drwxrwxrwx  2 root root 4096 Mar 30 23:50 .                    
drwxrwxrwx. 3 root root 4096 Mar 30 23:50 ..                   
-rwxrwxrwx  1 root root 1157 Mar 31 00:08 authorized_keys      
```
  
明显*.ssh/*与*authorized_keys*权限设置错误,改之

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

退出登录,然而依然不能用密钥登陆...
<!--more-->
猜测是*sshd*配置问题.去sshd_config查看

```bash
#RSAAuthentication yes
#PubkeyAuthentication yes
#AuthorizedKeysFile       .ssh/authorized_keys
```

取消注释,重启sshd服务,退出登录,问题依旧......
谷歌之,用*ssh -vv server*来查看登陆日志,发现报*we did not send a packet, disable method*
![we did not send a packet, disable method](/uploads/2018-03-31_1.png)
谷歌之,发现是*~*的权限设置[问题](https://unix.stackexchange.com/questions/205842/unable-to-login-with-ssh-rsa-key)

```bash
chmod 755 ~
```

退出登录,问题解决😂