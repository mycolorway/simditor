(function() {
  describe('Simditor Button Module', function() {
    var editor, findButtonLink, setRange, toolbar, triggerShortCut;
    editor = null;
    toolbar = ['bold', 'title', 'italic', 'underline', 'strikethrough', 'color', 'ol', 'ul', 'blockquote', 'code', 'table', 'link', 'image', 'hr', 'indent', 'outdent'];
    beforeEach(function() {
      var tmp;
      $('<textarea id="test"></textarea>').appendTo('body');
      editor = new Simditor({
        textarea: '#test',
        toolbar: toolbar
      });
      tmp = '<p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>\n<p id="para2">相比传统的编辑器它的特点是：</p>\n<ul id="list">\n  <li>功能精简，加载快速</li>\n  <li id="list-item-2">输出格式化的标准<span id="test-span"> HTML </span></li>\n  <li>每一个功能都有非常优秀的使用体验</li>\n</ul>\n<pre id="code">this is a code snippet</pre>\n<p id="para3">兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>\n<blockquote>\n    <p id="blockquote-first-line">First line</p>\n    <p id="blockquote-last-line"><br/></p>\n</blockquote>\n<hr/>\n<p id="after-hr">After hr</p>';
      tmp = $(tmp);
      tmp.appendTo('.simditor-body');
      return editor.sync();
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
    findButtonLink = function(name) {
      var buttonLink;
      buttonLink = editor.toolbar.list.find('a.toolbar-item-' + name);
      return buttonLink != null ? buttonLink : null;
    };
    triggerShortCut = function(key, ctrl, shift) {
      var e;
      e = $.Event('keydown', {
        keyCode: key,
        which: key,
        shiftKey: shift != null
      });
      if (editor.util.os.mac) {
        e.metaKey = ctrl != null;
      } else {
        e.ctrlKey = ctrl != null;
      }
      return editor.body.trigger(e);
    };
    describe('bold button', function() {
      it('should let content bold when clicked', function() {
        setRange($('#para2'), 0, 1);
        findButtonLink('bold').trigger('mousedown');
        return expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('b');
      });
      return it('should has shortcut for ctrl + b', function() {
        var spyEvent;
        spyEvent = spyOnEvent(findButtonLink('bold'), 'mousedown');
        setRange($('#para2'), 0, 1);
        triggerShortCut(66, true);
        return expect(spyEvent).toHaveBeenTriggered();
      });
    });
    describe('italic button', function() {
      it('should let content italic when clicked', function() {
        setRange($('#para2'), 0, 1);
        findButtonLink('italic').trigger('mousedown');
        return expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('i');
      });
      return it('should has shortcut for ctrl + i', function() {
        var spyEvent;
        spyEvent = spyOnEvent(findButtonLink('italic'), 'mousedown');
        setRange($('#para2'), 0, 1);
        triggerShortCut(73, true);
        return expect(spyEvent).toHaveBeenTriggered();
      });
    });
    describe('underline button', function() {
      it('should let content underline when clicked', function() {
        setRange($('#para2'), 0, 1);
        findButtonLink('underline').trigger('mousedown');
        return expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('u');
      });
      return it('should has shortcut for ctrl + u', function() {
        var spyEvent;
        spyEvent = spyOnEvent(findButtonLink('underline'), 'mousedown');
        setRange($('#para2'), 0, 1);
        triggerShortCut(85, true);
        return expect(spyEvent).toHaveBeenTriggered();
      });
    });
    describe('strikethrough button', function() {
      return it('should let content strike when clicked', function() {
        setRange($('#para2'), 0, 1);
        findButtonLink('strikethrough').trigger('mousedown');
        return expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('strike');
      });
    });
    describe('indent button', function() {
      return it('should let content indent when clicked', function() {
        setRange($('#para2'), 0, 1);
        findButtonLink('indent').trigger('mousedown');
        return expect(editor.selection.getRange().commonAncestorContainer).toHaveAttr('data-indent', '1');
      });
    });
    describe('outdent button', function() {
      return it('should let content outdent when clicked', function() {
        setRange($('#para2'), 0, 1);
        findButtonLink('indent').trigger('mousedown');
        findButtonLink('outdent').trigger('mousedown');
        return expect(editor.selection.getRange().commonAncestorContainer).toHaveAttr('data-indent', '0');
      });
    });
    return describe('hr button', function() {
      return it('should insert a hr when clicked', function() {
        setRange($('#para2'), 0, 1);
        findButtonLink('hr').trigger('mousedown');
        return expect(editor.selection.getRange().commonAncestorContainer.nextSibling).toEqual('hr');
      });
    });
  });

}).call(this);
