# Windows部署前端Linux开发环境

## 什么是wsl

wsl全称：Windows Subsystem for Linux，wsl2对wsl进行了巨大的改进，在实现方式和性能上，有很大的不同。

## 安装wsl

#### 安装linux子系统

1. 以**管理员身份**打开 PowerShell 并运行：

   ```powershell
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
   ```

2. 出现提示时，重启计算机。

3. 从 Microsoft Store 安装 Linux发行版：[点击获取ubuntu 18](https://www.microsoft.com/zh-cn/p/ubuntu-1804-lts/9n9tngvndl3q?rtc=1&activetab=pivot:overviewtab)，选择从appstore获取，下载之后选择启动。

4. 进入安装页面，点击回车，输入用户名及密码，输入完用户名和密码之后，wsl就安装完毕了。现在你拥有了一个linux子系统了。

#### 升级为wsl2

1. 以**管理员身份**打开 PowerShell 并运行:

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

2. 重启计算机
3. 打开 PowerShell

```powershell
# 输入：
wsl -l

# 你将会看见：
适用于 Linux 的 Windows 子系统:
Ubuntu-18.04 (默认)

# 接着输入：
wsl --set-version Ubuntu-18.04 2

# 等待安装完毕
# 接着输入
wsl -l -v

# 如果为下面的结果，则表示安装成功
 NAME          STATE    VERSION
*Ubuntu-18.04  Stopped  2

# 最后设置以后安装的linux都安装到wsl2中：
wsl --set-default-version 2
```

## 进入wsl

#### vscode设置

打开vscode，此时会提示安装remote-wsl插件，安装完之后，打开vscode终端，将默认shell切换为wsl。

#### gitbash设置

打开gitbash，依次输入如下指令：

```bash
# 启动bash的时候切换至wsl
echo "winpty wsl" >> ~/.bashrc
# 刷新配置
source ~/.bashrc
```

#### cmd、powershell进入wsl

输入`wsl` 或者` bash`即可

## Linux开发环境设置

至此，你已经拥有了一个linux开发环境。接下来我们来配置linux前端开发环境。

#### Ubuntu换源【重要，一定要做】

打开vscode wsl bash / git bash （已经配置了自动进入wsl的gitbash），建议在vscode wsl中进行下面所有操作，方便复制粘贴。

输入指令：

```bash
sudo vim /etc/apt/sources.list
```

按住d键，删除所有内容，然后按`a`或者`i` 进入编辑模式。

确保vim左下角的状态为 `-- INSERT --`。

将下面的代码粘贴过去：

```bash
deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse
```

注意如果粘贴的内容和拷贝的内容有差别，重新试一下。

粘贴完之后，按`ESC`进入命令行模式，输入 `:wq`保存好了的文件。

然后分别执行指令：

```bash
sudo apt-get update
sudo apt-get upgrade
```

换至阿里源。

#### nvm

在wsl命令行中输入：

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
```

如果出现443错误，请先进行换源。

然后执行

```bash
source ~/.bashrc
```

nvm安装完毕。

#### node

安装完nvm之后，输入：

```bash
# 安装当前最新稳定版
nvm install stable

# 安装指定版本
nvm install xx.xx.xx

# 将某个版本的node设置为默认的node
nvm alias default xx.xx.xx

# 查看已安装了的node版本
nvm ls

#注意, nvm use xx.xx.xx 指令是 指定当前shell使用的node。shell进程退出后，仍然会使用默认版本的node
```

不同于windows，这里node安装完之后，npm也附带安装完毕。

如果安装了zsh，参考zsh部分，设置nvm的path。

#### oh-my-zsh

先安装zsh：

```bash
sudo apt-get install zsh
```

再安装`oh-my-zsh`

```bash
# 先试试这个
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# 不行再试试这个
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

由于公司网络的原因，大概率443。这里提供一个离线安装的方式:

```bash
# clone 项目
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
# 拷贝配置
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
# 刷新
source ~/.zshrc
```

安装完毕之后，一定要选择`y` 将辛辛苦苦安装上的`oh-my-zsh`设置为默认shell。

*直接改观：bash界面好看了，还能配置各种主题;  按 向上 的方向键，可以补全命令（补全以前输入过的）了，git有了各种简便的快捷组合；再也不用输入烦人的`cd`了；可以输入数字来跳转路径了，等等......*

**以下为可选**

可以参考oh-my-zsh的插件配置，配置一些有用的插件，如 `z` 这种自动跳转插件。

#### 设置oh-my-zsh nvm path

安装完oh-my-zsh之后，nvm指令会不可用：

```bash
zsh: command not found: nvm
```

我们来修复它：

```bash
# 添加path
echo "export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm" >> ~/.zshrc

# 刷新配置
source ~/.zshrc
```

#### 设置ssh key

你需要再linux环境中重新生成ssh key：

```bash
ssh-keygen -o
```

一路回车就好。

你的ssh公钥：

```bash
cat ~/.ssh/id_rsa.pub
```

然后重新配置下gitlab和github即可。






















