(function() {
  describe('A Simditor instance', function() {
    var $textarea, editor;
    editor = null;
    $textarea = null;
    beforeEach(function() {
      jasmine.clock().install();
      $textarea = $('<textarea id="editor"></textarea>').appendTo('body');
      return editor = new Simditor({
        textarea: $textarea
      });
    });
    afterEach(function() {
      jasmine.clock().uninstall();
      if (editor != null) {
        editor.destroy();
      }
      editor = null;
      $textarea.remove();
      return $textarea = null;
    });
    it('should render specific layout', function() {
      expect(editor.el.find('.simditor-paste-area')).toExist();
      return expect(editor.el.find('.simditor-clean-paste-area')).toExist();
    });
    return it('should ensure editor\'s body has content', function() {
      var e;
      editor.body.empty();
      editor.body.focus();
      jasmine.clock().tick(100);
      e = $.Event('keyup', {
        which: 8,
        keyCode: 8
      });
      editor.body.trigger(e);
      return expect(editor.body.find('p>br')).toExist();
    });
  });

}).call(this);
