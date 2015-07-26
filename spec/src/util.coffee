
window.spec =
  generateSimditor: (opts = {}) ->
    opts.content ||= ''
    opts.toolbar ||= false

    $textarea = $('<textarea id="editor"></textarea>')
      .val(opts.content)
      .appendTo 'body'

    new Simditor
      textarea: $textarea
      toolbar: opts.toolbar

  destroySimditor: ->
    $textarea = $('#editor')
    editor = $textarea.data 'simditor'
    editor?.destroy()
    $textarea.remove()
