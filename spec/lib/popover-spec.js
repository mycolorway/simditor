(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  describe('Simditor Popover Module', function() {
    var TestPopover, editor, testPopover;
    editor = null;
    testPopover = null;
    TestPopover = (function(_super) {
      __extends(TestPopover, _super);

      function TestPopover() {
        return TestPopover.__super__.constructor.apply(this, arguments);
      }

      TestPopover.prototype.render = function() {
        this.el.addClass('test-popover');
        return this.el.append($('<p>popover</p>'));
      };

      return TestPopover;

    })(Popover);
    beforeEach(function() {
      var button;
      $('<textarea id="test"></textarea>').appendTo('body');
      editor = new Simditor({
        textarea: '#test'
      });
      $('<p id="target">target</p>').appendTo(editor.body);
      button = {
        editor: editor
      };
      return testPopover = new TestPopover({
        button: button
      });
    });
    afterEach(function() {
      if (editor != null) {
        editor.destroy();
      }
      return $('#test').remove();
    });
    it('can be inherited from', function() {
      return expect(testPopover instanceof SimpleModule).toBeTruthy();
    });
    it('should render specific layout', function() {
      return expect(editor.el.find('.simditor-popover.test-popover')).toExist();
    });
    it('should add/remove hover class when hovered', function() {
      testPopover.el.trigger('mouseenter');
      expect(testPopover.el).toHaveClass('hover');
      testPopover.el.trigger('mouseleave');
      return expect(testPopover.el).not.toHaveClass('hover');
    });
    it('should show up when call show on specified node', function() {
      var $target;
      $target = $('#target');
      expect(testPopover).not.toBeVisible();
      testPopover.show($target);
      expect($target).toHaveClass('selected');
      expect(testPopover.el).toBeVisible();
      return expect(testPopover.active).toBeTruthy();
    });
    return it('should hide when call hide method', function() {
      var $target, spyEvent;
      spyEvent = spyOnEvent(testPopover, 'popoverhide');
      testPopover.hide();
      expect(spyEvent).not.toHaveBeenTriggered();
      $target = $('#target');
      spyEvent.reset();
      testPopover.show($target);
      expect(testPopover.el).toBeVisible();
      testPopover.hide();
      expect(spyEvent).toHaveBeenTriggered();
      return expect(testPopover.el).not.toBeVisible();
    });
  });

}).call(this);
