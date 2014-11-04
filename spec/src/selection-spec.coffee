describe 'Simditor Selection Module', ->
  editor = null
  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
    tmp = '''
    <p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>
      <p>相比传统的编辑器它的特点是：</p>
        <ul id="list">
          <li id="list-item-1">功能精简，<span id="test-span">加载快速</span></li>
          <li id="list-item-2">输出格式化的标准 HTML</li>
          <li id="list-item-3">每一个功能都有非常优秀的使用体验</li>
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

  compareRange = (range1, range2) ->
    return false unless range1.endContainer? or range2.endContainer?
    return false unless range1.endContainer == range2.endContainer \
      or range1.endOffset == range2.endOffset \
      or range1.startContainer == range2.startContainer \
      or range1.startOffset == rang2.startOffset
    true

  setRange = (ele1, offset1, ele2, offset2) ->
    ele1 = ele1[0]
    ele2 = ele2[0]
    range = document.createRange()
    range.setStart ele1, offset1
    range.setEnd ele2, offset2
    editor.focus()
    editor.selection.selectRange range

  it 'can set range and get range', ->
    tmp = $('<p id="test1">this is <b id="test2">test</b> text</p>').appendTo '.simditor-body'
    range = document.createRange();
    range.setStart $('#test1')[0], 0
    range.setEnd $('#test2')[0], 0
    editor.focus()
    editor.selection.selectRange range

    expect(compareRange(editor.selection.getRange(), range)).toBe(true)
    editor.selection.clear()
    expect(editor.selection.getRange()).toBe(null)

  it 'can set range end after a node', ->
    setRange($('#test-span'), 0, $('#list-item-2').contents(), 4)
    editor.selection.setRangeAfter $('#list-item-3')
    expect(editor.selection.getRange().startOffset).toBe(6)

  it 'can set range start before a node', ->
    setRange($('#test-span'), 0, $('#list-item-2').contents(), 4)
    editor.selection.setRangeBefore $('#list-item-1')
    expect(editor.selection.getRange().startOffset).toBe(1)

  it 'can set range at start of a nope', ->
    setRange($('#test-span'), 0, $('#list-item-2').contents(), 4)
    editor.selection.setRangeAtStartOf $('#list-item-1')
    expect(editor.selection.getRange().endContainer).toBe($('#list-item-1')[0])

  it 'can set range at end of a node', ->
    setRange($('#test-span'), 0, $('#list-item-2').contents(), 4)
    editor.selection.setRangeAtEndOf $('#list-item-2')
    expect(editor.selection.getRange().endContainer).toBe($('#list-item-2')[0])

  it 'can judge range whether it\'s at start or end of a node', ->
    range = document.createRange()
    range.setStart($('#test-span')[0], 0)
    range.collapse()
    expect(editor.selection.rangeAtStartOf($('#test-span')[0], range)).toBeTruthy()

    range = document.createRange()
    range.setEnd($('#test-span')[0], 1)
    range.collapse false
    expect(editor.selection.rangeAtEndOf($('#test-span')[0], range)).toBeTruthy()