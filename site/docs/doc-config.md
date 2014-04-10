---
layout: doc
title: 配置 - Simditor
name: doc-config
root: ../
---

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
