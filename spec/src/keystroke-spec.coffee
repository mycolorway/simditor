describe 'Simditor Keystroke Module', ->
  editor = null
  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
    tmp = '''
    <p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>
    <p>相比传统的编辑器它的特点是：</p>
    <pre id="code">this is a code snippet</pre>
    <p id="para3">兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>
    <blockquote>
        <p id="blockquote-first-line">First line</p>
        <p id="blockquote-last-line"><br/></p>
    </blockquote>
    <hr/>
    <p id="after-hr">After hr</p>
    <ol id="list">
      <li id="list-1">list1
        <ol>
          <li id="list1-1">list1-1</li>
          <li id="list1-2">list1-2</li>
        </ol>
      </li>
    </ol>
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

  triggerKeyStroke = (key, shift) ->
    e = $.Event('keydown', {keyCode: key, which: key, shiftKey: shift?})
    editor.body.trigger e

  it 'should leave blockquote when press return on last line of blockquote', ->
    setRange( $('#blockquote-first-line'), 0)
    triggerKeyStroke 13
    expect(editor.body.find('blockquote>#blockquote-first-line')).toExist()
    setRange( $('#blockquote-last-line'), 0)
    triggerKeyStroke 13
    expect(editor.body.find('blockquote>#blockquote-last-line')).not.toExist()

  it 'should delete blockquote when press delete at start of blockquote', ->
    setRange( $('blockquote'), 0)
    triggerKeyStroke 8
    expect(editor.body.find('blockquote')).not.toExist()

  it 'should remove hr when press delete after hr', ->
    expect(editor.body.find('hr')).toExist()
    setRange( $('#after-hr'), 0)
    triggerKeyStroke 8
    expect(editor.body.find('hr')).not.toExist()

  it 'should indent content when press tab', ->
    expect(editor.body.find('#para3')).not.toHaveAttr('data-indent')
    setRange( $('#para3'), 0, 1)
    e = $.Event('keydown', {keyCode: 9, which: 9});
    triggerKeyStroke 9
    expect(editor.body.find('#para3')).toHaveAttr('data-indent')

  it 'should insert \\n in pre when press return', ->
    expect(editor.body.find('#code')).not.toContainText('\n')
    setRange( $('#code').contents(), 1, 4)
    triggerKeyStroke 13
    expect(editor.body.find('#code')).toContainText('\n')

  it 'should leave pre when press shift + return', ->
    setRange( $('#code').contents(), 1, 4)
    triggerKeyStroke 13, true
    expect(editor.selection.getRange().startContainer).not.toHaveClass('#code')

  it 'should delete pre when press delete at start of pre', ->
    setRange( $('#code'), 0, 0)
    triggerKeyStroke 8
    expect(editor.body.find('pre')).not.toExist()

  #TODO: fix li went strange