(function() {
  describe('Simditor table button', function() {
    var editor;
    editor = null;
    beforeEach(function() {
      jasmine.clock().install();
      return editor = spec.generateSimditor({
        toolbar: ['table']
      });
    });
    afterEach(function() {
      jasmine.clock().uninstall();
      spec.destroySimditor();
      return editor = null;
    });
    return it('should create a new table after clicking and selecting size', function() {
      var $button, $table;
      editor.focus();
      $button = editor.toolbar.list.find('.toolbar-item-table');
      expect($button.length).toBe(1);
      expect(editor.body.find('table').length).toBe(0);
      editor.inputManager.focused = true;
      editor.trigger('selectionchanged');
      $button.mousedown();
      $('.menu-create-table td').eq(2).mousedown();
      $table = editor.body.find('table');
      expect($table.length).toBe(1);
      expect($table.find('tr').length).toBe(2);
      return expect($table.find('th, td').length).toBe(6);
    });
  });

}).call(this);
