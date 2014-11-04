(function() {
  describe('Simditor Util Module', function() {
    var editor;
    editor = null;
    beforeEach(function() {
      var tmp;
      $('<textarea id="test"></textarea>').appendTo('body');
      editor = new Simditor({
        textarea: '#test'
      });
      tmp = '<p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>\n  <p>相比传统的编辑器它的特点是：</p>\n    <ul id="list">\n      <li id="list-item-1">功能精简，加载快速</li>\n      <li id="list-item-2">输出格式化的标准 HTML</li>\n      <li>每一个功能都有非常优秀的使用体验</li>\n    </ul>\n    <pre id="code">"this is a code snippet"</pre>\n  <p data-indent="2" id="para">兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>\n  <table>\n    <tr>\n      <td id="td-1">test1</td>\n      <td id="td-2">test2</td>\n    </tr>\n  </table>';
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
    it('can find the closet|furthest Block element', function() {
      expect(editor.util.closestBlockEl($('#list-item-1'))[0]).toBe($('#list-item-1')[0]);
      return expect(editor.util.furthestBlockEl($('#list-item-1'))[0]).toBe($('#list')[0]);
    });
    it('can get node\'s length', function() {
      var $n1, n2;
      $n1 = $('<div><p></p><br/><hr/></div>');
      n2 = document.createTextNode('text node');
      expect(editor.util.getNodeLength($n1[0])).toBe(3);
      return expect(editor.util.getNodeLength(n2)).toBe(9);
    });
    it('can intent and outdent content', function() {
      var setRange, text;
      setRange = function(ele) {
        var range;
        ele = ele[0];
        range = document.createRange();
        range.setStart(ele, 0);
        range.setEnd(ele, 1);
        editor.focus();
        return editor.selection.selectRange(range);
      };
      setRange($('pre'));
      text = $('#code').text();
      editor.util.indent();
      expect($('#code').text()).toBe('\u00A0\u00A0' + text);
      editor.util.outdent();
      expect($('#code').text()).toBe(text);
      setRange($('#list-item-1'));
      editor.util.indent();
      expect($('#list-item-1').parent().attr('id')).toBe('list');
      setRange($('#list-item-2'));
      editor.util.indent();
      expect($('#list-item-2').parent().parent().attr('id')).toBe('list-item-1');
      setRange($('#list-item-2'));
      editor.util.outdent();
      expect($('#list-item-2').parent().attr('id')).toBe('list');
      setRange($('#para'));
      editor.util.indent();
      expect($('#para').attr('data-indent')).toBe('3');
      setRange($('#para'));
      editor.util.outdent();
      expect($('#para').attr('data-indent')).toBe('2');
      setRange($('#td-1'));
      editor.util.indent();
      expect(editor.selection.getRange().startContainer).toBe($('#td-2')[0]);
      expect(editor.selection.getRange().collapsed).toBe(true);
      setRange($('#td-2'));
      editor.util.outdent();
      expect(editor.selection.getRange().startContainer).toBe($('#td-1')[0]);
      return expect(editor.selection.getRange().collapsed).toBe(true);
    });
    return it('can push event\'s function key to shortcut string', function() {
      var e;
      e = {
        shiftKey: true,
        ctrlKey: true,
        altKey: true,
        metaKey: true,
        which: 1
      };
      return expect(editor.util.getShortcutKey(e)).toBe('shift+ctrl+alt+cmd+1');
    });
  });

}).call(this);
