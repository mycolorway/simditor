---
layout: doc
title: 方法 - Simditor
name: doc-method
root: ../
---

这篇文档用来介绍 Simditor 的主要方法，调用方式如下：

```js
// 初始化 Simditor
var editor = new Simditor({
  textarea: $('#editor')
});

// 调用 setValue 方法设置内容
editor.setValue('hello world');
```

<dl class="doc-methods">
  {% for item in site.data.methods %}
    <dt>
      <span class="icon fa fa-caret-down"></span>
      <span class="name">{{ item.name }}</span>
      <span class="params">
        {% for param in item.params %}
          <span class="param">{{ param.name }}: {{ param.type }}</span>
        {% endfor %}
      </span>
      {% if item.return.size > 0 %}
      <span class="return">返回值: {{ item.return.type }}</span>
      {% endif %}
    </dt>
    <dd class="expand">
      {{ item.description | markdownify }}
    </dd>
  {% endfor %}
</dl>
