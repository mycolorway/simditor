---
layout: doc
title: Options - Simditor
id: doc-config
root: ../
---

#Options

You can customize Simditor by passing optional options when initializing Simditor.
Here are some optional options and their default values:

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
  cleanPaste: false
```


<dl class="doc-configs">
  {% for item in site.data.configs %}
    <dt id="anchor-{{ item.name }}">
      <!--<span class="icon simditor-icon simditor-icon-caret-down"></span>-->
      <a href="#anchor-{{ item.name }}" class="name">{{ item.name }}</a>
      <span class="type">{{ item.type }}</span>
      <span class="default">default: {{ item.default }}</span>
    </dt>
    <dd class="expand">
      {{ item.description | markdownify }}
    </dd>
  {% endfor %}
</dl>
