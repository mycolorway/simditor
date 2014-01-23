### What is Simditor
Simditor is a simple WYSIWYG editor which aims at providing top writing experience on web page.

Instead of extending it to be over-powerful, we choose to keep it simple and tight while improving every single feature for the best user expeirence. It is also extreamly easy to be extended, if sometimes it couldn't cover your needs.

Check [here](http://mycolorway.github.io/simditor/demo.html) for a live demo.


### How to Use

Reference these files in your html page:

```
<link media="all" rel="stylesheet" type="text/css" href="styles/font-awesome.css" />
<link media="all" rel="stylesheet" type="text/css" href="styles/simditor.css" />

<script type="text/javascript" src="scripts/jquery-2.0.3.js"></script>
<script type="text/javascript" src="scripts/simditor.js"></script>
```

Notice: `font-awesome.css` is optional which is used to provide icon image for our toolbar button. You can customize the style of editor as you like by modifying `simditor.css` or writing your own to override it. jQuery 2.0+ is required.

Then initialize the editor in your script:

```
var editor = new Simditor({
  textarea: $('#textarea-id')
});
```

### Documentation
Not ready yet...

### Support or Contact
Any thoughts or uncomfortable experience, be free to contact me: farthinker@gmail.com.


