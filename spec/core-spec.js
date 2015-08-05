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
      expect($simditor.length).toBe(1);
      expect($simditor.find('> .simditor-wrapper > .simditor-body').length).toBe(1);
      expect($simditor.find('> .simditor-wrapper > .simditor-placeholder').length).toBe(1);
      expect($simditor.find('> .simditor-wrapper > textarea#editor').length).toBe(1);
      expect(editor.el.is('.simditor')).toBe(true);
      expect(editor.body.is('.simditor-body')).toBe(true);
      return expect(editor.wrapper.is('.simditor-wrapper')).toBe(true);
    });
    it('should reset to default after destroyed', function() {
      var $textarea;
      $textarea = $('textarea#editor');
      if (editor != null) {
        editor.destroy();
      }
      expect($('.simditor').length).toBe(0);
      expect($textarea.length).toBe(1);
      return expect($textarea.data('simditor')).toBeUndefined();
    });
    it('should set formatted value to editor\'s body after calling setValue', function() {
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
    return it('should lose focus after calling blur', function() {
      editor.focus();
      editor.blur();
      expect(document.activeElement).not.toBe(editor.body[0]);
      expect(editor.selection.range()).toBe(null);
      return expect(editor.inputManager.focused).toBe(false);
    });
  });

}).call(this);
