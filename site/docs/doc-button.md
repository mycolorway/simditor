---
layout: doc
title: Button - Simditor
id: doc-button
root: ../
---

Simditor 的按钮都继承自 [Button 类](https://github.com/mycolorway/simditor/blob/master/src/buttons/button.coffee)，并且需要通过 `Simditor.Toolbar.addButton(Button)` 方法来注册，例如：

```coffee
class TitleButton extends Simditor.Button
  name: 'title'
  title: '标题文字'
  ...

  setActive: (active) ->
    ...

  setDisabled: (disabled) ->
    ...

  status: ($node) ->
    ...

  command: (param) ->
    # 在 Button 类中这是一个抽象方法，需要各个按钮单独实现
  	# 执行格式化的操作

Simditor.Toolbar.addButton(TitleButton)
```

###属性

<dl class="doc-button-properties">
  {% for item in site.data.button.properties %}
    <dt id="anchor-{{ item.name }}">
      <!--<span class="icon simditor-icon simditor-icon-caret-down"></span>-->
      <span class="name">{{ item.name }}</span>
      <span class="type">{{ item.type }}</span>
      <span class="default">默认值: {{ item.default}}</span>
    </dt>
    <dd class="expand">
      {{ item.description | markdownify }}
    </dd>
  {% endfor %}
</dl>

###方法

<dl class="doc-button-methods">
  {% for item in site.data.button.methods %}
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
