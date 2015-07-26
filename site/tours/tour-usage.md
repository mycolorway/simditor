---
layout: tour
title: 使用方法 - Simditor
id: tour-usage
root: ../
---

###第一步：下载并引用

在[这里](https://github.com/mycolorway/simditor/releases)下载并解压最新版的 Simditor 文件，然后在页面中引入这些文件：

```html
<link rel="stylesheet" type="text/css" href="[style path]/simditor.css" />

<script type="text/javascript" src="[script path]/jquery.min.js"></script>
<script type="text/javascript" src="[script path]/module.js"></script>
<script type="text/javascript" src="[script path]/hotkeys.js"></script>
<script type="text/javascript" src="[script path]/uploader.js"></script>
<script type="text/javascript" src="[script path]/simditor.js"></script>
```

其中，

* Simditor基于 [jQuery](http://jquery.com) 开发，`jquery.js` 是必需的；
* [module.js](https://github.com/mycolorway/simple-module) 是彩程内部使用的 CoffeeScript 组件抽象类，Simditor 基于这个类开发；
* [hotkeys.js](https://github.com/mycolorway/simple-hotkeys) 用于绑定快捷键，Simditor 依赖此库。
* [uploader.js](https://github.com/mycolorway/simple-uploader) 是一个与 UI 无关的上传逻辑，如果你的项目不需要上传附件，那么可以不引用这个文件。

###第二步，初始化配置

在使用 Simditor 的 HTML 页面里应该有一个对应的 `textarea` 文本框，例如：

```html
<textarea id="editor" placeholder="这里输入内容" autofocus></textarea>
```

我们需要在这个页面的脚本里初始化 Simditor：

```js
var editor = new Simditor({
  textarea: $('#editor')
});
```

`textarea` 是初始化 Simditor 的必需选项，可以接受 jQuery Object、HTML Element 或者 Selector String。另外，Simditor 还支持这些可选 option：

* `placeholder`（默认值：''）编辑器的 placeholder，如果为空 Simditor 会取 textarea 的 placeholder 属性；
* `toolbar` （默认值：true）是否显示工具栏按钮；
* `toolbarFloat` （默认值：true）是否让工具栏按钮在页面滚动的过程中始终可见；
* `toolbarHidden` （默认值：false）是否隐藏工具栏，隐藏后 `toolbarFloat` 会失效；
* `defaultImage`（默认值：'images/image.png'）编辑器插入混排图片时使用的默认图片；
* `tabIndent`（默认值：true）是否在编辑器中使用 `tab` 键来缩进；
* `params`（默认值：{}）键值对，在编辑器中增加 hidden 字段（input:hidden），通常用于生成 form 表单的默认参数；
* `upload`（默认值：false）false 或者键值对，编辑器上传本地图片的配置，常用的属性有 `url` 和 `params`；
* `pasteImage`（默认值：false）是否允许粘贴上传图片，依赖 `upload` 选项，仅支持 Firefox 和 Chrome 浏览器。

更详细的配置说明可以参考 Simditor 的[配置文档]({{ page.root }}/docs/doc-config.html)。配置完成之后刷新页面，Simditor 应该就可以正确加载了。

###最后，自定义样式和交互

每个项目都有不同的设计风格，大多数时候我们需要修改 Simditor 的样式，让它的样式跟项目的风格相符。

`simditor.css` 是通过 [Sass](http://sass-lang.com/) 自动生成的代码，所以推荐大家修改 `simditor.scss`，然后再重新生成css代码。

`.editor-style` 选择符下面的样式，是 Simditor 输出 HTML 的中文排版样式，大家可以根据自己项目的情况进行调整。

有的项目有一些特殊的交互需求，例如自动保存功能或者 @ 人的功能，我们可以基于 [Simple Module](https://github.com/mycolorway/simple-module) 来给 Simditor 编写扩展。关于编写扩展更详细的介绍请参考教程[《编写扩展》]({{ page.root }}tours/tour-plugin.html)。
