(function() {
  describe('Simditor InputManager Module', function() {
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
    it('should render specific layout', function() {
      expect(editor.el.find('.simditor-paste-area')).toExist();
      return expect(editor.el.find('.simditor-clean-paste-area')).toExist();
    });
    it('can add key stroke to its instance', function() {
      var tmpCallback, _ref;
      tmpCallback = function() {
        return console.log('this is a test');
      };
      editor.inputManager.addKeystrokeHandler(13, 'ele', tmpCallback);
      return expect((_ref = editor.inputManager._keystrokeHandlers[13]) != null ? _ref['ele'] : void 0).toBe(tmpCallback);
    });
    it('should add focus class when editor focus', function() {
      var spyEvent;
      spyEvent = spyOnEvent(editor, 'selectionchanged');
      editor.focus();
      expect(editor.el).toHaveClass('focus');
      return expect(editor.inputManager.focused).toBeTruthy();
    });
    it('should remove focus class when editor blur', function() {
      editor.focus();
      editor.blur();
      expect(editor.el).not.toHaveClass('focus');
      return expect(editor.inputManager.focused).not.toBeTruthy();
    });
    it('should call shortcut when keydown', function() {
      var KeyStrokeCalled, boldBtn, spyEvent, triggerKey;
      triggerKey = function(key, ctrl, shift) {
        var e;
        e = $.Event('keydown', {
          keyCode: key,
          which: key,
          shiftKey: shift != null
        });
        if (editor.util.os.mac) {
          e.metaKey = ctrl != null;
        } else {
          e.ctrlKey = ctrl != null;
        }
        return editor.body.trigger(e);
      };
      editor.focus();
      boldBtn = editor.el.find('a.toolbar-item-bold');
      spyEvent = spyOnEvent(boldBtn, 'mousedown');
      triggerKey(66, true);
      expect(spyEvent).toHaveBeenTriggered();
      KeyStrokeCalled = false;
      editor.inputManager.addKeystrokeHandler('15', '*', (function(_this) {
        return function(e, $node) {
          return KeyStrokeCalled = true;
        };
      })(this));
      triggerKey(15);
      return expect(KeyStrokeCalled).toBeTruthy();
    });
    return it('should ensure editor\' body has content when keyup', function() {
      var e;
      editor.body.empty();
      editor.focus();
      e = $.Event('keyup', {
        which: 8,
        keyCode: 8
      });
      editor.body.trigger(e);
      return expect(editor.body.find('p>br')).toExist();
    });
  });

}).call(this);
