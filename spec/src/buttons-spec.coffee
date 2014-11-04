describe 'Simditor Buttons Module', ->
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
      <li id="list-item-1">功能精简，加载快速</li>
      <li id="list-item-2">输出格式化的标准<span id="test-span"> HTML </span></li>
      <li id="list-item-3">每一个功能都有非常优秀的使用体验</li>
    </ul>
    <pre id="code">this is a code snippet</pre>
    <p id="para3">兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>
    <blockquote>
        <p id="blockquote-first-line">First line</p>
        <p id="blockquote-last-line"><br/></p>
    </blockquote>
    <hr/>
    <p id="after-hr">After hr</p>
    <p id="link">test</p>
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

  it 'should let content bold when bold button clicked or by shortcut', ->
    setRange($('#para2'), 0, 1)
    findButtonLink('bold').trigger 'mousedown'
    expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('b')

    spyEvent = spyOnEvent(findButtonLink('bold'), 'mousedown')
    setRange($('#para2'), 0, 1)
    triggerShortCut(66, true)
    expect(spyEvent).toHaveBeenTriggered()

  it 'should let content italic when italic button clicked or by shortcut', ->
    setRange($('#para2'), 0, 1)
    findButtonLink('italic').trigger 'mousedown'
    expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('i')

    spyEvent = spyOnEvent(findButtonLink('italic'), 'mousedown')
    setRange($('#para2'), 0, 1)
    triggerShortCut(73, true)
    expect(spyEvent).toHaveBeenTriggered()

  it 'should let content underline when underline button clicked or by shortcut', ->
    setRange($('#para2'), 0, 1)
    findButtonLink('underline').trigger 'mousedown'
    expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('u')

    spyEvent = spyOnEvent(findButtonLink('underline'), 'mousedown')
    setRange($('#para2'), 0, 1)
    triggerShortCut(85, true)
    expect(spyEvent).toHaveBeenTriggered()

  it 'should let content strike when strikethrough button clicked', ->
    setRange($('#para2'), 0, 1)
    findButtonLink('strikethrough').trigger 'mousedown'
    expect(editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('strike')

  it 'should let content indent when indent button clicked', ->
    setRange($('#para2'), 0, 1)
    #will call util.indent
    findButtonLink('indent').trigger 'mousedown'
    expect(editor.selection.getRange().commonAncestorContainer).toHaveAttr('data-indent', '1')

  it 'should let content outdent when  outdent button clicked', ->
    setRange($('#para2'), 0, 1)
    findButtonLink('indent').trigger 'mousedown'
    findButtonLink('outdent').trigger 'mousedown'
    expect(editor.selection.getRange().commonAncestorContainer).toHaveAttr('data-indent', '0')

  it 'should insert a hr when hr button clicked', ->
    setRange($('#para2'), 0, 1)
    findButtonLink('hr').trigger 'mousedown'
    expect(editor.selection.getRange().commonAncestorContainer.nextSibling).toEqual('hr')

  it 'should change content color when color button clicked', ->
    setRange($('#para2'), 0, 1)
    expect(editor.toolbar.wrapper.find('.color-list')).not.toBeVisible()
    findButtonLink('color').trigger 'mousedown'
    expect(editor.toolbar.wrapper.find('.color-list')).toBeVisible()

    editor.toolbar.wrapper.find('.font-color-1').click()
    expect($ editor.selection.getRange().commonAncestorContainer.parentNode).toEqual('font[color]')

  it 'should let content be title when title button clicked', ->
    setRange($('#para2'), 0, 0)
    findButtonLink('title').trigger 'mousedown'
    editor.toolbar.wrapper.find('.menu-item-h1').click()
    expect($ editor.selection.getRange().commonAncestorContainer).toEqual('h1')

  it 'should create list when list button clicked', ->
    setRange = (ele1, offset1, ele2, offset2) ->
      unless ele2
        ele2 = ele1
        offset2 = offset1
      ele1 = ele1[0]
      ele2 = ele2[0]
      range = document.createRange()
      range.setStart ele1, offset1
      range.setEnd ele2, offset2
      editor.focus()
      editor.selection.selectRange range

    #UnorderedList
    #click on collapsed range
    setRange($('#para2'), 0)
    findButtonLink('ul').trigger 'mousedown'
    parentNode = $ editor.selection.getRange().commonAncestorContainer
    expect(parentNode).toEqual('li')
    expect(parentNode.parent()).toBeMatchedBy('ul')

    #click again to toggle list
    findButtonLink('ul').trigger 'mousedown'
    parentNode = $ editor.selection.getRange().commonAncestorContainer
    expect(parentNode).toEqual('p')

    #click on a range of nodes
    setRange($('#list-item-1'), 0, $('#list-item-3'), 1)
    findButtonLink('ul').trigger 'mousedown'
    parentNode = $ editor.selection.getRange().commonAncestorContainer
    expect(parentNode).not.toEqual('ul')
    expect(parentNode.find('li')).not.toExist()

    findButtonLink('ul').trigger 'mousedown'
    parentNode = $ editor.selection.getRange().commonAncestorContainer
    expect(parentNode).toEqual('ul')
    expect(parentNode.find('li').length).toBe(3)

    #shortcut
    spyEvent = spyOnEvent(findButtonLink('ul'), 'mousedown')
    triggerShortCut(190, true)
    expect(spyEvent).toHaveBeenTriggered()

    spyEvent2 = spyOnEvent(findButtonLink('ol'), 'mousedown')
    triggerShortCut(191, true)
    expect(spyEvent2).toHaveBeenTriggered()

    #OL is same to UL, no need to test again

  #TODO add link, code, image
