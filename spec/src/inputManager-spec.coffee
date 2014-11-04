describe 'Simditor InputManager Module', ->
  editor = null
  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
  afterEach ->
    editor?.destroy()
    $('#test').remove()

  it 'should render specific layout', ->
    expect(editor.el.find('.simditor-paste-area')).toExist()
    expect(editor.el.find('.simditor-clean-paste-area')).toExist()

  it 'can add key stroke to its instance', ->
    tmpCallback = ->
      console.log 'this is a test'
    editor.inputManager.addKeystrokeHandler 13, 'ele', tmpCallback
    expect(editor.inputManager._keystrokeHandlers[13]?['ele']).toBe(tmpCallback)

  it 'should add focus class when editor focus', ->
    spyEvent = spyOnEvent(editor, 'selectionchanged')

    editor.focus()
    expect(editor.el).toHaveClass('focus')
    expect(editor.inputManager.focused).toBeTruthy()

  it 'should remove focus class when editor blur', ->
    editor.focus()
    editor.blur()
    expect(editor.el).not.toHaveClass('focus')
    expect(editor.inputManager.focused).not.toBeTruthy()

  it 'should call shortcut when keydown', ->
    #shortcut
    triggerKey = (key, ctrl, shift) ->
      e = $.Event('keydown', {keyCode: key, which: key, shiftKey: shift?})
      if editor.util.os.mac
        e.metaKey = ctrl?
      else
        e.ctrlKey = ctrl?
      editor.body.trigger e

    editor.focus()
    boldBtn = editor.el.find('a.toolbar-item-bold')
    spyEvent = spyOnEvent(boldBtn, 'mousedown')
    triggerKey(66, true)
    expect(spyEvent).toHaveBeenTriggered()

    #keyStroke
    KeyStrokeCalled = false
    editor.inputManager.addKeystrokeHandler '15', '*', (e, $node) =>
      KeyStrokeCalled = true

    triggerKey 15
    expect(KeyStrokeCalled).toBeTruthy()

    #TODO: add typing

  it 'should ensure editor\' body has content when keyup', ->
    editor.body.empty()
    editor.focus()
    e = $.Event('keyup', {which: 8, keyCode:8})
    editor.body.trigger e
    expect(editor.body.find('p>br')).toExist()

  #TODO: add paste
