(function() {
  describe('Core', function() {
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
    describe('_init & destroy method', function() {
      it('should append template to DOM when constructed', function() {
        expect($('.simditor')).toExist();
        expect($('.simditor')).toContainElement('.simditor-wrapper .simditor-placeholder');
        expect($('.simditor')).toContainElement('.simditor-wrapper .simditor-body');
        expect($('.simditor')).toContainElement('textarea');
        expect(editor.el).toHaveClass('simditor');
        expect(editor.body).toHaveClass('simditor-body');
        return expect(editor.wrapper).toHaveClass('simditor-wrapper');
      });
      return it('should reset to default when call destroy', function() {
        editor.destroy();
        expect($('.simditor')).not.toExist();
        return expect($('textarea#test')).toExist();
      });
    });
    describe('setValue && getValue method', function() {
      it('should set correct value when call setValue', function() {
        editor.setValue('Hello, world!');
        return expect($('#test').val()).toBe('Hello, world!');
      });
      return it('should return correct value when call getValue', function() {
        editor.setValue('Hello, world!');
        return expect(editor.getValue()).toBe('<p>Hello, world!</p>');
      });
    });
    describe('focus && blur method', function() {
      return it('should focus on editor\'s body when call focus and blur when call blue', function() {
        editor.focus();
        expect(editor.body).toBeFocused();
        editor.blur();
        return expect(editor.body).not.toBeFocused();
      });
    });
    return describe('hidePopover method', function() {});
  });

}).call(this);
