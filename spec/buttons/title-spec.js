(function() {
  describe('Simditor title button', function() {
    var $p, editor;
    editor = null;
    $p = null;
    beforeEach(function() {
      editor = spec.generateSimditor({
        content: '<p>paragraph 1</>',
        toolbar: ['title']
      });
      editor.focus();
      $p = editor.body.find('> p');
      editor.selection.setRangeAtStartOf($p);
      editor.inputManager.focused = true;
      return editor.trigger('selectionchanged');
    });
    afterEach(function() {
      spec.destroySimditor();
      return editor = null;
    });
    it("can convert paragraph to h1", function() {
      var $firstBlock, button;
      $firstBlock = editor.body.children().first();
      expect($firstBlock.is('p')).toBe(true);
      expect($firstBlock.is('h1')).toBe(false);
      button = editor.toolbar.list.find('.toolbar-item-title').data('button');
      button.menuEl.find('.menu-item-h1').click();
      $firstBlock = editor.body.children().first();
      expect($firstBlock.is('p')).toBe(false);
      expect($firstBlock.is('h1')).toBe(true);
      button.menuEl.find('.menu-item-normal').click();
      $firstBlock = editor.body.children().first();
      expect($firstBlock.is('p')).toBe(true);
      return expect($firstBlock.is('h1')).toBe(false);
    });
    return it("can convert paragraph to h5", function() {
      var $firstBlock, button;
      $firstBlock = editor.body.children().first();
      expect($firstBlock.is('p')).toBe(true);
      expect($firstBlock.is('h5')).toBe(false);
      button = editor.toolbar.list.find('.toolbar-item-title').data('button');
      button.menuEl.find('.menu-item-h5').click();
      $firstBlock = editor.body.children().first();
      expect($firstBlock.is('p')).toBe(false);
      expect($firstBlock.is('h5')).toBe(true);
      button.menuEl.find('.menu-item-normal').click();
      $firstBlock = editor.body.children().first();
      expect($firstBlock.is('p')).toBe(true);
      return expect($firstBlock.is('h5')).toBe(false);
    });
  });

}).call(this);
