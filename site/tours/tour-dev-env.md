---
layout: tour
title: 搭建环境 - Simditor
id: tour-dev-env
root: ../
---

这篇教程主要介绍，如何在本地搭建 Simditor 的开发环境。

###获取源代码

在 Github 上 fork Simditor 的源代码仓库（[什么是 fork？](https://help.github.com/articles/fork-a-repo)）：

![Fork Simditor](http://pic.yupoo.com/farthinker_v/DFeVxRCs/custom.jpg)

然后将 fork 之后的仓库 clone 到本地：

```bash
$ git clone git@github.com:[your username]/simditor.git
```


###用 Bundler 管理 Gem 包

Simditor 使用 [Bundler](http://bundler.io/) 来管理依赖的 Ruby Gem：

* [sass](https://github.com/nex3/sass)：用来将 scss 文件编译为 css 文件
* [github-pages](https://github.com/github/pages-gem): 在本地安装 [Github Pages](https://pages.github.com/) 使用的 [Jekyll](http://jekyllrb.com/) 环境，用来生成 Simditor 的网站

首先，确保你的系统中已经安装了 [Ruby](https://www.ruby-lang.org/en/installation/)，然后在命令行中安装 Bundler：

```bash
$ gem install bundler
```

进入 Simditor 根目录，安装依赖的 Gem 包：

```bash
$ cd simditor
$ bundle install
```


###用 Grunt 管理自动化任务

Simditor 使用 [Grunt](http://gruntjs.com/) 来实现本地的自动化任务，例如运行本地开发服务器、监视源代码文件并自动编译等等。

Grunt 需要通过 [Node.js](http://nodejs.org/) 的包管理工具 npm 来安装，所以先确保你的系统已经安装了 Node.js，然后通过 npm 安装 Grunt 的命令行工具：

```bash
$ sudo npm install -g grunt-cli
```

最后安装 `package.json` 里配置的 grunt 插件：

```bash
$ npm install
```


###用 Bower 管理依赖项目

[Bower](http://bower.io/) 是一个前端项目的包管理工具，Simditor 用它来管理依赖的第三方库：

* [simple-module](https://github.com/mycolorway/simple-module)：是彩程内部使用的 CoffeeScript 组件抽象类
* [simple-uploader](https://github.com/mycolorway/simple-uploader)：一个与 UI 无关的上传逻辑

先通过`npm`安装bower：

```bash
npm install -g bower
```

然后安装 `bower.json` 里面配置的依赖项目：

```bash
bower install
```


###开始开发

现在运行 grunt 的默认任务：

```bash
$ grunt
```

然后用浏览器访问 `http://localhost:3000/demo.html`，就可以打开本地生成的 Simditor 网站了。这个时候修改 Simditor 的源代码，grunt 会自动编译并重新生成网站，你只需要刷新页面就可以测试最新的改动。

如果你需要测试上传功能，只需要给 url 增加一个 upload 参数就可以开启上传本地图片的功能：`http://localhost:3000/demo.html?upload`。
