(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  describe('Simditor Button Module', function() {
    var TestButton, editor, setRange;
    editor = null;
    TestButton = (function(_super) {
      __extends(TestButton, _super);

      function TestButton() {
        return TestButton.__super__.constructor.apply(this, arguments);
      }

      TestButton.prototype.name = 'test';

      TestButton.prototype.title = 'test';

      TestButton.prototype.htmlTag = 'b, strong';

      TestButton.prototype.disableTag = 'pre';

      TestButton.prototype.shortcut = 'shift+68';

      TestButton.prototype.title = 'test';

      TestButton.prototype.active = false;

      TestButton.prototype.menu = [
        {
          name: 'subMenu',
          text: 'subMenu',
          param: true
        }
      ];

      TestButton.prototype.render = function() {
        return TestButton.__super__.render.call(this);
      };

      TestButton.prototype.command = function(param) {
        if (param) {
          return $(document).trigger('testbuttonworked');
        }
      };

      return TestButton;

    })(Button);
    Simditor.Toolbar.addButton(TestButton);
    beforeEach(function() {
      $('<textarea id="test"></textarea>').appendTo('body');
      editor = new Simditor({
        textarea: '#test',
        toolbar: ['test']
      });
      $('<p>test</p><pre id="dis">test disabled tag</pre><b id="act">test active tag</b>').appendTo(editor.body);
      return editor.focus();
    });
    afterEach(function() {
      if (editor != null) {
        editor.destroy();
      }
      return $('#test').remove();
    });
    setRange = function(ele, offsetStart, offsetEnd) {
      var offset, range;
      ele = ele[0];
      range = document.createRange();
      if (!offset) {
        offset = 0;
      }
      range.setStart(ele, offsetStart);
      range.setEnd(ele, offsetEnd);
      editor.focus();
      return editor.selection.selectRange(range);
    };
    it('should render specific layout', function() {
      expect(editor.wrapper.find('a.toolbar-item.toolbar-item-test')).toExist();
      return expect(editor.toolbar.findButton('test').name).toBe('test');
    });
    it('should expand menu when clicked', function() {
      var btn, btnLink, spyEvent;
      btn = editor.toolbar.findButton('test');
      btnLink = editor.wrapper.find('a.toolbar-item.toolbar-item-test');
      spyEvent = spyOnEvent(btn, 'menuexpand');
      btnLink.trigger('mousedown');
      expect(btnLink.parent()).toHaveClass('menu-on');
      return expect(spyEvent).toHaveBeenTriggered();
    });
    it('should exec custom command when click menu-item', function() {
      var btnLink, spyEvent;
      btnLink = editor.wrapper.find('a.toolbar-item.toolbar-item-test');
      btnLink.trigger('mousedown');
      spyEvent = spyOnEvent(document, 'testbuttonworked');
      btnLink.parent().find('.menu-item-subMenu').trigger('click');
      return expect(spyEvent).toHaveBeenTriggered();
    });
    it('should be disabled when in disabled tag', function() {
      var btnLink;
      setRange($('#dis'), 0, 1);
      editor.trigger('selectionchanged');
      btnLink = editor.wrapper.find('a.toolbar-item.toolbar-item-test');
      return expect(btnLink).toHaveClass('disabled');
    });
    return it('should be active when in active tag', function() {
      var btnLink;
      setRange($('#act'), 0, 1);
      editor.trigger('selectionchanged');
      btnLink = editor.wrapper.find('a.toolbar-item.toolbar-item-test');
      return expect(btnLink).toHaveClass('active');
    });
  });

}).call(this);
