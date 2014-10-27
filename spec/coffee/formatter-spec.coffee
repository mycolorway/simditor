describe 'Formatter', ->
  editor = null
  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
  afterEach ->
    editor?.destroy()
    $('#test').remove()

  describe '_init method', ->
    it 'should link editor\'s instance', ->
      expect(editor.formatter.editor).toBe(editor)

  describe 'autolink method', ->
    it 'should transform link text node to a tag', ->
      editor.body.empty()
      tpl = '''
          <p>http://www.test.com</p>
          <p>https://www.test.com</p>
          <p>www.test.com</p>
          <p>http://test.com</p>
        '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'

      editor.formatter.autolink()
      expect(editor.body).toContainHtml('<a href="http://www.test.com" rel="nofollow">http://www.test.com</a>')
      expect(editor.body).toContainHtml('<a href="https://www.test.com" rel="nofollow">https://www.test.com</a>')
      #expect(editor.body).toContainHtml('<a href="https://www.test.com" rel="nofollow">https://www.test.com</a>')
      #expect(editor.body).toContainHtml('<a href="https://test.com" rel="nofollow">https://test.com</a>')

  describe 'cleanNode', ->
    describe 'should clean tags which\' is not allowed', ->
      it 'should remove not allowed tags', ->
        tpl = '''
        <script>var x = 1;</script>
        '''
        tpl = $(tpl)
        tpl.appendTo '.simditor-body'
        editor.formatter.cleanNode editor.body, true
        expect(editor.body.find('script')).not.toExist()

      it 'remove replace empty node of div, artical... by br', ->
        tpl = '''
        <div></div>
        '''
        tpl = $(tpl)
        tpl.appendTo '.simditor-body'
        editor.formatter.cleanNode editor.body, true
        expect(editor.body.find('div')).not.toExist()
        expect(editor.body.find('br')).toExist()

      #TODO: add table

    it 'should remove unallowed attributes', ->
      tpl = '''
      <p id="test">Not empty</p>
      <a on-click="return false;">Not empty</a>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.formatter.cleanNode editor.body, true
      expect(editor.body.find('p')).not.toHaveAttr('id')
      expect(editor.body.find('a')).not.toHaveAttr('on-click')

    it 'should remove empty node with \\r\\n', ->
      tpl = '''
        <p id="para">\ntest</p>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.formatter.cleanNode editor.body, true
      expect(editor.body.find('p').text()).toBe('test')

    it 'should prevent img tag in a tag', ->
      tpl = '''
      <a><img src="" alt="BlankImg"/></a>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.formatter.cleanNode editor.body, true
      expect(editor.body.find('a')).not.toExist()

    #perhaps it's a BUG
    it 'shouldn\'t remove img tag being uploading', ->
      tpl = '''
      <img src="" alt="BlankImg" class="uploading"/>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.formatter.cleanNode editor.body, true
      expect(editor.body.find('img')).toExist()

  describe 'format method', ->
    it 'clean all direct child br tag', ->
      editor.body.empty()
      tpl = '''
      <br/>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.formatter.format()
      expect(editor.body.find('br').length).toBe(0)

    it 'remove inline ele to p', ->
      editor.body.empty()
      tpl = '''
      <span>Hello</span>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.formatter.format()
      expect(editor.body).toContainHtml('<p>Hello</p>')

    it 'remove li inline ele to p', ->
      editor.body.empty()
      tpl = '''
      <li>list-item-1</li>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.formatter.format()
      expect(editor.body).toContainHtml('<ul><li>list-item-1</li></ul>')

  describe 'clearHtml method', ->
    it 'should clean html tag with \\n when lineBreak on', ->
      html = '<p>this is</p><p>test</p>'
      expect(editor.formatter.clearHtml(html)).toBe('this is\ntest')

    it 'should clean html tag without \\n when lineBreak off', ->
      html = '<p>this is </p><p>test</p>'
      expect(editor.formatter.clearHtml(html, false)).toBe('this is test')

  describe 'beautify', ->
    it 'should remove empty nodes and useless paragraph', ->
      editor.body.empty()
      tpl = '''
        <p></p>
        <p><br/></p>
        <img src="" alt=""/>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.body.empty()
      editor.formatter.beautify(editor.body)
      expect(editor.body.find('p')).not.toExist()
      expect(editor.body.find('img')).not.toExist()
