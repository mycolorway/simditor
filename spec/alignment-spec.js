(function() {
  describe('A Simditor instance with alignment manager', function() {
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
      it("to left", function() {
        expect($p1.attr('data-align')).toBe(void 0);
        expect($p2.attr('data-align')).toBe(void 0);
        editor.alignment.left();
        expect($p1.attr('data-align')).toBe('left');
        return expect($p2.attr('data-align')).toBe('left');
      });
      it("to center", function() {
        editor.alignment.center();
        expect($p1.attr('data-align')).toBe('center');
        return expect($p2.attr('data-align')).toBe('center');
      });
      return it("to right", function() {
        editor.alignment.right();
        expect($p1.attr('data-align')).toBe('right');
        return expect($p2.attr('data-align')).toBe('right');
      });
    });
  });

}).call(this);
