describe 'A Simditor Instance', ->
  editor = null
  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
  afterEach ->
    editor?.destroy()
    $('#test').remove()

  it 'should render specific layout', ->
    $simditor = $('.simditor')
    expect($simditor).toExist()
    expect($simditor.find('> .simditor-wrapper > .simditor-body')).toExist()
    expect($simditor.find('> .simditor-wrapper > .simditor-placeholder')).toExist()
    expect($simditor.find('> textarea#test')).toExist()

    expect(editor.el).toHaveClass('simditor')
    expect(editor.body).toHaveClass('simditor-body')
    expect(editor.wrapper).toHaveClass('simditor-wrapper')

  it 'should reset to default when destroyed', ->
    editor.destroy()
    expect($('.simditor')).not.toExist()
    expect($('textarea#test')).toExist()

  it 'should set formatted value to editor\'s body when call setValue', ->
    #formatter.format method will be called
    $textarea = $('.simditor textarea')
    tmpHtml = '''
    <p id="flag">test format</p>
    '''
    editor.setValue(tmpHtml)
    expect(editor.body).toContainHtml('<p>test format</p>')
    #expect($textarea.val()).toBe('<p>test format</p>')

  it 'should get formatted editor\'s value when call getValue', ->
    tmpHtml = '''
    <p id="flag">test format</p>
    '''
    editor.body.empty()
    $(tmpHtml).appendTo editor.body
    expect(editor.getValue()).toBe('<p>test format</p>')

  it 'should focus on editor\'s body when call focus and blur when call blue', ->
    editor.focus()
    expect(editor.body).toBeFocused()
    editor.blur()
    expect(editor.body).not.toBeFocused()


