---
layout: doc
title: 配置 - Simditor
id: doc-config
root: ../
---

###默认配置

Simditor 构造函数创建一个新的编辑器实例。通过传递的 options 参数定制实例。下面的示例使用所有选项及其默认值：

```coffee
editor = new Simditor
  textarea: null
  placeholder: ''
  defaultImage: 'images/image.png'
  params: {}
  upload: false
  tabIndent: true
  toolbar: true
  toolbarFloat: true
  toolbarFloatOffset: 0
  toolbarHidden: false
  pasteImage: false
```

###配置选项

<dl class="doc-configs">
  {% for item in site.data.configs %}
    <dt id="anchor-{{ item.name }}">
      <!--<span class="icon simditor-icon simditor-icon-caret-down"></span>-->
      <span class="name">{{ item.name }}</span>
      <span class="type">{{ item.type }}</span>
      <span class="default">默认值: {{ item.default }}</span>
    </dt>
    <dd class="expand">
      {{ item.description | markdownify }}
    </dd>
  {% endfor %}
</dl>
