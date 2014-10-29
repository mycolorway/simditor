(function() {
  describe('Keystroke', function() {
    var editor;
    editor = null;
    beforeEach(function() {
      var tmp;
      $('<textarea id="test"></textarea>').appendTo('body');
      editor = new Simditor({
        textarea: '#test'
      });
      tmp = '<p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>\n<p>相比传统的编辑器它的特点是：</p>\n<ul id="list">\n  <li>功能精简，加载快速</li>\n  <li id="list-item-2">输出格式化的标准<span id="test-span"> HTML </span></li>\n  <li>每一个功能都有非常优秀的使用体验</li>\n</ul>\n<pre id="code">this is a code snippet</pre>\n<p id="para3">兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>\n<blockquote>\n    <p id="blockquote-first-line">First line</p>\n    <p id="blockquote-last-line"><br/></p>\n</blockquote>\n<hr/>\n<p id="after-hr">After hr</p>';
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
    describe('_init method', function() {
      return it('should link editor\'s instance', function() {
        return expect(editor.keystroke.editor).toBe(editor);
      });
    });
    return describe('key stroke', function() {
      var setRange, triggerKeyStroke;
      setRange = function(ele, offsetStart, offsetEnd) {
        var offset, range;
        ele = ele[0];
        range = document.createRange();
        if (!offset) {
          offset = 0;
        }
        range.setStart(ele, offsetStart);
        range.setEnd(ele, offsetEnd);
        editor.focus();
        return editor.selection.selectRange(range);
      };
      triggerKeyStroke = function(key, shift) {
        var e;
        e = $.Event('keydown', {
          keyCode: key,
          which: key,
          shiftKey: shift != null
        });
        return editor.body.trigger(e);
      };
      it('should leave blockquote when press return on last line of blockquote', function() {
        setRange($('#blockquote-first-line'), 0);
        triggerKeyStroke(13);
        expect(editor.body.find('blockquote>#blockquote-first-line')).toExist();
        setRange($('#blockquote-last-line'), 0);
        triggerKeyStroke(13);
        return expect(editor.body.find('blockquote>#blockquote-last-line')).not.toExist();
      });
      it('should delete blockquote when press delete at start of blockquote', function() {
        setRange($('blockquote'), 0);
        triggerKeyStroke(8);
        return expect(editor.body.find('blockquote')).not.toExist();
      });
      it('should remove hr when press delete after hr', function() {
        expect(editor.body.find('hr')).toExist();
        setRange($('#after-hr'), 0);
        triggerKeyStroke(8);
        return expect(editor.body.find('hr')).not.toExist();
      });
      it('should indent content when press tab', function() {
        var e;
        expect(editor.body.find('#para3')).not.toHaveAttr('data-indent');
        setRange($('#para3'), 0, 1);
        e = $.Event('keydown', {
          keyCode: 9,
          which: 9
        });
        triggerKeyStroke(9);
        return expect(editor.body.find('#para3')).toHaveAttr('data-indent');
      });
      it('should insert \\n in pre when press return', function() {
        expect(editor.body.find('#code')).not.toContainText('\\n');
        setRange($('#code').contents(), 1, 4);
        triggerKeyStroke(13);
        return expect(editor.body.find('#code')).toContainText('\n');
      });
      it('should leave pre when press shift + return', function() {
        setRange($('#code').contents(), 1, 4);
        triggerKeyStroke(13, true);
        return expect(editor.selection.getRange().startContainer).not.toHaveClass('#code');
      });
      return it('should delete pre when press delete at start of pre', function() {
        setRange($('#code'), 0, 0);
        triggerKeyStroke(8);
        return expect(editor.body.find('pre')).not.toExist();
      });
    });
  });

}).call(this);
