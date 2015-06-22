(function() {
  describe('A Simditor instance with keystroke manager', function() {
    var editor, triggerKeyStroke;
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
