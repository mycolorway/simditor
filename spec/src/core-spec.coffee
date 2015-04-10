describe 'A Simditor instance', ->
  editor = null
  beforeEach ->
    editor = spec.generateSimditor()

  afterEach ->
    spec.destroySimditor()
    editor = null

  it 'should render specific layout', ->
    $simditor = $('.simditor')
    expect($simditor).toExist()
    expect($simditor.find('> .simditor-wrapper > .simditor-body')).toExist()
    expect($simditor.find('> .simditor-wrapper > .simditor-placeholder')).toExist()
    expect($simditor.find('> .simditor-wrapper > textarea#editor')).toExist()

    expect(editor.el).toHaveClass('simditor')
    expect(editor.body).toHaveClass('simditor-body')
    expect(editor.wrapper).toHaveClass('simditor-wrapper')

  it 'should reset to default after destroyed', ->
    editor?.destroy()
    expect($('.simditor')).not.toExist()
    expect($('textarea#editor')).toExist()

  it 'should set formatted value to editor\'s body by calling setValue', ->
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

  it 'should focus on editor\'s body when call focus and blur when call blue', ->
    editor.focus()
    expect(editor.body).toBeFocused()
    editor.blur()
    expect(editor.body).not.toBeFocused()
