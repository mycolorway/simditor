---
layout: doc
title: 配置 - Simditor
name: doc-config
root: ../
---

这篇文档主要介绍，Simditor 的配置方法。

###默认配置

Simditor 构造函数创建一个新的编辑器实例。通过传递的 options 参数定制实例。下面的示例使用所有选项及其默认值：

```js
var options = {
  textarea: null,
    placeholder: '',
    defaultImage: 'images/image.png',
    params: {},
    upload: false,
    tabIndent: true,
    toolbar: true,
    toolbarFloat: true,
    pasteImage: false
};
var editor = new Simditor(options);
```

###配置选项

<dl class="doc-properties">
  {% for item in site.data.properties %}
    <dt>
      <span class="icon fa fa-caret-down"></span>
      <span class="name">{{ item.name }}</span>
      <span class="type">{{ item.type }}</span>
      <span class="default">默认值: {{ item.default }}</span>
    </dt>
    <dd class="expand">
      {{ item.description | markdownify }}
    </dd>
  {% endfor %}
</dl>
