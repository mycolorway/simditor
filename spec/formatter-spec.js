(function() {
  describe('Simditor Formatter Module', function() {
    var editor;
    editor = null;
    beforeEach(function() {
      return editor = spec.generateSimditor();
    });
    afterEach(function() {
      spec.destroySimditor();
      return editor = null;
    });
    it('can convert url string to anchor element', function() {
      var $p1, $p2, $p3;
      $p1 = editor.formatter.autolink($('<p>http://test.com?x=1</p>'));
      $p2 = editor.formatter.autolink($('<p>http://www.test.net?x=1&y=2</p>'));
      $p3 = editor.formatter.autolink($('<p>http://127.0.0.1:3000/test</p>'));
      expect($p1.html()).toBe('<a href="http://test.com?x=1" rel="nofollow">http://test.com?x=1</a>');
      expect($p2.html()).toBe('<a href="http://www.test.net?x=1&amp;y=2" rel="nofollow">http://www.test.net?x=1&amp;y=2</a>');
      return expect($p3.html()).toBe('<a href="http://127.0.0.1:3000/test" rel="nofollow">http://127.0.0.1:3000/test</a>');
    });
    it('can clean forbidden tags and attributes and modify redundancy tags', function() {
      var $p1, $p2, $p3, $p4, $p5, $p6;
      $p1 = $('<div><p>\r\nthis is a test</p></div>');
      $p2 = $('<div><p id="test">this is a test</p></div>');
      $p3 = $('<div><script>var x = 1;</script></div>');
      $p4 = $('<div><article></article></div>');
      $p5 = $('<div><a href=""><img src="" alt="testImage"></a></div>');
      $p6 = $('<div><img src="" alt="" class="uploading"></div>');
      editor.formatter.cleanNode($p1.contents(), true);
      editor.formatter.cleanNode($p2.contents(), true);
      editor.formatter.cleanNode($p3.contents(), true);
      editor.formatter.cleanNode($p4.contents(), true);
      editor.formatter.cleanNode($p5.contents(), true);
      editor.formatter.cleanNode($p6.contents(), true);
      expect($p1.html()).toBe('<p>this is a test</p>');
      expect($p2.html()).toBe('<p>this is a test</p>');
      expect($p3.html()).toBe('var x = 1;');
      expect($p4.html()).toBe('');
      expect($p5.html()).toBe('<img src="" alt="testImage">');
      return expect($p6.html()).toBe('');
    });
    it('can format all direct children to block node', function() {
      var $p1, $p2, $p3, $p4;
      $p1 = editor.formatter.format($('<div><br/></div>'));
      $p2 = editor.formatter.format($('<div><span>test</span></div>'));
      $p3 = editor.formatter.format($('<div><li>list-item-1</li></div>'));
      $p4 = editor.formatter.format($('<div><li>list-item-1</li><li>list-item-2</li></div>'));
      expect($p1.html()).toBe('');
      expect($p2.html()).toBe('<p>test</p>');
      expect($p3.html()).toBe('<ul><li>list-item-1</li></ul>');
      return expect($p4.html()).toBe('<ul><li>list-item-1</li><li>list-item-2</li></ul>');
    });
    it('can clean html tag', function() {
      var $p1, $p2;
      $p1 = editor.formatter.clearHtml('<p>this is</p><p>test</p>');
      $p2 = editor.formatter.clearHtml('<p>this is </p><p>test</p>', false);
      expect($p1).toBe('this is\ntest');
      return expect($p2).toBe('this is test');
    });
    return it('can remove empty nodes and useless paragraph', function() {
      var $p1, $p2;
      $p1 = $('<div><p></p><p>this is test</p><p><br></p></div>');
      $p2 = $('<div><br/><hr/><img src="" alt=""/></div>');
      editor.formatter.beautify($p1);
      editor.formatter.beautify($p2);
      expect($p1.html()).toBe('<p>this is test</p><p><br></p>');
      return expect($p2.html()).toBe('<br><hr><img src="" alt="">');
    });
  });

}).call(this);
