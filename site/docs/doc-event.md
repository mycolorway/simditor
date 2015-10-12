---
layout: doc
title: Events - Simditor
id: doc-event
root: ../
---

Simditor will trigger different events, you can bind these events if needed：

```coffee
# init Simditor
editor = new Simditor
  textarea: $('#editor')

# bind valuechanged event
editor.on 'valuechanged', (e, src) ->
  alert('simditor valuechanged')
```

###Events

<dl class="doc-events">
  {% for item in site.data.events %}
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
    </dt>
    <dd class="expand">
      {{ item.description | markdownify }}
    </dd>
  {% endfor %}
</dl>
