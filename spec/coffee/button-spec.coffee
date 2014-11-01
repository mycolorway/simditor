describe 'Simditor Button Module', ->
  editor = null
  toolbar = ['bold','title',  'italic', 'underline', 'strikethrough', 'color', 'ol', 'ul', 'blockquote', 'code', 'table', 'link', 'image', 'hr', 'indent', 'outdent']
  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
      toolbar: toolbar

    tmp = '''
    <p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>
    <p id="para2">相比传统的编辑器它的特点是：</p>
    <ul id="list">
      <li>功能精简，加载快速</li>
      <li id="list-item-2">输出格式化的标准<span id="test-span"> HTML </span></li>
      <li>每一个功能都有非常优秀的使用体验</li>
    </ul>
    <pre id="code">this is a code snippet</pre>
    <p id="para3">兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>
    <blockquote>
        <p id="blockquote-first-line">First line</p>
        <p id="blockquote-last-line"><br/></p>
    </blockquote>
    <hr/>
    <p id="after-hr">After hr</p>
    '''
    tmp = $(tmp)
    tmp.appendTo '.simditor-body'
    editor.sync()

  afterEach ->
    editor?.destroy()
    $('#test').remove()

  setRange = (ele, offsetStart, offsetEnd) ->
    ele = ele[0]
    range = document.createRange()
    unless offset
      offset = 0
    range.setStart ele, offsetStart
    range.setEnd ele, offsetEnd
    editor.focus()
    editor.selection.selectRange range

  findButtonLink = (name) ->
    buttonLink = editor.toolbar.list.find('a.toolbar-item-' + name)
    buttonLink ? null

  triggerShortCut = (key, ctrl, shift) ->
    e = $.Event('keydown', {keyCode: key, which: key, shiftKey: shift?})
    if editor.util.os.mac
      e.metaKey = ctrl?
    else
      e.ctrlKey = ctrl?
    editor.body.trigger e

  #TODO add button spec
  describe 'bold button', ->
    it 'should let content bold when clicked', ->
      setRange($('#para2'), 0, 1)
      findButtonLink('bold').trigger 'mousedown'
      expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('b')

    it 'should has shortcut for ctrl + b', ->
      spyEvent = spyOnEvent(findButtonLink('bold'), 'mousedown')
      setRange($('#para2'), 0, 1)
      triggerShortCut(66, true)
      expect(spyEvent).toHaveBeenTriggered()

  describe 'italic button', ->
    it 'should let content italic when clicked', ->
      setRange($('#para2'), 0, 1)
      findButtonLink('italic').trigger 'mousedown'
      expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('i')

    it 'should has shortcut for ctrl + i', ->
      spyEvent = spyOnEvent(findButtonLink('italic'), 'mousedown')
      setRange($('#para2'), 0, 1)
      triggerShortCut(73, true)
      expect(spyEvent).toHaveBeenTriggered()

  describe 'underline button', ->
    it 'should let content underline when clicked', ->
      setRange($('#para2'), 0, 1)
      findButtonLink('underline').trigger 'mousedown'
      expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('u')

    it 'should has shortcut for ctrl + u', ->
      spyEvent = spyOnEvent(findButtonLink('underline'), 'mousedown')
      setRange($('#para2'), 0, 1)
      triggerShortCut(85, true)
      expect(spyEvent).toHaveBeenTriggered()

  describe 'strikethrough button', ->
    it 'should let content strike when clicked', ->
      setRange($('#para2'), 0, 1)
      findButtonLink('strikethrough').trigger 'mousedown'
      expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('strike')

  describe 'indent button', ->
    it 'should let content indent when clicked', ->
      setRange($('#para2'), 0, 1)
      #will call util.indent
      findButtonLink('indent').trigger 'mousedown'
      expect(editor.selection.getRange().commonAncestorContainer).toHaveAttr('data-indent', '1')

  describe 'outdent button', ->
    it 'should let content outdent when clicked', ->
      setRange($('#para2'), 0, 1)
      findButtonLink('indent').trigger 'mousedown'
      findButtonLink('outdent').trigger 'mousedown'
      expect(editor.selection.getRange().commonAncestorContainer).toHaveAttr('data-indent', '0')

  describe 'hr button', ->
    it 'should insert a hr when clicked', ->
      setRange($('#para2'), 0, 1)
      findButtonLink('hr').trigger 'mousedown'
      expect(editor.selection.getRange().commonAncestorContainer.nextSibling).toEqual('hr')
