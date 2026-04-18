# SSH
SSH（Secure Shell）是一种加密网络协议，用于在不安全的网络上安全地操作网络服务。它最常见的用途是远程登录到服务器并执行命令，默认端口为 22。

SSH 通过以下方式保证安全：
* **加密传输**：所有数据经过加密，防止中间人窃听
* **身份验证**：支持密码和密钥对两种认证方式
* **完整性校验**：防止数据在传输过程中被篡改
```
Client ←——————加密隧道 ——————→ Server
ssh CMD                     ssh deamon
```

## SSH Login 
身份校验包括两类方式：
1. 密码认证：安全性一般，适合临时访问。
    ```
    ssh user:host -p $PORT # PORT 默认为 22，执行之后会要求输入密码
    ```
2. 密钥对认证：安全性高，适合日常使用。将生成的 PUBLIC_KEY 保存到 server，本地登陆时提供 PRIVATE_KEY。
    ```
    # 密钥对生成
    ssh-keygen -C "user@hostname" # -C 设置的是密钥的注释，可以为任意字符串，一般用个人邮箱。执行完成后会在 ~/.ssh/ 路径下生成公钥和私钥（其中公钥一般为 .pub 文件）
    
    # 将 local_machine 生成的公钥保存到 server
    ssh-copy-id user:host -p $PORT -i $PUBLIC_KEY_PATH # PUBLIC_KEY_PATH 即为公钥文件路径

    # 通过私钥登陆 server
    ssh user:host -p $PORT -i $PRIVATE_KEY_PATH # PRIVATE_KEY_PATH 即为密钥文件路径
    ```

## SSH Config

### Client Config
SSH Client Config 文件分为 Global 和 User 两级：

* Global: /etc/ssh/ssh_config
* User: ~/.ssh/config

其中 User 的优先级大于 Global。

配置文件的基本结构如下：
```
 每个 Host 块对应一组配置
Host 别名\通配符
    key1 val1
    key2 val2

Host 别名\通配符
    key1 val1
```
一个连接的基本配置如下：
```
Host myserver
    HostName 192.168.1.100   # 真实地址（IP 或域名）
    User ubuntu              # 登录用户名
    Port 2222                # 端口，默认 22
```
配置后直接用别名连接：
```
ssh myserver # 等价于：ssh -p 2222 ubuntu@192.168.1.100
```
常用的配置选项如下：
```
Host myserver
    # 密钥相关
    IdentityFile ~/.ssh/id_ed25519   # 指定私钥路径
    IdentitiesOnly yes               # 只用上面指定的密钥，不轮询其他

    # 保持连接（防断连）
    ServerAliveInterval 60    # 每 60 秒发一次心跳包
    ServerAliveCountMax 3     # 心跳无响应 3 次后断开

    ForwardAgent yes          # 转发本地 ssh-agent 到远程（慎用，有安全风险）
    Compression yes           # 启用压缩，带宽小时有用
    LogLevel VERBOSE          # 日志级别（DEBUG/VERBOSE/INFO/QUIET）
    ConnectTimeout 10         # 连接超时秒数
    StrictHostKeyChecking no  # 不检查服务器指纹（测试环境用，生产慎用）
```
此外 Host 还支持通配符，可以做到批量配置：
```
 具体的匹配规则如下
    # *匹配任意个任意字符
    # ?匹配单个任意字符

 匹配所有主机的全局默认配置
Host *
    ServerAliveInterval 60
    IdentitiesOnly yes
    AddKeysToAgent yes

 匹配所有 .example.com 下的主机
Host *.example.com
    User deploy
    IdentityFile ~/.ssh/id_work

 匹配 server1.example.com、serverA.example.com
Host server?.example.com    
    User deploy
    IdentityFile ~/.ssh/id_work

 匹配多个别名
Host dev staging
    HostName server.example.com
    User ubuntu
```
同一个选项，先匹配到的生效，后面的不会覆盖。所以通常的写法是：具体配置写上面，全局默认写最下面。

### Server Config
path: /etc/ssh/sshd_config
```
# 修改默认端口（提高安全性）
Port 2222

# 禁止 root 直接登录（强烈建议）
PermitRootLogin no

# 禁用密码登录，只允许密钥（强烈建议）
PasswordAuthentication no
PubkeyAuthentication yes

# 限制登录用户
AllowUsers ubuntu deploy

# 空闲超时（秒）
ClientAliveInterval 300
ClientAliveCountMax 2
```

最佳实践：生产环境务必使用密钥认证 + 禁用密码登录 + 修改默认端口，可大幅降低被暴力破解的风险。

## scp
即安全拷贝，将 local/remote 下的 file 拷贝到 remote/local
```
 本地 → 远程
scp file.txt user@host:/remote/path/
scp -r ./local_dir user@host:/remote/path/   # 传目录

 远程 → 本地
scp user@host:/remote/file.txt ./local/

 远程 → 远程
scp user1@host1:/path/file user2@host2:/path/

 常用参数
scp -P 2222   # 指定端口
scp -C        # 启用压缩
```

# chmod
chmod（change mode）是 Linux/Unix 系统中用于修改文件或目录权限的命令。Linux 中每个文件/目录都有三组权限，分别对应三类用户：
```
-  rwx  rwx  rwx
   │    │    └── Others（其他用户）
   │    └─────── Group（所属组）
   └──────────── Owner（文件所有者）
```
对于每一类用户，又有三种基本的权限：
* r (Read): 允许读取文件内容，或者列出目录中的文件。数字代号为 4。
* w (Write): 允许修改、删除文件内容，或者在目录中创建/删除文件。数字代号为 2。
* x (Execute): 允许将文件作为程序/脚本运行，或者允许使用 cd 命令进入该目录。数字代号为 1。
* \- (None): 没有任何权限。数字代号为 0。

## 符号模式
* 语法格式：chmod [用户][操作][权限] 文件
* 用户标识：
    | 符号 | 含义              |
    | --- | -----------      |
    | u   | user，文件所有者   |
    | g   | group，所属组      |
    | o   | others，其他人     |
    | a   | all，所有人（默认） |
* 操作符：
    | 符号 | 含义              |
    | --- | -----------      |
    | +   | 添加权限           |
    | -   | 移除权限           |
    | =   | 精确设置权限       |
示例：
```
chmod u+x file         # 给所有者添加执行权限
chmod g-w file         # 移除组的写权限
chmod o=r file         # 其他人只有读权限
chmod a+x file         # 所有人添加执行权限
chmod u+x,g-w file     # 同时操作多个
chmod ug=rw,o=r file   # 精确设置
```