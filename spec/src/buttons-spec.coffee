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
    '''

    $textarea = $('<textarea id="editor"></textarea>')
      .val(content)
      .appendTo 'body'
    editor = new Simditor
      textarea: $textarea
      toolbar: ['bold','title',  'italic', 'underline', 'strikethrough', 'color', 'ol', 'ul', 'blockquote', 'code', 'table', 'link', 'image', 'hr', 'indent', 'outdent']

  afterEach ->
    jasmine.clock().uninstall()
    editor.destroy()
    editor = null
    $textarea.remove()
    $textarea = null

  it 'should set selection bold after clicking bold button', ->
    editor.focus()
    jasmine.clock().tick(100)

    $p = editor.body.find 'p:first'
    $button = editor.toolbar.list.find('.toolbar-item-bold')
    expect($button).toExist()


    $text = $p.contents().first()
    range = editor.selection.getRange()
    range.setStart($text[0], 0)
    range.setEnd($text[0], 8)
    editor.selection.selectRange range
    $button.mousedown()
    expect(editor.body.find('b')).toExist()

