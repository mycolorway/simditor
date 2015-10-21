(function() {
  describe('Simditor fontScale button', function() {
    var editor;
    editor = null;
    beforeEach(function() {
      return editor = spec.generateSimditor({
        content: '<p>hello font scale</p>',
        toolbar: ['fontScale']
      });
    });
    afterEach(function() {
      spec.destroySimditor();
      return editor = null;
    });
    it('should set selection bold after clicking', function() {
      var $button, $p, $span, $text, button, range;
      editor.focus();
      $button = editor.toolbar.list.find('.toolbar-item-fontScale');
      expect($button.length).toBe(1);
      $p = editor.body.find('p:first');
      $text = $p.contents().first();
      range = document.createRange();
      range.setStart($text[0], 0);
      range.setEnd($text[0], 10);
      editor.selection.range(range);
      button = $button.data('button');
      button.menuEl.find('.menu-item:first').click();
      $span = $p.find('span[style*="font-size"]');
      expect($span.length).toBe(1);
      return expect($span.text()).toBe('hello font');
    });
    return it('should be active when selection inside font size tag', function() {
      var $button, $span, button, range;
      editor.setValue('<p><span style="font-size: 1.5em;">hello font</span> scale</p>');
      editor.focus();
      $span = editor.body.find('span[style*="font-size"]');
      range = document.createRange();
      range.setStart($span[0], 1);
      range.setEnd($span[0], 1);
      editor.selection.range(range);
      editor.trigger('selectionchanged');
      $button = editor.toolbar.list.find('.toolbar-item-fontScale');
      button = $button.data('button');
      return expect(button.active).toBe(true);
    });
  });

}).call(this);
