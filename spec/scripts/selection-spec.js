(function() {
  describe('Simditor Selection Module', function() {
    var compareRange, editor, setRange;
    editor = null;
    beforeEach(function() {
      var tmp;
      $('<textarea id="test"></textarea>').appendTo('body');
      editor = new Simditor({
        textarea: '#test'
      });
      tmp = '<p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>\n  <p>相比传统的编辑器它的特点是：</p>\n    <ul id="list">\n      <li id="list-item-1">功能精简，<span id="test-span">加载快速</span></li>\n      <li id="list-item-2">输出格式化的标准 HTML</li>\n      <li id="list-item-3">每一个功能都有非常优秀的使用体验</li>\n    </ul>\n    <pre id="code">"this is a code snippet"</pre>\n  <p data-indent="2" id="para">兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>';
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
    compareRange = function(range1, range2) {
      if (!((range1.endContainer != null) || (range2.endContainer != null))) {
        return false;
      }
      if (!(range1.endContainer === range2.endContainer || range1.endOffset === range2.endOffset || range1.startContainer === range2.startContainer || range1.startOffset === rang2.startOffset)) {
        return false;
      }
      return true;
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
    it('can set range and get range', function() {
      var range, tmp;
      tmp = $('<p id="test1">this is <b id="test2">test</b> text</p>').appendTo('.simditor-body');
      range = document.createRange();
      range.setStart($('#test1')[0], 0);
      range.setEnd($('#test2')[0], 0);
      editor.focus();
      editor.selection.selectRange(range);
      expect(compareRange(editor.selection.getRange(), range)).toBe(true);
      editor.selection.clear();
      return expect(editor.selection.getRange()).toBe(null);
    });
    it('can set range end after a node', function() {
      setRange($('#test-span'), 0, $('#list-item-2').contents(), 4);
      editor.selection.setRangeAfter($('#list-item-3'));
      return expect(editor.selection.getRange().startOffset).toBe(6);
    });
    it('can set range start before a node', function() {
      setRange($('#test-span'), 0, $('#list-item-2').contents(), 4);
      editor.selection.setRangeBefore($('#list-item-1'));
      return expect(editor.selection.getRange().startOffset).toBe(1);
    });
    it('can set range at start of a nope', function() {
      setRange($('#test-span'), 0, $('#list-item-2').contents(), 4);
      editor.selection.setRangeAtStartOf($('#list-item-1'));
      return expect(editor.selection.getRange().endContainer).toBe($('#list-item-1')[0]);
    });
    it('can set range at end of a node', function() {
      setRange($('#test-span'), 0, $('#list-item-2').contents(), 4);
      editor.selection.setRangeAtEndOf($('#list-item-2'));
      return expect(editor.selection.getRange().endContainer).toBe($('#list-item-2')[0]);
    });
    return it('can judge range whether it\'s at start|end of a node', function() {
      var range;
      range = document.createRange();
      range.setStart($('#test-span')[0], 0);
      return expect(editor.selection.rangeAtStartOf($('#test-span')[0], range)).toBeTruthy();
    });
  });

}).call(this);
