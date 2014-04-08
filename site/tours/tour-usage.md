---
layout: tour
title: 使用方法 - Simditor
name: tour-usage
root: ../
---

###第一步：下载并引用

在[这里]({{ page.root }}download.html)下载并解压最新版的Simditor文件，然后在页面中引入这些文件：

```html
<link rel="stylesheet" type="text/css" href="[style path]/font-awesome.css" />
<link rel="stylesheet" type="text/css" href="[style path]/simditor.css" />

<script type="text/javascript" src="[script path]/jquery-2.1.0.js"></script>
<script type="text/javascript" src="[script path]/module.js"></script>
<script type="text/javascript" src="[script path]/uploader.js"></script>
<script type="text/javascript" src="[script path]/simditor.js"></script>
```

其中，

* Simditor基于[jQuery](http://jquery.com)开发，`jquery.js`是必需的；
* [font-awesome.css](http://fontawesome.io/)是一个图片字体icon库，Simditor基于它来定义工具栏的按钮样式。为了让icon能够正常显示，需要将font文件（fontawesome-webfont.xxx）放到正确的路径里：`../fonts/`（如果把font-awsome.css放在`styles`文件夹，那么就应该把font文件放在跟`styles`同级的`fonts`文件夹）。另外，如果想自定义工具栏按钮的样式就可以不必引用`font-awesome.css`；
* [module.js](http://https://github.com/mycolorway/simple-module)是彩程内部使用的CoffeeScript组件抽象类，Simditor基于这个类开发；
* [uploader.js](https://github.com/mycolorway/simple-uploader)是一个与UI无关的上传逻辑，如果你的项目不需要上传附件，那么可以不引用这个文件。

如果觉得需要引用的脚本文件太多，可以用`simditor-all.js`（里面包含了`module.js``uploader.js`和`simditor.js`）替换：

```html
<link rel="stylesheet" type="text/css" href="[style path]/font-awesome.css" />
<link rel="stylesheet" type="text/css" href="[style path]/simditor.css" />

<script type="text/javascript" src="[script path]/jquery-2.1.0.js"></script>
<script type="text/javascript" src="[script path]/simditor-all.js"></script>
```


###第二步，初始化配置

在使用Simditor的HTML页面里应该有一个对应的`textarea`文本框，例如：

```html
<textarea id="editor" placeholder="这里输入内容" autofocus></textarea>
```

我们需要在这个页面的脚本里初始化Simditor：

```js
var editor = new Simditor({
  textarea: $('#editor')
});
```

`textarea`是初始化Simditor的必需选项，可以接受jQuery Object、HTML Element或者Selector String。另外，Simditor还支持这些可选option：

* `placeholder`（默认值：''）编辑器的placeholder，如果为空Simditor会取textarea的placeholder属性
* `toolbar` （默认值：true）是否显示工具栏按钮
* `toolbarFloat` （默认值：true）是否让工具栏按钮在页面滚动的过程中始终可见
* `defaultImage`（默认值：'images/image.png'）编辑器插入混排图片时使用的默认图片
* `tabIndent`（默认值：true）是否在编辑器中使用`tab`键来缩进
* `params`（默认值：{}）键值对，在编辑器中增加hidden字段（input:hidden），通常用于生成form表单的默认参数
* `upload`（默认值：false）false或者键值对，编辑器上传本地图片的配置，常用的属性有`url`和`params`
* `pasteImage`（默认值：false）是否允许粘贴上传图片，依赖`upload`选项，仅支持Firefox和Chrome浏览器

更详细的配置说明可以参考Simditor的[配置文档]({{ page.root }}/docs/doc-config.html)。配置完成之后刷新页面，Simditor应该就可以正确加载了。

###最后，自定义样式和交互

每个项目都有不同的设计风格，大多数时候我们需要修改Simditor的样式，让它的样式跟项目的风格相符。

`simditor.css`是通过[Sass](http://sass-lang.com/)自动生成的代码，所以推荐大家修改`simditor.scss`，然后再重新生成css代码。

`.editor-style`选择符下面的样式，是Simditor输出HTML的中文排版样式，大家可以根据自己项目的情况进行调整。另外，如果不想使用[font-awesome.css](http://fontawesome.io/)来实现工具栏按钮的icon，可以将`font-awesome.css`去掉，然后增加`.toolbar-item-[button name]`选择符来自定义按钮样式。

有的项目有一些特殊的交互需求，例如自动保存功能或者@人的功能，我们可以基于[Simple Module](http://https://github.com/mycolorway/simple-module)来给Simditor编写扩展。关于编写扩展更详细的介绍请参考教程[《编写扩展》]({{ page.root }}tours/tour-plugin.html)。


