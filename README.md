# gdc-sigma.github.io

[![Build Status](https://travis-ci.org/gdc-sigma/gdc-sigma.github.io.svg?branch=source)](https://travis-ci.org/gdc-sigma/gdc-sigma.github.io)

这里是 GDC Sigma 官方博客的 Repository。 [http://gdc-sigma.com/](http://gdc-sigma.com/)

## 博文编写流程

在开始编写博文前，请先确认你已拥有本 Repository 的写权限。联系 `gdcsigmaer@gmail.com` 以获取权限。

### 设置环境

首先，使用 `git` 下载 Repository：

```bash
git clone https://github.com/gdc-sigma/gdc-sigma.github.io.git
```

接下来便可以开始配置开发环境了。本博客使用 [Hexo](https://hexo.io/) 框架进行构建，你可以选择使用 Repository 提供的 Dockerfile 或者直接在本地安装 Hexo 来配置开发环境。

#### Docker

Repository 中提供了可用于构建开发用 Docker 容器的 `Dockerfile`。如果你已经在本机上安装了 [Docker](https://www.docker.com/)，那么你可以通过如下命令安装该 Docker 容器：

```bash
# 构建 Docker 镜像
docker build -t sigma-blog .

# 构建并启动 Docker 容器
docker run -it --name sigma-blog -h sigma-blog -v .:/sigma-blog -p 4000:4000 sigma-blog
```

执行上述命令后，Docker 容器中的 Hexo Server 便会在当前命令行窗口的前台运行，你可以通过 [http://localhost:4000/](http://localhost:4000/) 访问该本地预览站点。通过按下 `CTRL + C` 键即可关闭 Hexo Server 并退出 Docker 容器。

完成上述命令，以后你便可以通过如下指令直接启动该 Docker 容器：

```bash
docker start -i sigma-blog
```

值得注意的是，Hexo Server 的文件系统监视功能可能无法在 Docker 容器中正常工作，使得博客文件发生修改时 Hexo Server 无法自动更新预览站点。你可以通过手动重启 Docker 容器来刷新预览站点。

#### NPM

你也可以不使用 Docker，在本机使用 NodeJS 和 NPM 安装开发环境。假设你已安装 [NodeJS](https://nodejs.org/en/download/) 和 [NPM](https://www.npmjs.com/get-npm)，你可以使用如下指令安装项目依赖：

```bash
# 安装 hexo-cli
npm install -g hexo-cli

# 安装项目依赖
npm install
```

之后你便能通过如下指令启动 Hexo Server：

```bash
hexo server
```

### 开始编写博文

你可以在 `source/_posts` 目录下创建一个 Markdown 文件，并在其中编写博文。你可以通过查看其他博文的 `.md` 文件来参考博文编写的格式。

### 发布博文

在你本地测试过博文内容正确后，你便可以提交你的改动并通过如下指令发布到 Github Repository：

```bash
git push
```

完成上传后，你的代码将由 Travis 自动构建并部署到 [http://gdc-sigma.com/](http://gdc-sigma.com/)。Travis 构建的过程耗时较长，可能在你上传改动几分钟后才能完成部署。你可以在 [Travis 控制台](https://travis-ci.org/gdc-sigma/gdc-sigma.github.io)查看当前的构建进度。

## 联系方式

- Sigma 团队官方 Email: `gdcsigmaer@gmail.com`
