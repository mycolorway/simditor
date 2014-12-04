(function() {
  describe('A Simditor instance', function() {
    var $textarea, editor, triggerKeyStroke;
    editor = null;
    $textarea = null;
    beforeEach(function() {
      var content;
      jasmine.clock().install();
      content = '<p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>\n<p>相比传统的编辑器它的特点是：</p>\n<ul>\n  <li>功能精简，加载快速</li>\n  <li>输出格式化的标准 HTML</li>\n  <li>每一个功能都有非常优秀的使用体验</li>\n</ul>\n<p>兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>\n<pre>this is a code snippet</pre>\n<blockquote><p>First line</p><p><br/></p></blockquote>\n<hr/>\n<p><br/></p>';
      $textarea = $('<textarea id="editor"></textarea>').val(content).appendTo('body');
      return editor = new Simditor({
        textarea: $textarea
      });
    });
    afterEach(function() {
      jasmine.clock().uninstall();
      editor.destroy();
      editor = null;
      $textarea.remove();
      return $textarea = null;
    });
    triggerKeyStroke = function(key, opts) {
      var e;
      if (opts == null) {
        opts = {};
      }
      e = $.Event('keydown', $.extend({
        which: key
      }, opts));
      return editor.body.trigger(e);
    };
    it('should leave blockquote when press return on last line of blockquote', function() {
      editor.focus();
      editor.selection.setRangeAtStartOf(editor.body.find('blockquote > p:last'));
      expect(editor.body.find('blockquote > p').length).toBe(2);
      triggerKeyStroke(13);
      return expect(editor.body.find('blockquote > p').length).toBe(1);
    });
    it('should delete blockquote when press delete at start of blockquote', function() {
      editor.focus();
      jasmine.clock().tick(100);
      editor.selection.setRangeAtStartOf(editor.body.find('blockquote > p:first'));
      expect(editor.body.find('blockquote')).toExist();
      triggerKeyStroke(8);
      return expect(editor.body.find('blockquote')).not.toExist();
    });
    it('should remove hr when press delete after hr', function() {
      editor.focus();
      jasmine.clock().tick(100);
      editor.selection.setRangeAtStartOf(editor.body.find('p:last'));
      expect(editor.body.find('hr')).toExist();
      triggerKeyStroke(8);
      return expect(editor.body.find('hr')).not.toExist();
    });
    it('should indent content when press tab', function() {
      var $p, e;
      editor.focus();
      jasmine.clock().tick(100);
      $p = editor.body.find('p:first');
      editor.selection.setRangeAtStartOf($p);
      expect($p).not.toHaveAttr('data-indent');
      e = $.Event('keydown', {
        keyCode: 9,
        which: 9
      });
      triggerKeyStroke(9);
      return expect($p.attr('data-indent')).toBe('1');
    });
    it('should insert \\n by pressing return in code block', function() {
      var $pre;
      editor.focus();
      jasmine.clock().tick(100);
      $pre = editor.body.find('pre');
      editor.selection.setRangeAtEndOf($pre);
      expect($pre.text().indexOf('\n')).toBe(-1);
      triggerKeyStroke(13);
      return expect($pre.text().indexOf('\n') > -1).toBe(true);
    });
    it('should leave code block by pressing shift + return', function() {
      var $pre;
      editor.focus();
      jasmine.clock().tick(100);
      $pre = editor.body.find('pre');
      editor.selection.setRangeAtEndOf($pre);
      triggerKeyStroke(13, {
        shiftKey: true
      });
      return expect(editor.util.closestBlockEl()).not.toBeMatchedBy('pre');
    });
    return it('should delete code block by pressing delete at start of pre', function() {
      var $pre;
      editor.focus();
      jasmine.clock().tick(100);
      $pre = editor.body.find('pre');
      editor.selection.setRangeAtStartOf($pre);
      triggerKeyStroke(8);
      return expect(editor.body.find('pre')).not.toExist();
    });
  });

}).call(this);
