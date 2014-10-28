(function() {
  describe('Selection', function() {
    var compareRange, editor;
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
    compareRange = function(range1, range2) {
      if (!((range1.endContainer != null) || (range2.endContainer != null))) {
        return false;
      }
      if (!(range1.endContainer === range2.endContainer || range1.endOffset === range2.endOffset || range1.startContainer === range2.startContainer || range1.startOffset === rang2.startOffset)) {
        return false;
      }
      return true;
    };
    describe('_init method', function() {
      return it('should link editor instance and get document\s selection', function() {
        expect(editor.selection.editor).toBe(editor);
        return expect(editor.selection.sel).toBe(document.getSelection());
      });
    });
    describe('selectRange && getRange', function() {
      return it('', function() {
        var range, tmp;
        tmp = $('<p id="test1">this is <b id="test2">test</b> text</p>').appendTo('.simditor-body');
        range = document.createRange();
        range.setStart($('#test1')[0], 0);
        range.setEnd($('#test2')[0], 0);
        editor.focus();
        editor.selection.selectRange(range);
        expect(editor.selection.getRange().toString() === range.toString()).toBe(true);
        editor.selection.clear();
        return expect(editor.selection.getRange()).toBe(null);
      });
    });
    describe('operate range method', function() {
      beforeEach(function() {
        var range, tmp;
        tmp = $('<p id="test1">this <b id="test2">is</b> <b id="test3">test</b>text</p>').appendTo('.simditor-body');
        editor.sync();
        range = document.createRange();
        range.setStart($('#test1')[0], 0);
        range.setEnd($('#test2')[0], 0);
        editor.focus();
        return editor.selection.selectRange(range);
      });
      it('should set correct range when call setRangeAfter method', function() {
        editor.selection.setRangeAfter($('#test3'));
        return expect(editor.selection.getRange().startOffset).toBe(4);
      });
      it('should set correct range when call  setRangeBefore method', function() {
        editor.selection.setRangeBefore($('#test3'));
        return expect(editor.selection.getRange().startOffset).toBe(3);
      });
      it('should set correct range when call  setRangeAtStartOf method', function() {
        editor.selection.setRangeAtStartOf($('#test3'));
        return expect(editor.selection.getRange().endContainer).toBe($('#test3')[0]);
      });
      return it('should set correct range when call  setRangeAtEndOf ,method', function() {
        editor.selection.setRangeAtEndOf($('#test3'));
        return expect(editor.selection.getRange().endContainer).toBe($('#test3')[0]);
      });
    });
    return describe('save and restore', function() {});
  });

}).call(this);
