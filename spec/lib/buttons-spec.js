(function() {
  describe('Simditor Buttons Module', function() {
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
      tmp = '<p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>\n<p id="para2">相比传统的编辑器它的特点是：</p>\n<ul id="list">\n  <li id="list-item-1">功能精简，加载快速</li>\n  <li id="list-item-2">输出格式化的标准<span id="test-span"> HTML </span></li>\n  <li id="list-item-3">每一个功能都有非常优秀的使用体验</li>\n</ul>\n<pre id="code">this is a code snippet</pre>\n<p id="para3">兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>\n<blockquote>\n    <p id="blockquote-first-line">First line</p>\n    <p id="blockquote-last-line"><br/></p>\n</blockquote>\n<hr/>\n<p id="after-hr">After hr</p>\n<p id="link">test</p>';
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
    it('should let content bold when bold button clicked or by shortcut', function() {
      var spyEvent;
      setRange($('#para2'), 0, 1);
      findButtonLink('bold').trigger('mousedown');
      expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('b');
      spyEvent = spyOnEvent(findButtonLink('bold'), 'mousedown');
      setRange($('#para2'), 0, 1);
      triggerShortCut(66, true);
      return expect(spyEvent).toHaveBeenTriggered();
    });
    it('should let content italic when italic button clicked or by shortcut', function() {
      var spyEvent;
      setRange($('#para2'), 0, 1);
      findButtonLink('italic').trigger('mousedown');
      expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('i');
      spyEvent = spyOnEvent(findButtonLink('italic'), 'mousedown');
      setRange($('#para2'), 0, 1);
      triggerShortCut(73, true);
      return expect(spyEvent).toHaveBeenTriggered();
    });
    it('should let content underline when underline button clicked or by shortcut', function() {
      var spyEvent;
      setRange($('#para2'), 0, 1);
      findButtonLink('underline').trigger('mousedown');
      expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('u');
      spyEvent = spyOnEvent(findButtonLink('underline'), 'mousedown');
      setRange($('#para2'), 0, 1);
      triggerShortCut(85, true);
      return expect(spyEvent).toHaveBeenTriggered();
    });
    it('should let content strike when strikethrough button clicked', function() {
      setRange($('#para2'), 0, 1);
      findButtonLink('strikethrough').trigger('mousedown');
      return expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('strike');
    });
    it('should let content indent when indent button clicked', function() {
      setRange($('#para2'), 0, 1);
      findButtonLink('indent').trigger('mousedown');
      return expect(editor.selection.getRange().commonAncestorContainer).toHaveAttr('data-indent', '1');
    });
    it('should let content outdent when  outdent button clicked', function() {
      setRange($('#para2'), 0, 1);
      findButtonLink('indent').trigger('mousedown');
      findButtonLink('outdent').trigger('mousedown');
      return expect(editor.selection.getRange().commonAncestorContainer).toHaveAttr('data-indent', '0');
    });
    it('should insert a hr when hr button clicked', function() {
      setRange($('#para2'), 0, 1);
      findButtonLink('hr').trigger('mousedown');
      return expect(editor.selection.getRange().commonAncestorContainer.nextSibling).toEqual('hr');
    });
    it('should change content color when color button clicked', function() {
      setRange($('#para2'), 0, 1);
      expect(editor.toolbar.wrapper.find('.color-list')).not.toBeVisible();
      findButtonLink('color').trigger('mousedown');
      expect(editor.toolbar.wrapper.find('.color-list')).toBeVisible();
      editor.toolbar.wrapper.find('.font-color-1').click();
      return expect($(editor.selection.getRange().commonAncestorContainer.parentNode)).toEqual('font[color]');
    });
    it('should let content be title when title button clicked', function() {
      setRange($('#para2'), 0, 0);
      findButtonLink('title').trigger('mousedown');
      editor.toolbar.wrapper.find('.menu-item-h1').click();
      return expect($(editor.selection.getRange().commonAncestorContainer)).toEqual('h1');
    });
    return it('should create list when list button clicked', function() {
      var parentNode, spyEvent, spyEvent2;
      setRange = function(ele1, offset1, ele2, offset2) {
        var range;
        if (!ele2) {
          ele2 = ele1;
          offset2 = offset1;
        }
        ele1 = ele1[0];
        ele2 = ele2[0];
        range = document.createRange();
        range.setStart(ele1, offset1);
        range.setEnd(ele2, offset2);
        editor.focus();
        return editor.selection.selectRange(range);
      };
      setRange($('#para2'), 0);
      findButtonLink('ul').trigger('mousedown');
      parentNode = $(editor.selection.getRange().commonAncestorContainer);
      expect(parentNode).toEqual('li');
      expect(parentNode.parent()).toBeMatchedBy('ul');
      findButtonLink('ul').trigger('mousedown');
      parentNode = $(editor.selection.getRange().commonAncestorContainer);
      expect(parentNode).toEqual('p');
      setRange($('#list-item-1'), 0, $('#list-item-3'), 1);
      findButtonLink('ul').trigger('mousedown');
      parentNode = $(editor.selection.getRange().commonAncestorContainer);
      expect(parentNode).not.toEqual('ul');
      expect(parentNode.find('li')).not.toExist();
      findButtonLink('ul').trigger('mousedown');
      parentNode = $(editor.selection.getRange().commonAncestorContainer);
      expect(parentNode).toEqual('ul');
      expect(parentNode.find('li').length).toBe(3);
      spyEvent = spyOnEvent(findButtonLink('ul'), 'mousedown');
      triggerShortCut(190, true);
      expect(spyEvent).toHaveBeenTriggered();
      spyEvent2 = spyOnEvent(findButtonLink('ol'), 'mousedown');
      triggerShortCut(191, true);
      return expect(spyEvent2).toHaveBeenTriggered();
    });
  });

}).call(this);
