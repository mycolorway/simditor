describe 'A Simditor instance', ->
  editor = null
  $textarea = null
  beforeEach ->
    jasmine.clock().install()
    content = '''
      <p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>
      <p>相比传统的编辑器它的特点是：</p>
      <ul>
        <li>功能精简，加载快速</li>
        <li>输出格式化的标准 HTML</li>
        <li>每一个功能都有非常优秀的使用体验</li>
      </ul>
      <p>兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>
      <pre>this is a code snippet</pre>
      <blockquote><p>First line</p><p><br/></p></blockquote>
      <hr/>
      <p><br/></p>
    '''

    $textarea = $('<textarea id="editor"></textarea>')
      .val(content)
      .appendTo 'body'
    editor = new Simditor
      textarea: $textarea

  afterEach ->
    jasmine.clock().uninstall()
    editor.destroy()
    editor = null
    $textarea.remove()
    $textarea = null

  triggerKeyStroke = (key, opts = {}) ->
    e = $.Event('keydown', $.extend({which: key}, opts))
    editor.body.trigger e

  it 'should leave blockquote when press return on last line of blockquote', ->
    editor.focus()
    editor.selection.setRangeAtStartOf(editor.body.find('blockquote > p:last'))
    expect(editor.body.find('blockquote > p').length).toBe(2)
    triggerKeyStroke 13
    expect(editor.body.find('blockquote > p').length).toBe(1)

  it 'should delete blockquote when press delete at start of blockquote', ->
    editor.focus()
    jasmine.clock().tick(100)
    editor.selection.setRangeAtStartOf(editor.body.find('blockquote > p:first'))
    expect(editor.body.find('blockquote')).toExist()
    triggerKeyStroke 8
    expect(editor.body.find('blockquote')).not.toExist()

  it 'should remove hr when press delete after hr', ->
    editor.focus()
    jasmine.clock().tick(100)
    editor.selection.setRangeAtStartOf(editor.body.find('p:last'))
    expect(editor.body.find('hr')).toExist()
    triggerKeyStroke 8
    expect(editor.body.find('hr')).not.toExist()

  it 'should indent content when press tab', ->
    editor.focus()
    jasmine.clock().tick(100)
    $p = editor.body.find('p:first')
    editor.selection.setRangeAtStartOf($p)
    expect($p).not.toHaveAttr('data-indent')
    e = $.Event('keydown', {keyCode: 9, which: 9})
    triggerKeyStroke 9
    expect($p.attr('data-indent')).toBe('1')

  it 'should insert \\n by pressing return in code block', ->
    editor.focus()
    jasmine.clock().tick(100)
    $pre = editor.body.find('pre')
    editor.selection.setRangeAtEndOf($pre)
    expect($pre.text().indexOf('\n')).toBe(-1)
    triggerKeyStroke 13
    expect($pre.text().indexOf('\n') > -1).toBe(true)

  it 'should leave code block by pressing shift + return', ->
    editor.focus()
    jasmine.clock().tick(100)
    $pre = editor.body.find('pre')
    editor.selection.setRangeAtEndOf($pre)
    triggerKeyStroke 13, 
      shiftKey: true
    expect(editor.util.closestBlockEl()).not.toBeMatchedBy('pre')

  it 'should delete code block by pressing delete at start of pre', ->
    editor.focus()
    jasmine.clock().tick(100)
    $pre = editor.body.find('pre')
    editor.selection.setRangeAtStartOf($pre)
    triggerKeyStroke 8
    expect(editor.body.find('pre')).not.toExist()

