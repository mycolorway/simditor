(function() {
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

  describe('Core', function() {
    describe('_init & destroy method', function() {
      return it('should render DOM', function() {
        expect($('.simditor').length).toBe(1);
        editor.destroy();
        return expect($('.simditor').length).toBe(0);
      });
    });
    describe('setValue  && getValue && sync method', function() {
      return it('should set correct value', function() {
        editor.setValue('Hello, world!');
        expect($('#test').val()).toBe('Hello, world!');
        return expect(editor.getValue()).toBe('<p>Hello, world!</p>');
      });
    });
    describe('focus && blur method', function() {
      return it('should focus on editor', function() {
        $('<input id="tmp"></input>').appendTo('body');
        $('#tmp').focus();
        expect(document.activeElement.id).toBe('tmp');
        editor.focus();
        expect(document.activeElement.className).toBe('simditor-body');
        editor.blur();
        expect(document.activeElement).not.toBe('simditor-body');
        return $('#tmp').remove();
      });
    });
    return describe('hidePopover method', function() {});
  });

  describe('Selection', function() {
    it('_init method', function() {
      expect(editor.selection.editor).toBe(editor);
      return expect(editor.selection.sel).toBe(document.getSelection());
    });
    describe('selectRange && getRange', function() {
      return it('should perform well', function() {
        var range, tmp;
        tmp = $('<p id="test1">this is <b id="test2">test</b> text</p>').appendTo('.simditor-body');
        range = document.createRange();
        range.setStart($('#test1')[0], 0);
        range.setEnd($('#test2')[0], 0);
        editor.focus();
        editor.selection.selectRange(range);
        expect(editor.selection.getRange().toString() === range.toString()).toBe(true);
        editor.selection.clear();
        expect(editor.selection.getRange()).toBe(null);
        return tmp.remove();
      });
    });
    describe('insert and set method', function() {
      beforeEach(function() {
        var range, tmp;
        tmp = $('<p id="test1">this <b id="test2">is</b> <b id="test3">test</b>text</p>').appendTo('.simditor-body');
        range = document.createRange();
        range.setStart($('#test1')[0], 0);
        range.setEnd($('#test2')[0], 0);
        editor.focus();
        return editor.selection.selectRange(range);
      });
      xit('should insert text node', function() {
        editor.selection.insertNode(document.createTextNode('test'));
        return expect(editor.selection.getRange().innerHTML).toBe('nodethis is test text');
      });
      it('setRangeAfter', function() {
        editor.selection.setRangeAfter($('#test3'));
        return expect(editor.selection.getRange().startOffset).toBe(4);
      });
      it('setRangeBefore', function() {
        editor.selection.setRangeBefore($('#test3'));
        return expect(editor.selection.getRange().startOffset).toBe(3);
      });
      it('setRangeAtStartOf', function() {
        editor.selection.setRangeAtStartOf($('#test3'));
        return expect(editor.selection.getRange().endContainer).toBe($('#test3')[0]);
      });
      return it('setRangeAtEndOf', function() {
        editor.selection.setRangeAtEndOf($('#test3'));
        return expect(editor.selection.getRange().endContainer).toBe($('#test3')[0]);
      });
    });
    return describe('save and restore', function() {});
  });

  describe('Util', function() {
    it('_init method', function() {
      return expect(editor.util.editor).toBe(editor);
    });
    beforeEach(function() {
      var tmp;
      tmp = '<p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>\n  <p>相比传统的编辑器它的特点是：</p>\n    <ul id="list">\n      <li id="list-item-1">功能精简，加载快速</li>\n      <li id="list-item-2">输出格式化的标准 HTML</li>\n      <li>每一个功能都有非常优秀的使用体验</li>\n    </ul>\n    <pre id="code">"this is a code snippet"</pre>\n  <p data-indent="2" id="para">兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>';
      tmp = $(tmp);
      return tmp.appendTo('.simditor-body');
    });
    describe('is Empty && Block method', function() {
      return it('should return right answer', function() {
        var node;
        node = $('<h4></h4>').appendTo('.simditor-body');
        expect(editor.util.isEmptyNode(node)).toBe(true);
        return node.remove();
      });
    });
    describe('find_el_method', function() {
      return it('closet && furthest BlockNode', function() {
        expect(editor.util.closestBlockEl($('#list-item-1'))[0]).toBe($('#list-item-1')[0]);
        return expect(editor.util.furthestBlockEl($('#list-item-1'))[0]).toBe($('#list')[0]);
      });
    });
    return describe('indent && outdent', function() {
      var setRange;
      setRange = function(ele) {
        var range;
        ele = ele[0];
        range = document.createRange();
        range.setStart(ele, 0);
        range.setEnd(ele, 1);
        editor.focus();
        return editor.selection.selectRange(range);
      };
      it('pre', function() {
        var text;
        setRange($('pre'));
        text = $('#code').text();
        editor.util.indent();
        return expect($('#code').text()).toBe('\u00A0\u00A0' + text);
      });
      it('li', function() {
        setRange($('#list-item-1'));
        editor.util.indent();
        expect($('#list-item-1').parent().attr('id')).toBe('list');
        setRange($('#list-item-2'));
        editor.util.indent();
        expect($('#list-item-2').parent().parent().attr('id')).toBe('list-item-1');
        setRange($('#list-item-2'));
        editor.util.outdent();
        return expect($('#list-item-2').parent().attr('id')).toBe('list');
      });
      it('p', function() {
        setRange($('#para'));
        editor.util.indent();
        expect($('#para').attr('data-indent')).toBe('3');
        setRange($('#para'));
        editor.util.outdent();
        return expect($('#para').attr('data-indent')).toBe('2');
      });
      return it('table', function() {});
    });
  });

  describe('Formatter', function() {
    it('_init', function() {
      return expect(editor.formatter.editor).toBe(editor);
    });
    describe('autolink', function() {
      return it('autolink', function() {
        var tpl;
        tpl = '<p>http://www.test.com</p>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.autolink();
        return expect(editor.body.find('a').length).toBe(1);
      });
    });
    describe('cleanNode', function() {
      it('\\r\\n node', function() {
        var tpl;
        tpl = '<p id="para">\ntest</p>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.cleanNode(editor.body, true);
        return expect(editor.body.find('p').text()).toBe('test');
      });
      it('img in a', function() {
        var tpl;
        tpl = '<a><img src="" alt="BlankImg"/></a>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.cleanNode(editor.body, true);
        return expect(editor.body.find('a').length).toBe(0);
      });
      xit('img is uploading', function() {
        var tpl;
        tpl = '<img src="" alt="BlankImg" class="uploading"/>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.cleanNode(editor.body, true);
        return expect(editor.body.find('img').length).toBe(1);
      });
      it(':empty typical node', function() {
        var tpl;
        tpl = '<div></div>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.cleanNode(editor.body, true);
        return expect(editor.body.find('div').length).toBe(0);
      });
      return xit('table node', function() {});
    });
    describe('format', function() {
      return it('<br />', function() {
        var tpl;
        editor.body.empty();
        tpl = '<br/><br/><br/><br/>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.format();
        return expect(editor.body.find('br').length).toBe(0);
      });
    });
    it('clearHtml', function() {
      var html;
      html = '<p>test</p>';
      return expect(editor.formatter.clearHtml(html)).toBe('test');
    });
    return it('beautify', function() {
      var tpl;
      editor.body.empty();
      tpl = '<p></p><img></img><p><br/></p>';
      tpl = $(tpl);
      tpl.appendTo('.simditor-body');
      editor.body.empty();
      editor.formatter.beautify(editor.body);
      return expect(editor.body.children().length).toBe(0);
    });
  });

  describe('UndoManager', function() {
    it('_init', function() {
      return expect(editor.undoManager.editor).toBe(editor);
    });
    describe('caret position', function() {
      it('_getNodeOffset', function() {});
      it('_getNodePosition', function() {});
      it('_getNodeByPosition', function() {});
      return it('caretPosition', function() {});
    });
    return it('_pushUndoState', function() {
      var tpl;
      editor.body.empty();
      tpl = '<p>test</p>';
      tpl = $(tpl);
      tpl.appendTo('.simditor-body');
      editor.undoManager._pushUndoState();
      return expect(editor.undoManager._stack[0].html).toBe('<p>test</p>');
    });
  });

}).call(this);
