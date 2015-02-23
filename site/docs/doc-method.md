---
layout: doc
title: 方法 - Simditor
id: doc-method
root: ../
---

Simditor 初始化之后，编辑器实例会暴露一些公共方法供调用：

```coffee
# 初始化 Simditor
editor = new Simditor
  textarea: $('#editor')

# 调用 setValue 方法设置内容
editor.setValue 'hello world'
```

###公共方法

<dl class="doc-methods">
  {% for item in site.data.methods %}
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
      {% if item.return.size > 0 %}
      <span class="return">返回值: {{ item.return.type }}</span>
      {% endif %}
    </dt>
    <dd class="expand">
      {{ item.description | markdownify }}
    </dd>
  {% endfor %}
</dl>
