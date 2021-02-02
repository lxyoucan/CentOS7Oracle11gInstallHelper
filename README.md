@[toc](目录)

<hr>

# 前言
之前写了一篇[《2021年CentOS7安装Oracle11g全记录》](https://blog.csdn.net/lxyoucan/article/details/113177763)因为是边做边写的，看起来可能会比较混乱和冗余。所以决定适当的整理一下，希望能帮助电脑前的您，少走一些弯路。
断断续续熬夜3天，终于做到0警告安装oracle 11g。强迫证福音！

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202155357486.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)

# 环境信息
不同的环境可能会有小小的差异，都是大同小异的。下面给出我用的版本信息：
项目     | 版本
-------- | -----
操作系统  | CentOS Linux release 7.9.2009 (Core)
oracle  | linux.x64_11g_11.2.0.4

**Oracle11g版本选择：**
强烈建议下载 11.2.0.4版本的，oracle版本是官网下载的11.2.0.1有点小坑在里面，我是后来遇到坑后换成的 11.2.0.4版本。

CentOS7安装11.2.0.1遇到的坑：
1. 操作系统内核参数semmni 明明设置正确，先决条件检查以然会提示参数不正确
2.  一些程序包，已经安装过了，先决条件检查以然会提示没有安装
3. 安装到 68%会报错：makefile '/home/oracle/app/oracle/product/11.2.0/dbhome_1/ctx/lib/ins_ctx.mk'的目标'install'时出错

坑 1，2直接忽略可以解决，3网上也有解决办法。但是总让人有点不舒服。好在 11.2.0.4版本中已经没有这些坑了，舒心多了。

11.2.0.4版本普通用户在官网是下载不到的，实在找不到，可以私信我。
# 准备工作
兵马未动，粮草先行。个人觉得linux下安装oracle也就是准备工作比较麻烦一些。实际工作中，经常是远程帮客户安装oracle。为了模拟客户现场环境，我在电脑上远程我这台CentOS7虚拟机来实现数据库的安装。

在安装之前，我们要做一些简单的准备工作，大致如下：
 1. 创建oracle用户和组
 2. 图形化的操作环境：VNC远程或者直接本地图形化操作。

我这里使用openbox做桌面，因为它短小精干！
看文章没看懂？那就来看看视频怎么操作的吧！
B站：
[https://www.bilibili.com/video/BV1Mh411C71D/](https://www.bilibili.com/video/BV1Mh411C71D/)
## 一键安装和配置VNC图形化相关
root执行以下命令，直接整体复制粘贴到终端就行（不用一行一行复制）。
```bash
#图形界面必备`X Window System`
yum -y groupinstall "X Window System"
#安装epel源
yum -y install epel-release
#安装VNC+图形需要的软件
yum -y install tigervnc-server openbox xfce4-terminal tint2 cjkuni-ukai-fonts network-manager-applet
#自动修改/etc/xdg/openbox/autostart配置文件
echo 'if which dbus-launch >/dev/null && test -z "$DBUS_SESSION_BUS_ADDRESS"; then' > /etc/xdg/openbox/autostart
echo '       eval `dbus-launch --sh-syntax --exit-with-session`' >> /etc/xdg/openbox/autostart
echo 'fi' >> /etc/xdg/openbox/autostart
echo 'tint2 &' >> /etc/xdg/openbox/autostart
echo 'nm-applet  &' >> /etc/xdg/openbox/autostart
echo 'xfce4-terminal &' >> /etc/xdg/openbox/autostart
echo ' ' >> /etc/xdg/openbox/autostart
#防火墙放行VNC端口
firewall-cmd --add-port=5901/tcp
firewall-cmd --add-port=5901/tcp --permanent
```

## 创建用户
为了安全起见，不建议使用root做为vnc用户。单独创建一个用户比较安全。
既然安装oracle,这里用户名我使用 oracle。

root执行以下命令，直接整体复制粘贴到终端就行（不用一行一行复制）。
```bash
#创建database用户组
groupadd database
#创建oracle用户并放入database组中
useradd oracle -g database
#设置oracle密码
passwd oracle 
```
密码我设置的是`database@2021`

## 开启 VNC服务
切换到oracle用户
```bash
su oracle
#首次运行，生成~/.vnc/xstartup等配置文件
vncserver :1 -geometry 1024x768
```
我这里设置的密码是 `vnc@2021`
oracle用户执行以下命令，直接整体复制粘贴到终端就行（不用一行一行复制）。
```bash
#配置VNC默认启动openbox
echo "openbox-session &" > ~/.vnc/xstartup
# 停止服务
vncserver -kill :1
#重新开启vnc服务
vncserver :1 -geometry 1024x768
```
## 客户端连接VNC实现远程控制
使用你的VNC客户端连接就行了，会的就略过吧。
我用的是：[VNC Viewer点击下载](https://www.realvnc.com/en/connect/download/viewer/)
我的地址如下：

```bash
172.16.184.5:5901
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210129111608185.png)
然后输入上面设置的连接密码就可以了。我这里设置的密码是 `vnc@2021`

如果你连接的时候发现，没有界面，是黑屏的只有一个鼠标，那么可以**重启一下VNC服务**试试。
切换到oracle用户`su oracle`
命令：

```bash
vncserver -kill :1
vncserver :1 -geometry 1024x768

```
是不是很简单！

如果需要更详细的教程，请看：
《Centos7安装和配置VNC服务器 - openbox篇》
[https://blog.csdn.net/lxyoucan/article/details/113210891](https://blog.csdn.net/lxyoucan/article/details/113210891)

## 安装oracle安装程序依赖程序包
root用户执行以下命令,`su root`
```bash
yum -y install binutils compat-libcap1  compat-libstdc++-33 compat-libstdc++-33*.i686 elfutils-libelf-devel gcc gcc-c++ glibc*.i686 glibc glibc-devel glibc-devel*.i686 ksh libgcc*.i686 libgcc libstdc++ libstdc++*.i686 libstdc++-devel libstdc++-devel*.i686 libaio libaio*.i686 libaio-devel libaio-devel*.i686 make sysstat unixODBC unixODBC*.i686 unixODBC-devel unixODBC-devel*.i686 libXp
```
## 安装中文字体解决中文乱码问题
默认情况下，因CentOS 中缺少中易宋体18030所以会导致中文显示成□□□□□的问题。
中文是世界上最美的文字，不能显示太可惜了。很简单增加所需字体就行了。操作如下：
下载字体：
[https://download.csdn.net/download/lxyoucan/14968070](https://download.csdn.net/download/lxyoucan/14968070)
root执行以下命令：
新建文件夹
```bash
mkdir -p /usr/share/fonts/zh_CN/TrueType
```
`zysong.ttf`上传到/usr/share/fonts/zh_CN/TrueType目录

```bash
chmod 75 /usr/share/fonts/zh_CN/TrueType/zysong.ttf
```
字体安装完成，这样安装oracle就不会中文乱码了。

就喜欢英文安装界面，想用英文界面怎么办呢？
如果不想用中文界面安装，安装前运行以下命令，临时使用英文环境。

```bash
LANG=en_US
```


## 上传并解压安装包
上传安装包到 CentOS7服务器。我上传到 `/home/oracle/`目录了。
上传以后，文件路径和名称如下：

```bash
[oracle@localhost ~]$ pwd
/home/oracle
[oracle@localhost ~]$ ls
p13390677_112040_Linux-x86-64_1of7.zip  p13390677_112040_Linux-x86-64_2of7.zip
```
只需要`*1of7.zip`,`*2of7.zip` 两个压缩包即可。

如果没有unzip工具，安装unzip用于文件解压root执行以下面

```bash
yum install unzip
```

oracle用户登录vnc，执行下面命令，解压安装包
```bash
#解压第1个zip
unzip p13390677_112040_Linux-x86-64_1of7.zip
#解压第2个zip
unzip p13390677_112040_Linux-x86-64_2of7.zip
```
解压出 database，已被安装使用。
文件如下：

```bash
[oracle@localhost ~]$ ls
database  p13390677_112040_Linux-x86-64_1of7.zip  p13390677_112040_Linux-x86-64_2of7.zip
```

前期准备工作已经完毕！

<hr>

# 安装oracle实战
准备工作已经结束了，接下来的安装工作就跟在windows下安装oracle差不多了。先总结一下，基本就是根据界面提示就可以一路“`下一步（N）`”就可以完成了。
需要稍微注意的就是：
1. 桌面类与服务器类的选择
2. 超级管理员密码的设置
3. 先决条件检查

其它的根据自己的需要，或者一路“`下一步（N）`”就可以完成了。为了一些朋友更直观的观看，我把每一步都截图了，可以跳着看。

## oracle用户登录vnc远程桌面。
进入`~/database/`目录。
```bash
#进入安装目录
cd ~/database/
#运行安装程序
./runInstaller
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202144033104.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202144115400.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)

## 配置安全更新
根据需要设置，我这里就不设置了。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202144454451.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 下载软件更新
根据个人需要选择，我这里选择 `跳过软件更新（S）`。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202144643740.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 网络安装选项
选择“`创建和配置数据库（C）`”
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202144833620.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 桌面类 or 服务器类
描述中已经说的很清楚了，根据自己需要选择。这里我选择的是`服务器类（S）`。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202145134580.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 安装类型
我选默认的，`单实例数据库安装（S）`根据实际需要选择。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202145313770.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 典型安装
默认`典型安装（T）`即可。
![在这里插入图片描述](https://img-blog.csdnimg.cn/2021020214545713.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 典型安装配置
主要设置一下密码，其他默认即可。这里密码要在大写字母+小写字母+数字组合。比如：我设置的是`Database123`。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202145942205.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 创建产品清单
默认即可。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202150120775.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 执行先决条件检查
这一步要稍花一些时间处理。每个人的显示可能略有不同。比如：物理内存的检测，我这个1G内存就会提示小于预期。
处理方法：
- 根据提示信息做处理即可，比如：内存小了，加大内存啊。
- 执行`修补并再次检查（F）` 可以自动修复
- 以上都解决不了，百度一下你就知道。基本都是有解决办法的。

没解决之前我的显示如下：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202151138502.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
执行`修补并再次检查（F）` 
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202151223407.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
方法上面描述的很清楚。
root权限执行：

```bash
/tmp/CVU_11.2.0.4.0_oracle/runfixup.sh
```
执行完后，点击上面对话框中的`确定（O）` 这里发现大部分都修复了。如下：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202151720157.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
剩下的警告尽量解决，如果自己知道影响不大直接点右上角 `☐全部忽略`即可。
比如：我的虚拟机内存，比预期值差30MB左右，影响不大直接忽略也可以。
解决方法也很简单，加大内存即可。即可写教程了，就追求完美吧，我把虚拟机内存加大一些。
### 解决 包：pdksh-5.2.14 警告
这个警告，我猜测直接忽略就行了。因为本机已经安装了ksh-20120801-142.el7.x86_64。
`yum search pdksh`中搜索没的搜索到它。只能手动安装了。

```bash
#下载安装包
wget  http://vault.centos.org/5.11/os/x86_64/CentOS/pdksh-5.2.14-37.el5_8.1.x86_64.rpm
```
如果没有wget就安装一下 `yum install wget`
执行安装操作。
```bash
rpm -ivh pdksh-5.2.14-37.el5_8.1.x86_64.rpm
```
执行结果如下，与已经安装的冲突了，安装失败了。
```bash
rpm -ivh pdksh-5.2.14-37.el5_8.1.x86_64.rpm 
警告：pdksh-5.2.14-37.el5_8.1.x86_64.rpm: 头V3 DSA/SHA1 Signature, 密钥 ID e8562897: NOKEY
错误：依赖检测失败：
	pdksh 与 (已安裝) ksh-20120801-142.el7.x86_64 冲突
```
**卸载冲突**

```bash
rpm -e ksh-20120801-142.el7.x86_64
```
**再次安装**

```bash
rpm -ivh pdksh-5.2.14-37.el5_8.1.x86_64.rpm
```
全过程如下：

```bash
[root@localhost ~]# rpm -ivh pdksh-5.2.14-37.el5_8.1.x86_64.rpm 
警告：pdksh-5.2.14-37.el5_8.1.x86_64.rpm: 头V3 DSA/SHA1 Signature, 密钥 ID e8562897: NOKEY
错误：依赖检测失败：
	pdksh 与 (已安裝) ksh-20120801-142.el7.x86_64 冲突
[root@localhost ~]# rpm -e ksh-20120801-142.el7.x86_64
[root@localhost ~]# rpm -ivh pdksh-5.2.14-37.el5_8.1.x86_64.rpm
警告：pdksh-5.2.14-37.el5_8.1.x86_64.rpm: 头V3 DSA/SHA1 Signature, 密钥 ID e8562897: NOKEY
准备中...                          ################################# [100%]
正在升级/安装...
   1:pdksh-5.2.14-37.el5_8.1          ################################# [100%]
```
**重新检测，发现警告消失了！！！**

### Swap分区设置
**若检查中无此项，可忽略！** 
这个问题之前有遇到过，写这篇文章又没有了。下面解决办法供参考。

 如果Swap空间不符合要求，oracle 安装文件检查发现swap 空间不足。
 大小一般设置为一般为内存的1.5倍。

（root权限）查询当时Swap分区设置情况。

```bash
swapon -s
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210201220640383.png)
或者使用`free`工具来查看内存和Swap情况。

```bash
free -m
```
结果如下单位（MB）：

```bash
[root@localhost ~]# free -m
              total        used        free      shared  buff/cache   available
Mem:           1475         439         171          13         865         877
Swap:          2047           0        2047
```
**创建Swap文件**
接下来我们将在文件系统上创建swap文件。我们要在`根目录/`下创建一个名叫`swapfile`的文件，当然你也可以选择你喜欢的文件名。该文件分配的空间将等于我们需要的swap空间。
一般 内存的 1.5倍以上就好了。也可以根据安装程序的提示来。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202155013609.png)

root执行以下命令，创建swap分区，
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202000241726.png)

```bash
#创建swap文件 bs=2300的设置的值一般为内存的1.5倍以上 
dd if=/dev/zero of=/var/swap bs=2500 count=1000000
#需要更改swap文件的权限，确保只有root才可读
chmod 600 /var/swap
#告知系统将该文件用于swap
mkswap /var/swap
#开始使用该swap
swapon /var/swap
#使Swap文件永久生效,/etc/fstab加入配置
echo "/var/swap   swap    swap    sw  0   0" >> /etc/fstab
```

> 如果上面创建后发现，大小创建错误了。如何重置呢？
> 
> `swapoff -a`
>  `rm /var/swap`
>  上面命令就可以删除了，然后重新创建合适的swap文件就行了。

### 所有警告消失了
经过我们的不断努力，所有警告都消失了。有一些警告虽然没影响什么，有了总让人不舒服。没有⚠️真是太舒服了。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202155357486.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 概要
这里显示了安装配置的概要部分，检查一下是否正确。没问题就开始安装吧！
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202155757483.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 安装产品
上面折腾了这么久终于迎来了真正的安装操作了。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202155906324.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 进度70% ins_emagent.mk错误弹框
它来了，它来了，我等待好久了。

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202160136258.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
编辑：
/home/oracle/app/oracle/product/11.2.0/dbhome_1/sysman/lib/ins_emagent.mk
约176行，可以搜索`$(MK_EMAGENT_NMECTL)` 关键字快速找到。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202161046615.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
修改后如下：

```bash
#===========================
#  emdctl
#===========================

$(SYSMANBIN)emdctl:
	$(MK_EMAGENT_NMECTL) -lnnz11

#===========================
#  nmocat
#===========================
```
修改完成后，点击`重试（R）`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202161549679.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 复制数据库文件
上面的问题解决后，安装一会儿就会出现如下的界面。耐心等待即可。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202161826301.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 数据库创建完成
经过一段时间的等待，终于弹出如下界面。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202162553269.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## 执行配置脚本
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202162714164.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
根据上图提示,root 执行上面两个脚本就可以了。
执行结果如下：
[root@localhost ~]# /home/oracle/app/oraInventory/orainstRoot.sh 
更改权限/home/oracle/app/oraInventory.
添加组的读取和写入权限。
删除全局的读取, 写入和执行权限。

更改组名/home/oracle/app/oraInventory 到 database.
脚本的执行已完成。

```bash
[root@localhost ~]# /home/oracle/app/oraInventory/orainstRoot.sh 
更改权限/home/oracle/app/oraInventory.
添加组的读取和写入权限。
删除全局的读取, 写入和执行权限。

更改组名/home/oracle/app/oraInventory 到 database.
脚本的执行已完成。
[root@localhost ~]# /home/oracle/app/oracle/product/11.2.0/dbhome_1/root.sh 
Performing root user operation for Oracle 11g 

The following environment variables are set as:
    ORACLE_OWNER= oracle
    ORACLE_HOME=  /home/oracle/app/oracle/product/11.2.0/dbhome_1

Enter the full pathname of the local bin directory: [/usr/local/bin]: 
   Copying dbhome to /usr/local/bin ...
   Copying oraenv to /usr/local/bin ...
   Copying coraenv to /usr/local/bin ...


Creating /etc/oratab file...
Entries will be added to the /etc/oratab file as needed by
Database Configuration Assistant when a database is created
Finished running generic part of root script.
Now product-specific root actions will be performed.
Finished product-specific root actions.
[root@localhost ~]# 

```
执行完成这两个脚本，点击`确定`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202163044864.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
## Oracle Database 的安装已成功
经过我们的努力，终于走到了这一步。
Oracle Database 的安装已成功。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202163511782.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)
点击`关闭`即可。

# 防火墙放行1521
默认端口是1521

```bash
# 防火墙放行1521oracle端口
firewall-cmd --add-port=1521/tcp
firewall-cmd --add-port=1521/tcp --permanent
```

# 配置环境变量

```bash
su oracle
```
切换到oracle用户操作。
编辑配置文件

```bash
vi ~/.bash_profile
```
文件末尾加入以下内容，ORACLE_HOME中换成你实际安装的路径

```bash
export ORACLE_HOME=/home/oracle/app/oracle/product/11.2.0/dbhome_1/
export ORACLE_SID=orcl
export PATH=$PATH:$ORACLE_HOME/bin
```
使用配置文件立即生效。

```bash
source ~/.bash_profile
```
# 日常运维
## 启动oracle

```bash
su oracle
sqlplus /nolog
SQL> connect /as sysdba
SQL> startup
```
## sys用户登录

```bash
[oracle@localhost ~]$ sqlplus /nolog

SQL*Plus: Release 11.2.0.4.0 Production on Tue Feb 2 02:59:38 2021

Copyright (c) 1982, 2013, Oracle.  All rights reserved.

SQL> connect as sysdba
Enter user-name: sys
Enter password: 
Connected.
SQL> select 1 from dual;

	 1
----------
	 1

SQL> 

```
没有问题，说明oracle本地连接oracle成功。
## 启动监听

```bash
lsnrctl start
```
### PLSQL连接测试
使用其他机器连接我们刚安装好的oracle进行连接测试。
修改配置文件`C:\app\itkey\product\11.2.0\client_1\network\admin\tnsnames.ora`（路径根据实际情况来）
```bash
CentOS7ORCL =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 172.16.184.5)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl)
    )
  )
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210202110903459.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2x4eW91Y2Fu,size_16,color_FFFFFF,t_70)

# 总结
CentOS7安装Oracle 11g不难，遇到问题都能百度解决。就是对比windows下安装有些麻烦。安装中遇到的小问题大多因为oracle 11g年岁己高导致的。我猜测在新版的系统中安装新版的Oracle 可能会更简单。甚至可能像windows中那样简单吧！或者使用 Oracle 自己的linux系统安装起来会不会更容易呢？等我以后有空了，可以测试一下。
# 参考文档
《2021年CentOS7安装Oracle11g全记录》
[https://blog.csdn.net/lxyoucan/article/details/113177763](https://blog.csdn.net/lxyoucan/article/details/113177763)


《在CentOS 7上添加Swap交换空间》
[https://blog.csdn.net/zstack_org/article/details/53258588](https://blog.csdn.net/zstack_org/article/details/53258588)

《Error in invoking target 'install' of makefile '../dbhome_1/ctx/lib/ins_ctx.mk' ...》
[https://blog.csdn.net/xch_yang/article/details/104389154](https://blog.csdn.net/xch_yang/article/details/104389154)

《记一次oracle安装错误：INFO: //usr/lib64/libstdc++.so.5: undefined reference to `memcpy@GLIBC_2.14'》
[https://www.cnblogs.com/yhq1314/p/10830300.html](https://www.cnblogs.com/yhq1314/p/10830300.html)


《Linux/Centos 安装oracle报错“调用makefile '/oracle/product/11.2.0/dbhome_1/sysman/lib/ins_emagent.mk的目标” 解决》
[https://blog.csdn.net/weixin_41078837/article/details/80585287](https://blog.csdn.net/weixin_41078837/article/details/80585287)
《在CenOS 上安装oracle 11g R2的时候提示:pdksh包没有安装》
[https://my.oschina.net/u/3318604/blog/1527845](https://my.oschina.net/u/3318604/blog/1527845)
