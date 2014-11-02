(function() {
  describe('Simditor UndoManager Module', function() {
    var compareArray, editor, prepareState, setRange;
    editor = null;
    beforeEach(function() {
      var tmp;
      $('<textarea id="test"></textarea>').appendTo('body');
      editor = new Simditor({
        textarea: '#test'
      });
      tmp = '<p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>\n<p>相比传统的编辑器它的特点是：</p>\n<ul id="list">\n  <li>功能精简，加载快速</li>\n  <li id="list-item-2">输出格式化的标准<span id="test-span"> HTML </span></li>\n  <li id="list-item-3">每一个功能都有非常优秀的使用体验</li>\n</ul>';
      tmp = $(tmp);
      tmp.appendTo('.simditor-body');
      return editor.sync();
    });
    afterEach(function() {
      if (editor != null) {
        editor.destroy();
      }
      return $('#test').remove();
    });
    compareArray = function(arr1, arr2) {
      return arr1.toString() === arr2.toString();
    };
    setRange = function(ele1, offset1, ele2, offset2) {
      var offset, range;
      ele1 = ele1[0];
      ele2 = ele2[0];
      range = document.createRange();
      if (!offset) {
        offset = 0;
      }
      range.setStart(ele1, offset1);
      range.setEnd(ele2, offset2);
      editor.focus();
      return editor.selection.selectRange(range);
    };
    it('can get current position', function() {
      var caret;
      setRange($('#test-span'), 0, $('#list-item-3').contents(), 4);
      caret = editor.undoManager.caretPosition();
      expect(compareArray(caret.start, [5, 3, 1, 0])).toBeTruthy();
      expect(compareArray(caret.end, [5, 5, 0, 4])).toBeTruthy();
      return expect(caret.collapsed).not.toBeTruthy();
    });
    it('can apply position by giving caret', function() {
      var caret, exception, range, _ref, _ref1;
      caret = {
        start: [5, 3, 1, 0],
        collapsed: true
      };
      editor.undoManager.caretPosition(caret);
      range = (_ref = document.getSelection()) != null ? _ref.getRangeAt(0) : void 0;
      expect(range.startContainer).toBe($('#test-span')[0]);
      expect(range.startOffset).toBe(0);
      expect(range.collapsed).toBeTruthy();
      caret = {
        start: [5, 3, 1, 0],
        end: [5, 5, 0, 4],
        collapsed: false
      };
      editor.undoManager.caretPosition(caret);
      range = (_ref1 = document.getSelection()) != null ? _ref1.getRangeAt(0) : void 0;
      expect(range.startContainer).toBe($('#test-span')[0]);
      expect(range.startOffset).toBe(0);
      expect(range.endContainer).toBe($('#list-item-3').contents()[0]);
      expect(range.endOffset).toBe(4);
      caret = {
        start: [99, 99, 99, 99],
        collapsed: true
      };
      exception = function() {
        return editor.undoManager.caretPosition(caret);
      };
      return expect(exception).toThrowError();
    });
    it('should get correct offset when call _getNodeOffset method', function() {
      expect(editor.undoManager._getNodeOffset($('#list-item-2')[0])).toBe(3);
      return expect(editor.undoManager._getNodeOffset($('#list')[0])).toBe(5);
    });
    it('should get correct postion array when call _getNodePosition method', function() {
      var position;
      position = editor.undoManager._getNodePosition($('#test-span')[0], 0);
      expect(compareArray(position, [5, 3, 1, 0])).toBeTruthy();
      position = editor.undoManager._getNodePosition($('#test-span')[0], 1);
      return expect(compareArray(position, [5, 3, 1, 1])).toBeTruthy();
    });
    it('should return correct element when call _getNodeByPosition method', function() {
      expect(editor.undoManager._getNodeByPosition([5, 3, 1, 0])).toBe($('#test-span')[0]);
      return expect(editor.undoManager._getNodeByPosition([5, 3, 1, 1])).toBe($('#test-span')[0]);
    });
    it('should push correct state', function() {
      var tpl;
      editor.body.empty();
      tpl = '<p>test</p>';
      $(tpl).appendTo('.simditor-body');
      editor.undoManager._pushUndoState();
      expect(editor.undoManager._stack[0].html).toBe('<p>test</p>');
      $(tpl).appendTo('.simditor-body');
      editor.undoManager._pushUndoState();
      return expect(editor.undoManager._stack[1].html).toBe('<p>test</p><p>test</p>');
    });
    prepareState = function() {
      editor.body.empty();
      editor.setValue('<p>test1</p>');
      editor.undoManager._pushUndoState();
      editor.setValue('<p>test1test2</p>');
      return editor.undoManager._pushUndoState();
    };
    it('can return to last state when call undo method', function() {
      var spyEvent;
      prepareState();
      expect(editor.getValue()).toBe('<p>test1test2</p>');
      expect(editor.undoManager._index).toBe(1);
      spyEvent = spyOnEvent(editor, 'valuechanged');
      editor.undoManager.undo();
      expect(editor.getValue()).toBe('<p>test1</p>');
      expect(editor.undoManager._index).toBe(0);
      expect(spyEvent).toHaveBeenTriggered();
      spyEvent.reset();
      editor.undoManager.undo();
      return expect(spyEvent).not.toHaveBeenTriggered();
    });
    return it('should back to former state when call redo method', function() {
      var spyEvent;
      prepareState();
      editor.undoManager.undo();
      expect(editor.getValue()).toBe('<p>test1</p>');
      spyEvent = spyOnEvent(editor, 'valuechanged');
      editor.undoManager.redo();
      expect(editor.getValue()).toBe('<p>test1test2</p>');
      expect(editor.undoManager._index).toBe(1);
      expect(spyEvent).toHaveBeenTriggered();
      spyEvent.reset();
      editor.undoManager.redo();
      return expect(spyEvent).not.toHaveBeenTriggered();
    });
  });

}).call(this);
