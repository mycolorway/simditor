(function() {
  describe('A Simditor instance', function() {
    var $textarea, editor;
    editor = null;
    $textarea = null;
    beforeEach(function() {
      var content;
      jasmine.clock().install();
      content = '<p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>\n<p>相比传统的编辑器它的特点是：</p>\n<ul>\n  <li>功能精简，加载快速</li>\n  <li>输出格式化的标准 HTML</li>\n  <li>每一个功能都有非常优秀的使用体验</li>\n</ul>\n<p>兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>';
      $textarea = $('<textarea id="editor"></textarea>').val(content).appendTo('body');
      return editor = new Simditor({
        textarea: $textarea,
        toolbar: ['bold', 'title', 'italic', 'underline', 'strikethrough', 'color', 'ol', 'ul', 'blockquote', 'code', 'table', 'link', 'image', 'hr', 'indent', 'outdent']
      });
    });
    afterEach(function() {
      jasmine.clock().uninstall();
      editor.destroy();
      editor = null;
      $textarea.remove();
      return $textarea = null;
    });
    return it('should set selection bold after clicking bold button', function() {
      var $button, $p, $text, range;
      editor.focus();
      jasmine.clock().tick(100);
      $p = editor.body.find('p:first');
      $button = editor.toolbar.list.find('.toolbar-item-bold');
      expect($button).toExist();
      $text = $p.contents().first();
      range = editor.selection.getRange();
      range.setStart($text[0], 0);
      range.setEnd($text[0], 8);
      editor.selection.selectRange(range);
      $button.mousedown();
      return expect(editor.body.find('b')).toExist();
    });
  });

}).call(this);
