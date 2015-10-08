(function() {
  describe('A Simditor instance with indentation manager', function() {
    var editor;
    editor = null;
    beforeEach(function() {});
    afterEach(function() {
      spec.destroySimditor();
      return editor = null;
    });
    it('should indent paragraph when pressing tab', function() {
      var $p, $p1, $p2, range;
      editor = spec.generateSimditor({
        content: '<p>paragraph 1</>\n<p>paragraph 2</>'
      });
      editor.focus();
      $p = editor.body.find('> p');
      $p1 = $p.first();
      $p2 = $p.eq(1);
      range = document.createRange();
      editor.selection.setRangeAtEndOf($p2, range);
      range.setStart($p1[0], 0);
      editor.selection.range(range);
      expect(parseInt($p1.css('margin-left'))).toBe(0);
      expect(parseInt($p2.css('margin-left'))).toBe(0);
      editor.indentation.indent();
      expect(parseInt($p1.css('margin-left'))).toBe(editor.opts.indentWidth);
      expect(parseInt($p2.css('margin-left'))).toBe(editor.opts.indentWidth);
      editor.indentation.indent(true);
      expect(parseInt($p1.css('margin-left'))).toBe(0);
      return expect(parseInt($p2.css('margin-left'))).toBe(0);
    });
    it('should indent list when pressing tab in ul', function() {
      var $li, $li1, $li2, $ul, range;
      editor = spec.generateSimditor({
        content: '<ul>\n  <li>item 1</li>\n  <li>item 2</li>\n  <li>item 3</li>\n</ul>'
      });
      editor.focus();
      $ul = editor.body.find('> ul');
      $li = $ul.find('li');
      $li1 = $li.eq(1);
      $li2 = $li.eq(2);
      range = document.createRange();
      editor.selection.setRangeAtEndOf($li2, range);
      range.setStart($li1[0], 0);
      editor.selection.range(range);
      expect($li1.parentsUntil(editor.body, 'ul').length).toBe(1);
      expect($li2.parentsUntil(editor.body, 'ul').length).toBe(1);
      editor.indentation.indent();
      expect($li1.parentsUntil(editor.body, 'ul').length).toBe(2);
      expect($li2.parentsUntil(editor.body, 'ul').length).toBe(2);
      editor.indentation.indent(true);
      expect($li1.parentsUntil(editor.body, 'ul').length).toBe(1);
      return expect($li2.parentsUntil(editor.body, 'ul').length).toBe(1);
    });
    return it('should insert two spaces while pressing tab in code block', function() {
      var $pre, range;
      editor = spec.generateSimditor({
        content: '<pre><code>var test = 1;</code></pre>',
        toolbar: ['code']
      });
      editor.focus();
      $pre = editor.body.find('> pre');
      range = document.createRange();
      editor.selection.setRangeAtStartOf($pre, range);
      expect($pre.html()).toBe('var test = 1;');
      editor.indentation.indent();
      return expect($pre.html()).toBe('&nbsp;&nbsp;var test = 1;');
    });
  });

}).call(this);
