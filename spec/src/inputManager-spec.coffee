describe 'A Simditor instance', ->
  editor = null
  $textarea = null
  beforeEach ->
    jasmine.clock().install()
    $textarea = $('<textarea id="editor"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: $textarea

  afterEach ->
    jasmine.clock().uninstall()
    editor?.destroy()
    editor = null
    $textarea.remove()
    $textarea = null

  it 'should render specific layout', ->
    expect(editor.el.find('.simditor-paste-area')).toExist()
    expect(editor.el.find('.simditor-clean-paste-area')).toExist()

  it 'should ensure editor\'s body has content', ->
    editor.body.empty()
    editor.body.focus()
    jasmine.clock().tick(100)

    e = $.Event('keyup', {which: 8, keyCode:8})
    editor.body.trigger e
    expect(editor.body.find('p>br')).toExist()

