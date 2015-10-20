(function() {
  describe('Simditor code button', function() {
    var editor;
    editor = null;
    beforeEach(function() {
      return editor = spec.generateSimditor({
        content: '<p>var test = 1;</p>',
        toolbar: ['code']
      });
    });
    afterEach(function() {
      spec.destroySimditor();
      return editor = null;
    });
    return it('should create code block after clicking', function() {
      var $button, $p, button, range;
      editor.focus();
      $button = editor.toolbar.list.find('.toolbar-item-code');
      button = $button.data('button');
      expect($button.length).toBe(1);
      $p = editor.body.find('p:first');
      range = document.createRange();
      range.setStart($p[0], 0);
      range.setEnd($p[0], 0);
      editor.selection.range(range);
      editor.inputManager.focused = true;
      button.command();
      editor.trigger('selectionchanged');
      expect(editor.getValue()).toBe('<pre><code>var test = 1;</code></pre>');
      editor.el.find('.code-popover .select-lang').val('js').change();
      return expect(editor.getValue()).toBe('<pre><code class="lang-js">var test = 1;</code></pre>');
    });
  });

}).call(this);
