---
layout: tour
title: 编写扩展 - Simditor
name: tour-plugin
root: ../
---

这篇教程主要介绍如何为Simditor编写一个自动保存扩展，这个扩展需要实现这些功能：

* 在编辑器的内容发生变化的时候，编辑器的内容会被自动保存到localStorage；
* 编辑器初始化的时候，如果发现localStorage里保存了上一次编辑的内容，扩展会将编辑器的默认值设置为上一次编辑的内容；
* 编辑器所在表单提交的时候，localStorage里保存的内容会被重置


###扩展的基本结构

创建`simditor-autosave.coffee`，输入扩展的基本结构：

```coffee
class SimditorAutosave extends Plugin
  constructor: (@widget) ->
    super @widget
    @editor = @widget

  _init: ->

Simditor.connect SimditorAutosave
```

Simditor的扩展继承自[Simple Module](https://github.com/mycolorway/simple-module)的[Plugin类](https://github.com/mycolorway/simple-module/blob/master/src/module.coffee#L66)，并且Simditor提供一个类方法`connect`用来安装扩展。

在初始化扩展的时候，Simditor会给Plugin的constructor方法传入自己的引用`@widget`。

`_init`方法和`constructor`的区别是，constructor在Simditor初始化扩展的时候（Simditor自身初始化之前）调用，而`_init`方法会在Simditor自身初始化完成之后调用。所以，在`_init`方法中，@widget的这些属性才是可用的：

* `@widget.textarea`：与Simditor绑定的textarea元素
* `@widtet.el`：Simditor的容器元素`div.simditor`
* `@widget.body`：Simditor的内容元素`div.simditor-body[contenteditable=true]`


###扩展的初始化选项

我们需要给Simditor增加一个autosave选项，用来开关autosave功能并且构造localStorage的key：

```coffee
class SimditorAutosave extends Plugin
  opts:
    autosave: false

  constructor: (@widget) ->
    super @widget
    @editor = @widget

  _init: ->
    @opts.autosave = @opts.autosave || @editor.textarea.data('autosave')
    return unless @opts.autosave
	key = 'simditor-autosave-' + (@opts.autosave || @editor.id)

Simditor.connect SimditorAutosave
```

Plugin的opts属性会与Simditor的opts保持同步，所以我们可以在`_init`方法里通过`@opts.autosave`来获取Simditor初始化时传入的autosave选项。


###添加核心逻辑

准备工作都做好之后，我们就可以添加扩展的核心逻辑了：

```coffee
class SimditorAutosave extends Plugin
  opts:
    autosave: false

  constructor: (@widget) ->
    super @widget
    @editor = @widget

  _init: ->
    @opts.autosave = @opts.autosave || @editor.textarea.data('autosave')
    return unless @opts.autosave
	key = 'simditor-autosave-' + (@opts.autosave || @editor.id)

    @editor.on "valuechanged", =>
      localStorage[key] = @editor.getValue()

    @editor.el.closest('form').on 'submit', (e) ->
      localStorage.removeItem key

    @editor.setValue(localStorage[key]) if localStorage[key]

Simditor.connect SimditorAutosave
```

其中，`valuechanged`是Simditor的自定义事件，每当编辑器的内容发生变化时会被触发，更多关于该事件的信息请参考[事件文档]({{ page.root }}docs/doc-event.html)。

