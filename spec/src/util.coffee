
window.spec =
  generateSimditor: ->
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
    new Simditor
      textarea: $textarea
      toolbar: [
        'bold', 'alignment', 'code', 'table'
      ]

  destroySimditor: ->
    $textarea = $('#editor')
    editor = $textarea.data 'simditor'
    editor?.destroy()
    $textarea.remove()
