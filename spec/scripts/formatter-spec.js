(function() {
  describe('Formatter', function() {
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
    describe('_init method', function() {
      return it('should link editor\'s instance', function() {
        return expect(editor.formatter.editor).toBe(editor);
      });
    });
    describe('autolink method', function() {
      return it('should transform link text node to a tag', function() {
        var tpl;
        editor.body.empty();
        tpl = '<p>http://www.test.com</p>\n<p>https://www.test.com</p>\n<p>www.test.com</p>\n<p>http://test.com</p>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.autolink();
        expect(editor.body).toContainHtml('<a href="http://www.test.com" rel="nofollow">http://www.test.com</a>');
        return expect(editor.body).toContainHtml('<a href="https://www.test.com" rel="nofollow">https://www.test.com</a>');
      });
    });
    describe('cleanNode', function() {
      describe('should clean tags which\' is not allowed', function() {
        it('should remove not allowed tags', function() {
          var tpl;
          tpl = '<script>var x = 1;</script>';
          tpl = $(tpl);
          tpl.appendTo('.simditor-body');
          editor.formatter.cleanNode(editor.body, true);
          return expect(editor.body.find('script')).not.toExist();
        });
        return it('remove replace empty node of div, artical... by br', function() {
          var tpl;
          tpl = '<div></div>';
          tpl = $(tpl);
          tpl.appendTo('.simditor-body');
          editor.formatter.cleanNode(editor.body, true);
          expect(editor.body.find('div')).not.toExist();
          return expect(editor.body.find('br')).toExist();
        });
      });
      it('should remove unallowed attributes', function() {
        var tpl;
        tpl = '<p id="test">Not empty</p>\n<a on-click="return false;">Not empty</a>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.cleanNode(editor.body, true);
        expect(editor.body.find('p')).not.toHaveAttr('id');
        return expect(editor.body.find('a')).not.toHaveAttr('on-click');
      });
      it('should remove empty node with \\r\\n', function() {
        var tpl;
        tpl = '<p id="para">\ntest</p>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.cleanNode(editor.body, true);
        return expect(editor.body.find('p').text()).toBe('test');
      });
      it('should prevent img tag in a tag', function() {
        var tpl;
        tpl = '<a><img src="" alt="BlankImg"/></a>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.cleanNode(editor.body, true);
        return expect(editor.body.find('a')).not.toExist();
      });
      return it('shouldn\'t remove img tag being uploading', function() {
        var tpl;
        tpl = '<img src="" alt="BlankImg" class="uploading"/>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.cleanNode(editor.body, true);
        return expect(editor.body.find('img')).toExist();
      });
    });
    describe('format method', function() {
      it('clean all direct child br tag', function() {
        var tpl;
        editor.body.empty();
        tpl = '<br/>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.format();
        return expect(editor.body.find('br').length).toBe(0);
      });
      it('remove inline ele to p', function() {
        var tpl;
        editor.body.empty();
        tpl = '<span>Hello</span>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.format();
        return expect(editor.body).toContainHtml('<p>Hello</p>');
      });
      return it('remove li inline ele to p', function() {
        var tpl;
        editor.body.empty();
        tpl = '<li>list-item-1</li>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.formatter.format();
        return expect(editor.body).toContainHtml('<ul><li>list-item-1</li></ul>');
      });
    });
    describe('clearHtml method', function() {
      it('should clean html tag with \\n when lineBreak on', function() {
        var html;
        html = '<p>this is</p><p>test</p>';
        return expect(editor.formatter.clearHtml(html)).toBe('this is\ntest');
      });
      return it('should clean html tag without \\n when lineBreak off', function() {
        var html;
        html = '<p>this is </p><p>test</p>';
        return expect(editor.formatter.clearHtml(html, false)).toBe('this is test');
      });
    });
    return describe('beautify', function() {
      return it('should remove empty nodes and useless paragraph', function() {
        var tpl;
        editor.body.empty();
        tpl = '<p></p>\n<p><br/></p>\n<img src="" alt=""/>';
        tpl = $(tpl);
        tpl.appendTo('.simditor-body');
        editor.body.empty();
        editor.formatter.beautify(editor.body);
        expect(editor.body.find('p')).not.toExist();
        return expect(editor.body.find('img')).not.toExist();
      });
    });
  });

}).call(this);
