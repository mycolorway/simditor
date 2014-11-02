(function() {
  describe('A Simditor Instance', function() {
    var editor;
    editor = null;
    beforeEach(function() {
      $('<textarea id="test"></textarea>').appendTo('body');
      return editor = new Simditor({
        textarea: '#test'
      });
    });
    afterEach(function() {
      if (editor != null) {
        editor.destroy();
      }
      return $('#test').remove();
    });
    it('should render specific layout', function() {
      var $simditor;
      $simditor = $('.simditor');
      expect($simditor).toExist();
      expect($simditor.find('> .simditor-wrapper > .simditor-body')).toExist();
      expect($simditor.find('> .simditor-wrapper > .simditor-placeholder')).toExist();
      expect($simditor.find('> textarea#test')).toExist();
      expect(editor.el).toHaveClass('simditor');
      expect(editor.body).toHaveClass('simditor-body');
      return expect(editor.wrapper).toHaveClass('simditor-wrapper');
    });
    it('should reset to default when destroyed', function() {
      editor.destroy();
      expect($('.simditor')).not.toExist();
      return expect($('textarea#test')).toExist();
    });
    it('should set formatted value to editor\'s body when call setValue', function() {
      var $textarea, tmpHtml;
      $textarea = $('.simditor textarea');
      tmpHtml = '<p id="flag">test format</p>';
      editor.setValue(tmpHtml);
      return expect(editor.body).toContainHtml('<p>test format</p>');
    });
    it('should get formatted editor\'s value when call getValue', function() {
      var tmpHtml;
      tmpHtml = '<p id="flag">test format</p>';
      editor.body.empty();
      $(tmpHtml).appendTo(editor.body);
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
