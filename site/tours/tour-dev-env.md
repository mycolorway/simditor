---
layout: tour
title: 搭建环境 - Simditor
name: tour-dev-env
root: ../
---

这篇教程主要介绍，如何在本地搭建Simditor的开发环境。

###获取源代码

在Github上fork Simditor的源代码仓库（[什么是fork？](https://help.github.com/articles/fork-a-repo)）：

![Fork Simditor](http://pic.yupoo.com/farthinker_v/DFeVxRCs/custom.jpg)

然后将fork之后的仓库clone到本地：

```bash
$ git clone git@github.com:[your username]/simditor.git
```


###安装Gem包

Simditor使用[Bundler](http://bundler.io/)来管理依赖的Ruby Gem：

* [sass](https://github.com/nex3/sass)：用来将scss文件编译为css文件
* [coffee-script](https://github.com/josh/ruby-coffee-script): 用来将coffee文件编译为js文件
* [github-pages](https://github.com/github/pages-gem): 在本地安装[Github Pages](https://pages.github.com/)使用的[Jekyll](http://jekyllrb.com/)环境，用来生成Simditor的网站

首先，确保你的系统中已经安装了[Ruby](https://www.ruby-lang.org/en/installation/)，然后在命令行中安装Bundler：

```bash
$ gem install bundler
```

进入Simditor根目录，安装依赖的Gem包：

```bash
$ cd simditor
$ bundle install
```

###安装Grunt

Simditor使用[Grunt](http://gruntjs.com/)来实现本地的自动化任务，例如运行本地开发服务器、监视源代码文件并自动编译等等。

Grunt需要通过[Node.js](http://nodejs.org/)的包管理工具npm来安装，所以先确保你的系统已经安装了Node.js，然后通过npm安装Grunt的命令行工具：

```bash
$ sudo npm install -g grunt-cli
```

最后安装`package.json`里配置的grunt 插件：

```bash
$ npm install
```

###开始开发

现在运行grunt的默认任务：

```bash
$ grunt
```

然后用浏览器访问`http://localhost:3000/demo.html`，就可以打开本地生成的Simditor网站了。这个时候修改Simditor的源代码，grunt会自动编译并重新生成网站，你只需要刷新页面就可以测试最新的改动。

如果你需要测试上传功能，只需要给url增加一个upload参数就可以开启上传本地图片的功能：`http://localhost:3000/demo.html?upload`。
