(function() {
  describe('Util', function() {
    var editor;
    editor = null;
    beforeEach(function() {
      var tmp;
      $('<textarea id="test"></textarea>').appendTo('body');
      editor = new Simditor({
        textarea: '#test'
      });
      tmp = '<p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>\n  <p>相比传统的编辑器它的特点是：</p>\n    <ul id="list">\n      <li id="list-item-1">功能精简，加载快速</li>\n      <li id="list-item-2">输出格式化的标准 HTML</li>\n      <li>每一个功能都有非常优秀的使用体验</li>\n    </ul>\n    <pre id="code">"this is a code snippet"</pre>\n  <p data-indent="2" id="para">兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>';
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
        return expect(editor.util.editor).toBe(editor);
      });
    });
    describe('closestBlockEl && furthestBlockEl method', function() {
      return it('should find the closet|furthest Block element', function() {
        expect(editor.util.closestBlockEl($('#list-item-1'))[0]).toBe($('#list-item-1')[0]);
        return expect(editor.util.furthestBlockEl($('#list-item-1'))[0]).toBe($('#list')[0]);
      });
    });
    return describe('indent && outdent method', function() {
      var setRange;
      setRange = function(ele) {
        var range;
        ele = ele[0];
        range = document.createRange();
        range.setStart(ele, 0);
        range.setEnd(ele, 1);
        editor.focus();
        return editor.selection.selectRange(range);
      };
      it('pre tag should indent & outdent correctly', function() {
        var text;
        setRange($('pre'));
        text = $('#code').text();
        editor.util.indent();
        expect($('#code').text()).toBe('\u00A0\u00A0' + text);
        editor.util.outdent();
        return expect($('#code').text()).toBe(text);
      });
      it('list tag should indent & outdent correctly', function() {
        setRange($('#list-item-1'));
        editor.util.indent();
        expect($('#list-item-1').parent().attr('id')).toBe('list');
        setRange($('#list-item-2'));
        editor.util.indent();
        expect($('#list-item-2').parent().parent().attr('id')).toBe('list-item-1');
        setRange($('#list-item-2'));
        editor.util.outdent();
        return expect($('#list-item-2').parent().attr('id')).toBe('list');
      });
      it('p(h1 h2..) tag should indent & outdent correctly', function() {
        setRange($('#para'));
        editor.util.indent();
        expect($('#para').attr('data-indent')).toBe('3');
        setRange($('#para'));
        editor.util.outdent();
        return expect($('#para').attr('data-indent')).toBe('2');
      });
      return it('table', function() {});
    });
  });

}).call(this);
