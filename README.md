# gdc-sigma.github.io

[![Build Status](https://travis-ci.org/gdc-sigma/gdc-sigma.github.io.svg?branch=source)](https://travis-ci.org/gdc-sigma/gdc-sigma.github.io)

这里是 GDC Sigma 官方博客的 Repository。 <https://gdc-sigma.github.io/>

## 博文编写流程

在开始编写博文前，请先确认你已拥有本 Repository 的写权限。联系 `gdcsigmaer@gmail.com` 以获取权限。

### 设置环境

首先，使用 `git` 下载 Repository：

```bash
git clone https://github.com/gdc-sigma/gdc-sigma.github.io.git
```

接下来便可以开始配置开发环境了。本博客使用 [Hexo](https://hexo.io/) 框架进行构建，首先需要你先安装 [NodeJS](https://nodejs.org/en/download/) 和 [NPM](https://www.npmjs.com/get-npm)，然后使用如下指令安装项目依赖：

```bash
npm ci
```

之后你便能通过如下指令启动 Hexo Server：

```bash
npm run server
```

### 开始编写博文

你可以在 `source/_posts` 目录下创建一个 Markdown 文件，并在其中编写博文。你可以通过查看其他博文的 `.md` 文件来参考博文编写的格式。

### 发布博文

在你本地测试过博文内容正确后，你便可以提交你的改动并通过如下指令发布到 Github Repository：

```bash
git push
```

完成上传后，你的代码将由 Travis 自动构建并部署到 <https://gdc-sigma.github.io/>。Travis 构建的过程耗时较长，可能在你上传改动几分钟后才能完成部署。你可以在 [Travis 控制台](https://travis-ci.org/gdc-sigma/gdc-sigma.github.io)查看当前的构建进度。

## 联系方式

- Sigma 团队官方 Email: `gdcsigmaer@gmail.com`
