# GDC-Sigma团队博客使用手册
> 如果问题请联系我or自行google

## 加入团队github

username: gdc-sigma

passwd: ****** 请联系我获取

将你的ssh key加进去即可

## 安装工具
* 安装nvm
```
 $ brew install nvm  
 $ mkdir ~/.nvm
 $ export NVM_DIR=~/.nvm
 $ . $(brew --prefix nvm)/nvm.sh
```
* 安装 nodejs
```
 $ nvm install 4
```

* 安装hexo
```
 $ sudo npm install hexo-cli -g
```

## 初始化项目
* init hexo
```
$ npm install hexo --save
```
* 删除一些文件
```
$ rm -r _config.yml source themes
```
* init git仓库且获取新的数据
```
$ git init
$ git remote add origin git@github.com:gdc-sigma/blog.git
$ git pull origin master
```
* 增加博客
```
$ cd blog/source/_posts
```
在这个目录下面，以md格式存储你的博客文件，图片则放在`blog/source/images`下，然后用`[](/images/xxx.jpg)`的方式使用
注意，博客需要一些规范，在md文件头加上如下信息（示例）：
```
---
title: storm-kafka stream 卡住问题分析
date: 2017-07-29 12:22:50
tags: 搞搞事
---
```
* 预览
```
$ hexo s
```
然后通过`http://localhost:4000`访问预览

*  在blog目录下安装hexo-deployer-git自动部署发布工具
```
 $ npm install hexo-deployer-git --save
```
* 发布到线上
```
$ hexo clean && hexo g && hexo d
```

然后就可以访问`http://gdc-sigma.com`查看啦
