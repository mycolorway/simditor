---
layout: doc
title: Methods - Simditor
id: doc-method
root: ../
---

Keep a reference of Simditor instance and call the methods：

```coffee
# init Simditor
editor = new Simditor
  textarea: $('#editor')

# call setValue to set content
editor.setValue 'hello world'
```

#Public Methods

<dl class="doc-methods">
  {% for item in site.data.methods %}
    <dt id="anchor-{{ item.name }}">
      <!--<span class="icon simditor-icon simditor-icon-caret-down"></span>-->
      <a href="#anchor-{{ item.name }}" class="name">{{ item.name }}</a>
      <span class="params">
        {% for param in item.params %}
          <span class="param">
            <span class="param-name">{{ param.name }}</span>
            <span class="param-type">{{ param.type }}</span>
          </span>
        {% endfor %}
      </span>
      {% if item.return.size > 0 %}
      <span class="return">return value: {{ item.return.type }}</span>
      {% endif %}
    </dt>
    <dd class="expand">
      {{ item.description | markdownify }}
    </dd>
  {% endfor %}
</dl>
