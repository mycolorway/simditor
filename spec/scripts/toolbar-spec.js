(function() {
  describe('Toolbar', function() {
    var compareArray, editor, toolbar;
    editor = null;
    toolbar = ['bold', 'title', 'italic', 'underline', 'strikethrough', 'color', 'ol', 'ul', 'blockquote', 'code', 'table', 'link', 'image', 'hr', 'indent', 'outdent'];
    beforeEach(function() {
      $('<textarea id="test"></textarea>').appendTo('body');
      return editor = new Simditor({
        textarea: '#test',
        toolbar: toolbar
      });
    });
    afterEach(function() {
      if (editor != null) {
        editor.destroy();
      }
      return $('#test').remove();
    });
    compareArray = function(arr1, arr2) {
      return arr1.toString() === arr2.toString();
    };
    describe('_init method', function() {
      it('should link editor\'s instance', function() {
        return expect(editor.toolbar.editor).toBe(editor);
      });
      return it('should remove menu-on class on li when click toolbar', function() {
        editor.toolbar.list.find('li').eq(0).addClass('menu-on');
        editor.toolbar.wrapper.trigger('mousedown');
        return expect(editor.toolbar.list.find('li').eq(0)).not.toHaveClass('menu-on');
      });
    });
    describe('render method', function() {
      it('should create button\'s instance to its buttons array', function() {
        var button, nameArray, _i, _len, _ref;
        expect(editor.toolbar.buttons.length).toBe(toolbar.length);
        nameArray = [];
        _ref = editor.toolbar.buttons;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          button = _ref[_i];
          nameArray.push(button.name);
        }
        return expect(compareArray(nameArray, toolbar)).toBeTruthy();
      });
      return it('should prepend toolbar to editor\'s wrapper', function() {
        expect(editor.wrapper.find('.simditor-toolbar')).toExist();
        return expect(editor.wrapper.find('.simditor-toolbar>ul>li').length).toBe(toolbar.length);
      });
    });
    describe('findButton method', function() {
      it('should find correct button', function() {
        return expect(editor.toolbar.findButton('bold').name).toBe('bold');
      });
      return it('it should return null when wrong arg give', function() {
        return expect(editor.toolbar.findButton('error')).toBeNull();
      });
    });
    return describe('toolbarStatus', function() {});
  });

}).call(this);
