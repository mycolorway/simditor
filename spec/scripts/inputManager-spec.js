(function() {
  describe('InputManager', function() {
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
      it('should link editor\'s instance', function() {
        return expect(editor.inputManager.editor).toBe(editor);
      });
      it('should render pasteArea to DOM', function() {
        expect(editor.el.find('div.simditor-paste-area')).toExist();
        return expect(editor.el.find('div.simditor-paste-area')).toHaveAttr('contentEditable');
      });
      return it('should render cleanPasteArea to DOM', function() {
        return expect(editor.el.find('textarea.simditor-clean-paste-area')).toExist();
      });
    });
    describe('onFocus && onBlur method', function() {
      return it('should add/remove focus class when call _onFocus/onBlur method', function() {
        editor.inputManager._onFocus();
        expect(editor.el).toHaveClass('focus');
        editor.inputManager._onBlur();
        return expect(editor.el).not.toHaveClass('focus');
      });
    });
    return describe('addKeystrokeHandler', function() {
      return it('should add key stroke to its instance', function() {
        var tmpCallback, _ref;
        tmpCallback = function() {
          return console.log('this is a test');
        };
        editor.inputManager.addKeystrokeHandler(13, 'ele', tmpCallback);
        return expect((_ref = editor.inputManager._keystrokeHandlers[13]) != null ? _ref['ele'] : void 0).toBe(tmpCallback);
      });
    });
  });

}).call(this);
