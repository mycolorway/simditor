(function() {
  describe('Simditor bold button', function() {
    var editor;
    editor = null;
    beforeEach(function() {
      return editor = spec.generateSimditor({
        content: '<p>bold text</p>',
        toolbar: ['bold']
      });
    });
    afterEach(function() {
      spec.destroySimditor();
      return editor = null;
    });
    it('should set selection bold after clicking', function() {
      var $b, $button, $p, $text, range;
      editor.focus();
      $button = editor.toolbar.list.find('.toolbar-item-bold');
      expect($button.length).toBe(1);
      $p = editor.body.find('p:first');
      $text = $p.contents().first();
      range = document.createRange();
      range.setStart($text[0], 0);
      range.setEnd($text[0], 4);
      editor.selection.range(range);
      $button.mousedown();
      $b = $p.find('b');
      expect($b.length).toBe(1);
      return expect($b.text()).toBe('bold');
    });
    return it('should be active when selection inside b tag', function() {
      var $b, $button, button, range;
      editor.setValue('<p><b>bold</b> text</p>');
      editor.focus();
      $b = editor.body.find('b');
      range = document.createRange();
      range.setStart($b[0], 1);
      range.setEnd($b[0], 1);
      editor.selection.range(range);
      editor.trigger('selectionchanged');
      $button = editor.toolbar.list.find('.toolbar-item-bold');
      button = $button.data('button');
      return expect(button.active).toBe(true);
    });
  });

}).call(this);
