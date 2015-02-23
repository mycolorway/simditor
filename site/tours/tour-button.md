---
layout: tour
title: 编写按钮 - Simditor
id: tour-button
root: ../
---

这篇教程主要介绍如何给 Simditor 编写一个 undo 按钮，点击 undo 按钮编辑器的内容会回退到上一个状态。


###基本结构

创建文件 `simditor-undo.coffee`，输入 Simditor 按钮的基本结构：

```coffee
class UndoButton extends Simditor.Button

  name: 'undo'

  icon: 'undo'

  title: '回退'

Simditor.Toolbar.addButton UndoButton
```

Simditor 的按钮都继承自 [Button 类](https://github.com/mycolorway/simditor/blob/master/src/buttons/button.coffee)，跟扩展类似 Simditor 也提供一个方法用来添加按钮：`Simditor.Toolbar.addButton()`。

Button 类有这些可以设置的属性：

* `name` 按钮的名称，用于识别按钮，构造按钮的 class `toolbar-item-[name]`；
* `icon` 按钮icon的名称，对应fonticon的class名称 `icon-[icon]`；
* `title` 按钮的title，鼠标悬停会显示的提示文本；
* `htmlTag` 按钮对应的 html 标签名称，用于识别按钮的激活状态（例如加粗按钮）；
* `disableTag` 在指定的 html 标签中禁用按钮（例如在代码标签中禁用链接按钮）；
* `needFocus` 按钮的功能是否依赖编辑器处于 focus 状态。

更多关于 Button 类的说明请参考文档 [Button]({{ page.root }}docs/doc-button.html)。


###按钮点击事件

按钮被点击之后，Simditor 会调用 Button 的 `command` 方法，我们需要在这个方法里处理按钮的点击事件：

```coffee
class UndoButton extends Simditor.Button

  name: 'undo'

  icon: 'undo'

  title: '回退'

  command: ->
    @editor.undoManager.undo()

Simditor.Toolbar.addButton UndoButton
```

###引用并配置按钮

为了在工具栏上显示 undo 按钮，我们需要编译并引用新编写的按钮文件：

```html
<script type="text/javascript" src="[script path]/jquery.min.js"></script>
<script type="text/javascript" src="[script path]/module.js"></script>
<script type="text/javascript" src="[script path]/simditor.js"></script>
<script type="text/javascript" src="[script path]/simditor-undo.js"></script>
```

然后修改编辑器的 `toolbar` 配置：

```js
var editor = new Simditor({
  textarea: $('#editor'),
  toolbar: ['bold', 'italic', 'underline', 'strikethrough', 'undo']
});
```

Simditor 默认支持的按钮有：bold, italic, underline, strikethrough, ol, ul, blockquote, code, link, image, indent, outdent。
