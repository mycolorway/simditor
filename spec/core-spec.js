(function() {
  describe('A Simditor instance', function() {
    var editor;
    editor = null;
    beforeEach(function() {
      return editor = spec.generateSimditor();
    });
    afterEach(function() {
      spec.destroySimditor();
      return editor = null;
    });
    it('should render specific layout', function() {
      var $simditor;
      $simditor = $('.simditor');
      expect($simditor).toExist();
      expect($simditor.find('> .simditor-wrapper > .simditor-body')).toExist();
      expect($simditor.find('> .simditor-wrapper > .simditor-placeholder')).toExist();
      expect($simditor.find('> .simditor-wrapper > textarea#editor')).toExist();
      expect(editor.el).toHaveClass('simditor');
      expect(editor.body).toHaveClass('simditor-body');
      return expect(editor.wrapper).toHaveClass('simditor-wrapper');
    });
    it('should reset to default after destroyed', function() {
      if (editor != null) {
        editor.destroy();
      }
      expect($('.simditor')).not.toExist();
      return expect($('textarea#editor')).toExist();
    });
    it('should set formatted value to editor\'s body by calling setValue', function() {
      var tmpHtml;
      tmpHtml = '<p id="flag">test format</p>';
      editor.setValue(tmpHtml);
      return expect($.trim(editor.body.html())).toBe('<p>test format</p>');
    });
    it('should get formatted editor\'s value by calling getValue', function() {
      var tmpHtml;
      tmpHtml = '<p id="flag">test format</p>';
      editor.body.html(tmpHtml);
      return expect(editor.getValue()).toBe('<p>test format</p>');
    });
    return it('should focus on editor\'s body when call focus and blur when call blue', function() {
      editor.focus();
      expect(editor.body).toBeFocused();
      editor.blur();
      return expect(editor.body).not.toBeFocused();
    });
  });

}).call(this);
