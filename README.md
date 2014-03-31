### What is Simditor

**LIVE DEMO:** [http://mycolorway.github.io/simditor/demo.html](http://mycolorway.github.io/simditor/demo.html) 

Simditor is a simple WYSIWYG editor which aims at providing top writing experience on web page.

Instead of extending it to be over-powerful, we choose to keep it simple and tight while improving every single feature for the best user expeirence. It is also extreamly easy to be extended, if sometimes it couldn't cover your needs.

### How to Use

Reference these files in your html page:

```
<link media="all" rel="stylesheet" type="text/css" href="styles/font-awesome.css" />
<link media="all" rel="stylesheet" type="text/css" href="styles/simditor.css" />

<script type="text/javascript" src="scripts/jquery-2.0.3.js"></script>
<script type="text/javascript" src="scripts/module.js"></script>
<script type="text/javascript" src="scripts/uploader.js"></script>
<script type="text/javascript" src="scripts/simditor.js"></script>
```

Then initialize the editor in your script:

```
var editor = new Simditor({
  textarea: $('#textarea-id')
});
```

### Dependence

Simditor is built on jQuery 2.0+ and [Mycolorway Simple Module](https://github.com/mycolorway/simple-module) which is a CoffeeScript base class for component development.

[FontAwesome](https://github.com/FortAwesome/Font-Awesome) is also required if you don't want to customize your own toolbar button.

[Mycolorway Simple Uploader](https://github.com/mycolorway/simple-uploader) is optional for local image uploading.

### Support or Contact

Any thoughts or uncomfortable experience, be free to contact me: [farthinker@gmail.com](mailto:farthinker@gmail.com).

### License

Licensed under MIT.

