#!/bin/bash
#因为脚本内容大量中文，临时设置中文环境
export LC_ALL=zh_CN.UTF-8
echo '------欢迎使用 CentOS7 Oracle 11G安装助手------'
echo '脚本测试环境如下：'
echo '操作系统: CentOS Linux release 7.9.2009 (Core)'
echo 'Oracle: linux.x64_11g_11.2.0.4'
echo '注意！其他环境尚未测试,请谨慎使用！理论上CentOS7与Oracle 11G都支持。'
echo '不建议直接在生产环境使用，因此脚本出现任何损失本人不负责。'
echo '脚本替我们做了哪些？脚本只是自动安装和配置所需的程序包，理论上对系统稳定性不会造成任何损害的。'
echo '* 创建oracle用户和组。'
echo '* 搭建图形化的操作环境：VNC远程。'
echo '* 防火墙放行VNC端口5901和Oracle默认端口1521。'
echo '* 安装oracle安装程序依赖程序包。'
echo '* 安装中文字体解决中文乱码问题。'
echo '* 单独安装pdksh-5.2.14'
echo '博文地址：https://blog.csdn.net/lxyoucan/article/details/113381858'
echo '------欢迎使用 CentOS7 Oracle 11G安装助手------'
echo '当前操作系统版本是：'
cat /etc/redhat-release
read -r -p "确定继续执行吗? [Y/n] " input

case $input in
    [yY][eE][sS]|[yY]|[1])
		echo '-------------正在安装VNC图形化相关软件----------------'
    #图形界面必备`X Window System`
    yum -y groupinstall "X Window System"
    #安装epel源
    yum -y install epel-release
    #安装VNC+图形需要的软件
    yum -y install tigervnc-server openbox xfce4-terminal tint2 cjkuni-ukai-fonts network-manager-applet
    echo '-------------自动修改/etc/xdg/openbox/autostart配置文件-------------'
    #自动修改/etc/xdg/openbox/autostart配置文件
    echo 'if which dbus-launch >/dev/null && test -z "$DBUS_SESSION_BUS_ADDRESS"; then' > /etc/xdg/openbox/autostart
    echo '       eval `dbus-launch --sh-syntax --exit-with-session`' >> /etc/xdg/openbox/autostart
    echo 'fi' >> /etc/xdg/openbox/autostart
    echo 'tint2 &' >> /etc/xdg/openbox/autostart
    echo 'nm-applet  &' >> /etc/xdg/openbox/autostart
    echo 'xfce4-terminal &' >> /etc/xdg/openbox/autostart
    echo ' ' >> /etc/xdg/openbox/autostart
    cat /etc/xdg/openbox/autostart
    echo '-------------防火墙放行VNC端口5901-------------'
    firewall-cmd --add-port=5901/tcp
    firewall-cmd --add-port=5901/tcp --permanent
    echo '-------------防火墙放行VNC端口1521-------------'
    firewall-cmd --add-port=1521/tcp
    firewall-cmd --add-port=1521/tcp --permanent
    echo '-------------安装oracle依赖的程序包-------------'
    yum -y install binutils compat-libcap1  compat-libstdc++-33 compat-libstdc++-33*.i686 elfutils-libelf-devel gcc gcc-c++ glibc*.i686 glibc glibc-devel glibc-devel*.i686 ksh libgcc*.i686 libgcc libstdc++ libstdc++*.i686 libstdc++-devel libstdc++-devel*.i686 libaio libaio*.i686 libaio-devel libaio-devel*.i686 make sysstat unixODBC unixODBC*.i686 unixODBC-devel unixODBC-devel*.i686 libXp
    echo '-------------正在安装中易宋体18030-------------'
    #新建字体目录
    mkdir -p /usr/share/fonts/zh_CN/TrueType
    #复制字体到字体目录
    cp zysong.ttf /usr/share/fonts/zh_CN/TrueType/zysong.ttf
    #更改字体文件属性，使其生效
    chmod 75 /usr/share/fonts/zh_CN/TrueType/zysong.ttf
    echo '字体安装完成！'
    ls /usr/share/fonts/zh_CN/TrueType
    echo '-------------正在尝试安装pdksh-5.2.14-------------'
    echo '尝试卸载冲突ksh-20120801-142.el7.x86_64'
    rpm -e ksh-20120801-142.el7.x86_64
    rpm -ivh pdksh-5.2.14-37.el5_8.1.x86_64.rpm
    echo '查询是否安装成功：'
    rpm -q pdksh
    echo '脚本执行完成！享受oracle安装吧!'
		;;

    [nN][oO]|[nN]|[0])
		echo "No"
       	;;

    *)
		echo "Invalid input..."
		exit 1
		;;
esac
