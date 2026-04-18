# [Bandit Level 13 → Level 14](https://overthewire.org/wargames/bandit/bandit14.html)

## Question

The password for the next level is stored in /etc/bandit_pass/bandit14 and can only be read by user bandit14. For this level, you don’t get the next password, but you get a private SSH key that can be used to log into the next level. Look at the commands that logged you into previous bandit levels, and find out how to use the key for this level.

## Solution

### Apporach
由于密码文件只能由 bandit14 读取，而当前的用户是 bandit13，所以 Level 14 注定无法通过 SSH 密码登陆。
在 bandit13 的根目录下执行 ls:
```
HINT  sshkey.private
```
有一个典型的 SSH 私钥文件：sshkey.private，所以解法很明显，就是通过 sshkey.private 进行 SSH 密钥登陆。

所以整体可分为两步:
1. 将 sshkey.private 保存到本地；
2. 通过 sshkey.private 登陆 bandit14，并读取 /etc/bandit_pass/bandit14 保存其密码；

### Process
通过 scp 命令将 sshkey.private 下载到本地（在 local_machine 上执行）：
```
scp -P 2220 bandit13@bandit.labs.overthewire.org:sshkey.private ~/tmp/
```
将 sshkey.private 下载到 ~/tmp/ 路径下之后，还需要对下载的文件进行权限修正处理，因为 SSH 密钥登陆规定密钥文件只能是文件所有者具有读写权限（即：-rw-------），而下载下来的文件权限相关信息如下：
```
// 在 ~/tmp/ 路径下执行 ls -l
ls -l

// output:
total 4
-rw-r----- 1 eidnoat eidnoat 1679 Apr 18 14:27 sshkey.private
```
显然不满足需求，所以还需要通过 chmod 命令对文件权限进行调整：
```
chmod g-r sshkey.private
```
再次查看文件权限信息：
```
// 在 ~/tmp/ 路径下执行 ls -l
ls -l

// output:
total 4
-rw------- 1 eidnoat eidnoat 1679 Apr 18 14:27 sshkey.private
```
权限调整成功。

下面执行 SSH 密钥登陆：
```
ssh -i ~/tmp/sshkey.private bandit14@bandit.labs.overthewire.org -p 2220
```
即可正常登陆到 bandit14。
