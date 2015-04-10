(function() {
  describe('A Simditor instance with buttons', function() {
    var editor;
    editor = null;
    beforeEach(function() {
      jasmine.clock().install();
      return editor = spec.generateSimditor();
    });
    afterEach(function() {
      jasmine.clock().uninstall();
      spec.destroySimditor();
      return editor = null;
    });
    return it('should set selection bold after clicking bold button', function() {
      var $button, $p, $text, range;
      editor.focus();
      jasmine.clock().tick(100);
      $p = editor.body.find('p:first');
      $button = editor.toolbar.list.find('.toolbar-item-bold');
      expect($button).toExist();
      $text = $p.contents().first();
      range = document.createRange();
      range.setStart($text[0], 0);
      range.setEnd($text[0], 8);
      editor.selection.selectRange(range);
      $button.mousedown();
      return expect($p.find('b')).toExist();
    });
  });

}).call(this);
