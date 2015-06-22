(function() {
  describe('A Simditor instance with buttons', function() {
    var editor;
    editor = null;
    beforeEach(function() {
      jasmine.clock().install();
      return editor = spec.generateSimditor();
    });
    afterEach(function() {
      jasmine.clock().uninstall();
      spec.destroySimditor();
      return editor = null;
    });
    it('should set selection bold after clicking bold button', function() {
      var $button, $p, $text, range;
      editor.focus();
      jasmine.clock().tick(100);
      $p = editor.body.find('p:first');
      $button = editor.toolbar.list.find('.toolbar-item-bold');
      expect($button).toExist();
      $text = $p.contents().first();
      range = document.createRange();
      range.setStart($text[0], 0);
      range.setEnd($text[0], 8);
      editor.selection.selectRange(range);
      $button.mousedown();
      return expect($p.find('b')).toExist();
    });
    it('should create code block after clicking code button', function() {
      var $button, $p, $text, range;
      editor.setValue('<p>var test = 1;</p>');
      editor.focus();
      jasmine.clock().tick(100);
      $p = editor.body.find('p:first');
      $button = editor.toolbar.list.find('.toolbar-item-code');
      expect($button).toExist();
      $text = $p.contents().first();
      range = document.createRange();
      range.setStart($text[0], 0);
      range.setEnd($text[0], 8);
      editor.selection.selectRange(range);
      $button.mousedown();
      editor.trigger('selectionchanged');
      expect(editor.getValue()).toBe('<pre><code>var test = 1;</code></pre>');
      editor.el.find('.code-popover .select-lang').val('js').change();
      return expect(editor.getValue()).toBe('<pre><code class="lang-js">var test = 1;</code></pre>');
    });
    describe('table button', function() {
      return it('should create a new table after clicking table button and selecting table size', function() {
        var $button, $table;
        editor.focus();
        jasmine.clock().tick(100);
        $button = editor.toolbar.list.find('.toolbar-item-table');
        expect(editor.body.find('table')).not.toExist();
        $button.mousedown();
        $('.menu-create-table td').eq(2).mousedown();
        $table = editor.body.find('table');
        expect($table).toExist();
        expect($table.find('tr').length).toBe(2);
        return expect($table.find('th, td').length).toBe(6);
      });
    });
    return describe('aligning paragraph', function() {
      var $p1, $p2;
      $p1 = null;
      $p2 = null;
      beforeEach(function() {
        var $p, range;
        editor.focus();
        jasmine.clock().tick(100);
        $p = editor.body.find('> p');
        $p1 = $p.first();
        $p2 = $p.eq(1);
        range = document.createRange();
        editor.selection.setRangeAtEndOf($p2, range);
        range.setStart($p1[0], 0);
        return editor.selection.selectRange(range);
      });
      it("can align to right", function() {
        var button;
        expect($p1.css('text-align')).toBe('start');
        expect($p2.css('text-align')).toBe('start');
        button = editor.toolbar.list.find('.toolbar-item-alignment').data('button');
        button.command("right");
        expect($p1.css('text-align')).toBe('right');
        return expect($p2.css('text-align')).toBe('right');
      });
      it("can align to center", function() {
        var button;
        button = editor.toolbar.list.find('.toolbar-item-alignment').data('button');
        button.command("center");
        expect($p1.css('text-align')).toBe('center');
        return expect($p2.css('text-align')).toBe('center');
      });
      return it("can align to left", function() {
        var button;
        button = editor.toolbar.list.find('.toolbar-item-alignment').data('button');
        button.command("left");
        expect($p1.css('text-align')).toBe('start');
        return expect($p2.css('text-align')).toBe('start');
      });
    });
  });

}).call(this);
