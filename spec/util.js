(function() {
  window.spec = {
    generateSimditor: function() {
      var $textarea, content;
      content = '<p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>\n<p>相比传统的编辑器它的特点是：</p>\n<ul>\n  <li>功能精简，加载快速</li>\n  <li>输出格式化的标准 HTML</li>\n  <li>每一个功能都有非常优秀的使用体验</li>\n</ul>\n<p>兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>\n<pre>this is a code snippet</pre>\n<blockquote><p>First line</p><p><br/></p></blockquote>\n<hr/>\n<p><br/></p>';
      $textarea = $('<textarea id="editor"></textarea>').val(content).appendTo('body');
      return new Simditor({
        textarea: $textarea,
        toolbar: ['bold', 'alignment', 'code', 'table']
      });
    },
    destroySimditor: function() {
      var $textarea, editor;
      $textarea = $('#editor');
      editor = $textarea.data('simditor');
      if (editor != null) {
        editor.destroy();
      }
      return $textarea.remove();
    }
  };

}).call(this);
