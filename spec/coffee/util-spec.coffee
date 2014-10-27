describe 'Util', ->
  editor = null
  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
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
    editor.sync()

  afterEach ->
    editor?.destroy()
    $('#test').remove()

  describe '_init method', ->
    it 'should link editor\'s instance', ->
      expect(editor.util.editor).toBe(editor)

  describe 'closestBlockEl && furthestBlockEl method', ->
    it 'should find the closet|furthest Block element', ->
      expect(editor.util.closestBlockEl($('#list-item-1'))[0]).toBe($('#list-item-1')[0])
      expect(editor.util.furthestBlockEl($('#list-item-1'))[0]).toBe($('#list')[0])

  describe 'indent && outdent method', ->
    setRange = (ele) ->
      ele = ele[0]
      range = document.createRange()
      range.setStart ele, 0
      range.setEnd ele, 1
      editor.focus()
      editor.selection.selectRange range

    it 'pre tag should indent & outdent correctly', ->
      setRange $('pre')
      text = $('#code').text()
      editor.util.indent()
      expect($('#code').text()).toBe('\u00A0\u00A0' + text)

      editor.util.outdent()
      expect($('#code').text()).toBe(text)

    it 'list tag should indent & outdent correctly', ->
      setRange $('#list-item-1')
      editor.util.indent()
      expect($('#list-item-1').parent().attr('id')).toBe('list')

      setRange $('#list-item-2')
      editor.util.indent()
      expect($('#list-item-2').parent().parent().attr('id')).toBe('list-item-1')

      setRange $('#list-item-2')
      editor.util.outdent()
      expect($('#list-item-2').parent().attr('id')).toBe('list')

    it 'p(h1 h2..) tag should indent & outdent correctly', ->
      setRange $('#para')
      editor.util.indent()
      expect($('#para').attr('data-indent')).toBe('3')

      setRange $('#para')
      editor.util.outdent()
      expect($('#para').attr('data-indent')).toBe('2')

    it 'table', ->
      #TODO: add spec