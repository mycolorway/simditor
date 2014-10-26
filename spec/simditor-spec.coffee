editor = null
beforeEach ->
  $('<textarea id="test"></textarea>').appendTo 'body'
  editor = new Simditor
    textarea: '#test'
afterEach ->
  editor?.destroy()
  $('#test').remove()

describe 'Core', ->
  describe '_init & destroy method', ->
    it 'should render DOM', ->
      expect($('.simditor').length).toBe(1)
      editor.destroy()
      expect($('.simditor').length).toBe(0)

  describe 'setValue  && getValue && sync method', ->
    it 'should set correct value', ->
      editor.setValue('Hello, world!')
      expect($('#test').val()).toBe('Hello, world!')
      #getValue method called sync method
      expect(editor.getValue()).toBe('<p>Hello, world!</p>')

  describe 'focus && blur method', ->
    it 'should focus on editor', ->
      $('<input id="tmp"></input>').appendTo 'body'
      $('#tmp').focus()
      expect(document.activeElement.id).toBe('tmp')
      editor.focus()
      expect(document.activeElement.className).toBe('simditor-body')
      editor.blur()
      expect(document.activeElement).not.toBe('simditor-body')
      $('#tmp').remove()

  describe 'hidePopover method', ->

describe 'Selection', ->
  it '_init method', ->
    expect(editor.selection.editor).toBe(editor)
    expect(editor.selection.sel).toBe(document.getSelection())

  describe 'selectRange && getRange', ->
    it 'should perform well', ->
      tmp = $('<p id="test1">this is <b id="test2">test</b> text</p>').appendTo '.simditor-body'
      range = document.createRange();
      range.setStart $('#test1')[0], 0
      range.setEnd $('#test2')[0], 0
      editor.focus()
      editor.selection.selectRange range
      #range not support equal
      expect(editor.selection.getRange().toString() == range.toString()).toBe(true)
      editor.selection.clear()
      expect(editor.selection.getRange()).toBe(null)
      tmp.remove()


  describe 'insert and set method', ->
    beforeEach ->
      tmp = $('<p id="test1">this <b id="test2">is</b> <b id="test3">test</b>text</p>')
      .appendTo '.simditor-body'
      range = document.createRange()
      range.setStart $('#test1')[0], 0
      range.setEnd $('#test2')[0], 0
      editor.focus()
      editor.selection.selectRange range

    xit 'should insert text node', ->
      editor.selection.insertNode(document.createTextNode 'test')
      expect(editor.selection.getRange().innerHTML).toBe('nodethis is test text')

    it 'setRangeAfter', ->
      editor.selection.setRangeAfter $('#test3')
      expect(editor.selection.getRange().startOffset).toBe(4)

    it 'setRangeBefore', ->
      editor.selection.setRangeBefore $('#test3')
      expect(editor.selection.getRange().startOffset).toBe(3)

    it 'setRangeAtStartOf', ->
      editor.selection.setRangeAtStartOf $('#test3')
      expect(editor.selection.getRange().endContainer).toBe($('#test3')[0])

    it 'setRangeAtEndOf', ->
      #TODO: Add more example
      editor.selection.setRangeAtEndOf $('#test3')
      expect(editor.selection.getRange().endContainer).toBe($('#test3')[0])

  describe 'save and restore', ->
    #TODO: add spec


describe 'Util', ->
  it '_init method', ->
    expect(editor.util.editor).toBe(editor)

  beforeEach ->
    tmp = '''
        <p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>
          <p>相比传统的编辑器它的特点是：</p>
            <ul id="list">
              <li id="list-item-1">功能精简，加载快速</li>
              <li id="list-item-2">输出格式化的标准 HTML</li>
              <li>每一个功能都有非常优秀的使用体验</li>
            </ul>
            <pre id="code">"this is a code snippet"</pre>
          <p data-indent="2" id="para">兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>
    '''
    tmp = $(tmp)
    tmp.appendTo '.simditor-body'

  describe 'is Empty && Block method', ->
    it 'should return right answer', ->
      node = $('<h4></h4>').appendTo '.simditor-body'
      expect(editor.util.isEmptyNode(node)).toBe(true)
      node.remove()

  describe 'find_el_method', ->
    it 'closet && furthest BlockNode', ->
      expect(editor.util.closestBlockEl($('#list-item-1'))[0]).toBe($('#list-item-1')[0])
      expect(editor.util.furthestBlockEl($('#list-item-1'))[0]).toBe($('#list')[0])

  describe 'indent && outdent', ->
    setRange = (ele) ->
      ele = ele[0]
      range = document.createRange()
      range.setStart ele, 0
      range.setEnd ele, 1
      editor.focus()
      editor.selection.selectRange range

    it 'pre', ->
      setRange $('pre')
      text = $('#code').text()
      editor.util.indent()
      expect($('#code').text()).toBe('\u00A0\u00A0' + text)



    it 'li', ->
      setRange $('#list-item-1')
      editor.util.indent()
      expect($('#list-item-1').parent().attr('id')).toBe('list')

      setRange $('#list-item-2')
      editor.util.indent()
      expect($('#list-item-2').parent().parent().attr('id')).toBe('list-item-1')

      setRange $('#list-item-2')
      editor.util.outdent()
      expect($('#list-item-2').parent().attr('id')).toBe('list')

    it 'p', ->
      setRange $('#para')
      editor.util.indent()
      expect($('#para').attr('data-indent')).toBe('3')

      setRange $('#para')
      editor.util.outdent()
      expect($('#para').attr('data-indent')).toBe('2')

    it 'table', ->
      #TODO: add spec

describe 'Formatter', ->
  it '_init', ->
    expect(editor.formatter.editor).toBe(editor)
  describe 'autolink', ->
    it 'autolink', ->
      tpl = '''
          <p>http://www.test.com</p>
        '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.formatter.autolink()
      expect(editor.body.find('a').length).toBe(1)

  describe 'cleanNode', ->
    it '\\r\\n node', ->
      tpl = '''
        <p id="para">\ntest</p>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.formatter.cleanNode editor.body, true
      expect(editor.body.find('p').text()).toBe('test')

    it 'img in a', ->
      tpl = '''
      <a><img src="" alt="BlankImg"/></a>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.formatter.cleanNode editor.body, true
      expect(editor.body.find('a').length).toBe(0)

    #perhaps it's a BUG
    it 'img is uploading', ->
      tpl = '''
      <img src="" alt="BlankImg" class="uploading"/>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.formatter.cleanNode editor.body, true
      expect(editor.body.find('img').length).toBe(1)

    it ':empty typical node', ->
      tpl = '''
      <div></div>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.formatter.cleanNode editor.body, true
      expect(editor.body.find('div').length).toBe(0)

    xit 'table node', ->
      #TODO add spec

  describe 'format', ->
    it '<br />', ->
      editor.body.empty()
      tpl = '''
      <br/><br/><br/><br/>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'
      editor.formatter.format()
      expect(editor.body.find('br').length).toBe(0)
    #TODO add li

  it 'clearHtml', ->
    html = '<p>test</p>'
    expect(editor.formatter.clearHtml(html)).toBe('test')

  it 'beautify', ->
    editor.body.empty()
    tpl = '''
      <p></p><img></img><p><br/></p>
    '''
    tpl = $(tpl)
    tpl.appendTo '.simditor-body'
    editor.body.empty()
    editor.formatter.beautify(editor.body)
    expect(editor.body.children().length).toBe(0)