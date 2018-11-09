---
layout: doc
title: Installation - Simditor
id: doc-dev-env
root: ../
---
#Install Source Code

If you want to install the source code and build the project locally, simply follow the steps below.

First, [fork](https://help.github.com/articles/fork-a-repo) Simditor and clone it from Github

![Fork Simditor](http://pic.yupoo.com/farthinker_v/DFeVxRCs/custom.jpg)

```bash
$ git clone git@github.com:[your username]/simditor.git
```


#Install Gem Dependencies

We use [Bundler](http://bundler.io/) to manage the gem dependencies：

* [sass](https://github.com/nex3/sass)：Compile SCSS file to CSS.
* [github-pages](https://github.com/github/pages-gem): Install [Jekyll](http://jekyllrb.com/) which is used by [Github Pages](https://pages.github.com/) locally to produce Simditor site.

Make sure that you have ruby installed in your computer first.

Install Bundler:

```bash
$ gem install bundler
```

Change to Simditor directory, install gems:

```bash
$ cd simditor
$ bundle install
```


#Install Dependencies

Simditor uses [Grunt](http://gruntjs.com/) as the task runner to run tasks such as auto-compiling and watching files.

Grunt needs to be installed by npm. To have npm working, first need to install [Node.js](https://nodejs.org/).

Install Grunt's command line interface (CLI) globally:

```bash
$ sudo npm install -g grunt-cli
```

Install grunt and other dependencies:

```bash
$ npm i
```

#Run Project

Run project with grunt:

```bash
$ grunt
```

Now you can visit the homepage in `http://localhost:3000/demo.html`.
Every time you change the source code of Simditor, Grunt will automatically re-compile the project,
so you can simply test your code by refreshing the page.

To test the uploading feature, add a upload param to the url: `http://localhost:3000/demo.html?upload`
