(function() {
  describe('UndoManager', function() {
    var editor;
    editor = null;
    beforeEach(function() {
      $('<textarea id="test"></textarea>').appendTo('body');
      return editor = new Simditor({
        textarea: '#test'
      });
    });
    afterEach(function() {
      if (editor != null) {
        editor.destroy();
      }
      return $('#test').remove();
    });
    describe('_init method', function() {
      return it('should link editor\'s instance', function() {
        console.log(editor.undoManager);
        return expect(editor.undoManager.editor).toBe(editor);
      });
    });
    describe('caret position method', function() {
      it('_getNodeOffset', function() {});
      it('_getNodePosition', function() {});
      it('_getNodeByPosition', function() {});
      return it('caetPosition', function() {});
    });
    return describe('_pushUndoState', function() {
      return it('should push correct state', function() {
        var tpl;
        editor.body.empty();
        tpl = '<p>test</p>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.undoManager._pushUndoState();
        return expect(editor.undoManager._stack[0].html).toBe('<p>test</p>');
      });
    });
  });

}).call(this);
