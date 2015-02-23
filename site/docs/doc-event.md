---
layout: doc
title: 事件 - Simditor
id: doc-event
root: ../
---

Simditor 会在特定情况下触发下列事件，你可以为编辑器实例绑定这些事件来做相应的操作：

```coffee
# 初始化 Simditor
editor = new Simditor
  textarea: $('#editor')

# 绑定 valuechanged 方法
editor.on 'valuechanged', (e, src) ->
  alert('simditor valuechanged')
```

###事件

<dl class="doc-events">
  {% for item in site.data.events %}
    <dt id="anchor-{{ item.name }}">
      <!--<span class="icon simditor-icon simditor-icon-caret-down"></span>-->
      <span class="name">{{ item.name }}</span>
      <span class="params">
        {% for param in item.params %}
          <span class="param">
            <span class="param-name">{{ param.name }}</span>
            <span class="param-type">{{ param.type }}</span>
          </span>
        {% endfor %}
      </span>
    </dt>
    <dd class="expand">
      {{ item.description | markdownify }}
    </dd>
  {% endfor %}
</dl>
