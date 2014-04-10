---
layout: doc
title: 事件 - Simditor
name: doc-event
root: ../
---

<dl class="doc-events">
  {% for item in site.data.events %}
    <dt>
      <span class="icon fa fa-caret-down"></span>
      <span class="name">{{ item.name }}</span>
      <span class="params">
        {% for param in item.params %}
          <span class="param">{{ param.name }}: {{ param.type }}</span>
        {% endfor %}
      </span>
    </dt>
    <dd class="expand">
      {{ item.description | markdownify }}
    </dd>
  {% endfor %}
</dl>
