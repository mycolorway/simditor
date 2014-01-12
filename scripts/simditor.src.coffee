
class Widget

  @extend: (opts) ->
    for key, val of opts
      if key is '_load'
        @::_loadCallbacks.push val
      else if key is '_init'
        @::_initCallbacks.push val
      else if key not in ['_loadCallbacks', '_initCallbacks', 'opts']
        @::[key] = val

  _loadCallbacks: []

  _initCallbacks: []

  opts: {}

  constructor: (opts) ->
    $.extend @opts, opts

    @load(@opts)
    load.call(this) for load in @_loadCallbacks

    @init(@opts)
    init.call(this) for init in @_initCallbacks

  on: (args...) ->
    $(this).on args...

  trigger: (args...) ->
    $(this).trigger args...

  triggerHandler: (args...) ->
    $(this).triggerHandler args...
  


class Simditor extends Widget

  opts:
    textarea: null
    tabIndent: false

  _init: () ->
		@textarea = $(@opts.textarea);
		if (@textarea.length? < 1) {
			throw new Error('mcw.editor: param textarea is required.');
			return;
		}

		var editor = this.textarea.data('mcw-editor');
		if (editor) {
			editor.destroy();
		}

		if (!mcw.editor.count) {
			mcw.editor.count = 0;
		}

		mcw.editor.count ++;
		this.id = mcw.editor.count;
		this.sel = document.getSelection();
		this.textarea.hide().blur();

		this.el = $("<div/>", {
			"class": "mcw-editor",
			"html": '<input type="hidden" name="is_html" value="1" />'
		}).insertAfter(this.textarea)
			.append(this.textarea);
		this.wrapper = $( "<div/>", {
			"class": "editor-wrapper"
		}).appendTo( this.el );
		this.body = $( "<div/>", {
			"class": "editor-body",
			"contenteditable": "true"
		}).appendTo(this.wrapper);

		var that = this,
			form = this.textarea.closest('form');
		if (form.length) {
			form.on('submit.mcw-editor-' + this.id, function() {
				that._syncEditorToTextarea();
			}).on('reset.mcw-editor-' + this.id, function() {
				setTimeout(function() {
					that._syncTextareaToEditor();
				}, 0);
			});
		}

		if (this.textarea.val()) {
			this._syncTextareaToEditor();
			setTimeout($.proxy(function() {
				this.trigger('valuechanged');
			}, this), 0);
		}

		this.el.data({
			"editor": this
		});
		this.textarea.data('mcw-editor', this);

		this.body.attr('tabindex', this.textarea.attr('tabindex'));

		if ($.browser.mozilla) {
			// 防止firefox下面table和img等元素出现用户自己resize的helper
			document.execCommand("enableObjectResizing", false, "false");
			document.execCommand("enableInlineTableEditing", false, "false");
		}
    
