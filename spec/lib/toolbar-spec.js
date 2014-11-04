(function() {
  describe('Simditor Toolbar Module', function() {
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
    it('should float toolbar when scroll down', function() {
      expect(editor.toolbar.wrapper).not.toHaveClass('toolbar-floating');
      $('body').css('height', '2000');
      $(document).scrollTop(200);
      $(window).trigger('scroll.simditor-' + editor.id);
      expect(editor.toolbar.wrapper).toHaveClass('toolbar-floating');
      return $('body').css('height', 'auto');
    });
    it('should remove menu-on class on li when click toolbar', function() {
      editor.toolbar.list.find('li').eq(0).addClass('menu-on');
      editor.toolbar.wrapper.trigger('mousedown');
      return expect(editor.toolbar.list.find('li').eq(0)).not.toHaveClass('menu-on');
    });
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
    it('should render toolbar to editor\'s wrapper', function() {
      expect(editor.wrapper.find('.simditor-toolbar')).toExist();
      return expect(editor.wrapper.find('.simditor-toolbar  >ul > li >.toolbar-item').length).toBe(toolbar.length);
    });
    return it('should find correct button when call findButton', function() {
      expect(editor.toolbar.findButton('bold').name).toBe('bold');
      return expect(editor.toolbar.findButton('error')).toBeNull();
    });
  });

}).call(this);
