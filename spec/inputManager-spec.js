(function() {
  describe('A Simditor instance with inputManager', function() {
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
    it('should render specific layout', function() {
      return expect(editor.el.find('.simditor-paste-area')).toExist();
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
