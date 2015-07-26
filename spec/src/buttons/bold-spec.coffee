describe 'Simditor bold button', ->
  editor = null
  beforeEach ->
    editor = spec.generateSimditor
      content: '''
        <p>bold text</p>
      '''
      toolbar: ['bold']


  afterEach ->
    spec.destroySimditor()
    editor = null

  it 'should set selection bold after clicking', ->
    editor.focus()

    $button = editor.toolbar.list.find('.toolbar-item-bold')
    expect($button.length).toBe(1)

    $p = editor.body.find 'p:first'
    $text = $p.contents().first()
    range = document.createRange()
    range.setStart($text[0], 0)
    range.setEnd($text[0], 4)
    editor.selection.range range
    $button.mousedown()

    $b = $p.find('b')
    expect($b.length).toBe(1)
    expect($b.text()).toBe('bold')

  it 'should be active when selection inside b tag', ->
    editor.setValue '''
      <p><b>bold</b> text</p>
    '''
    editor.focus()

    $b = editor.body.find 'b'
    range = document.createRange()
    range.setStart $b[0], 1
    range.setEnd $b[0], 1
    editor.selection.range range
    editor.trigger 'selectionchanged'

    $button = editor.toolbar.list.find('.toolbar-item-bold')
    button = $button.data 'button'
    expect(button.active).toBe(true)
