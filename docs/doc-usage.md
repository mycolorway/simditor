---
layout: doc
title: How to use - Simditor
id: doc-usage
root: ../
---

#Download

Click [Here](https://github.com/mycolorway/simditor/releases) to download the zip file. You can also install Simditor by bower and npm :

* `$ npm install simditor`
* `$ bower install simditor`


Import files below into your web application

```html
<link rel="stylesheet" type="text/css" href="[style path]/simditor.css" />

<script type="text/javascript" src="[script path]/jquery.min.js"></script>
<script type="text/javascript" src="[script path]/module.js"></script>
<script type="text/javascript" src="[script path]/hotkeys.js"></script>
<script type="text/javascript" src="[script path]/uploader.js"></script>
<script type="text/javascript" src="[script path]/simditor.js"></script>
```
Note that

* Simditor is based on [jQuery](http://jquery.com) and [module.js](https://github.com/mycolorway/simple-module).
* [hotkeys.js](https://github.com/mycolorway/simple-hotkeys) is used to bind hotkeys.
* [uploader.js](https://github.com/mycolorway/simple-uploader) is related to uploading files. You don't need to import this file if you don't want the uploading feature.

#Using Simditor in your project

To use Simditor, first, you need a `textarea` element like this：

```html
<textarea id="editor" placeholder="Balabala" autofocus></textarea>
```

Initialize Simditor：

```js
var editor = new Simditor({
  textarea: $('#editor')
  //optional options
});
```

`textarea` is a required option. jQuery Object、HTML Element or Selector String can be passed to this option.

Some optional options:

* `placeholder` (default: '') Placeholder of simditor. Use the placeholder attribute value of the textarea by default.
* `toolbar` (default: true) -  Show the toolbar buttons
* `toolbarFloat` (default: true) - Fixed the toolbar on the top of the browser when scrolling.
* `toolbarHidden` (default: false) - Hide the toolbar.
* `defaultImage` (default: 'images/image.png') - Default image placeholder. Used when inserting pictures in Simditor.
* `tabIndent` (default: true) - Use 'tab' key to make indent.
* `params` (default: {}) - Insert a hidden input in textarea to store params (key-value pairs).
* `upload` (default: false) - Accept false or key - value pairs. Extra options for uploading images. e.g. 'url', 'params'
* `pasteImage` (default: false) - Support uploading by pasting images from clipboard. Only supported by Firefox and Chrome.

For more details please refer to [Options Doc]({{ page.root }}/docs/doc-config.html).

#Customize Simditor


`simditor.css` is compiled from '.scss' source file using [Sass](http://sass-lang.com/). If you want to change
the style of Simditor, you can simply change `simditor.scss` and reproduce the CSS file.

`.editor-style` is the layout style of the textarea. Customize this file if you want a different text format.

Want some special interactions and features? have a look at [extension library]({{ page.root }}extension.html). You can also create your own extensions for Simditor.
Sample extensions:

* a feature extension: [simditor-autosave](https://github.com/mycolorway/simditor-autosave)
* a button extension: [simditor-mark](https://github.com/mycolorway/simditor-mark)