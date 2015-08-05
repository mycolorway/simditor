describe 'A Simditor instance', ->
  editor = null
  beforeEach ->
    editor = spec.generateSimditor()

  afterEach ->
    spec.destroySimditor()
    editor = null

  it 'should render specific layout', ->
    $simditor = $('.simditor')
    expect($simditor.length).toBe(1)
    expect($simditor.find('> .simditor-wrapper > .simditor-body').length)
      .toBe(1)
    expect($simditor.find('> .simditor-wrapper > .simditor-placeholder').length)
      .toBe(1)
    expect($simditor.find('> .simditor-wrapper > textarea#editor').length)
      .toBe(1)

    expect(editor.el.is('.simditor')).toBe(true)
    expect(editor.body.is('.simditor-body')).toBe(true)
    expect(editor.wrapper.is('.simditor-wrapper')).toBe(true)

  it 'should reset to default after destroyed', ->
    $textarea = $('textarea#editor')
    editor?.destroy()
    expect($('.simditor').length).toBe(0)
    expect($textarea.length).toBe(1)
    expect($textarea.data('simditor')).toBeUndefined()

  it 'should set formatted value to editor\'s body after calling setValue', ->
    tmpHtml = '''
      <p id="flag">test format</p>
    '''
    editor.setValue(tmpHtml)
    expect($.trim(editor.body.html())).toBe('<p>test format</p>')

  it 'should get formatted editor\'s value by calling getValue', ->
    tmpHtml = '''
      <p id="flag">test format</p>
    '''
    editor.body.html(tmpHtml)
    expect(editor.getValue()).toBe('<p>test format</p>')

  it 'should lose focus after calling blur', ->
    editor.focus()
    editor.blur()
    expect(document.activeElement).not.toBe(editor.body[0])
    expect(editor.selection.range()).toBe(null)
    expect(editor.inputManager.focused).toBe(false)
