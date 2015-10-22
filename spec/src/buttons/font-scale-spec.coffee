describe 'Simditor fontScale button', ->
  editor = null
  beforeEach ->
    editor = spec.generateSimditor
      content: '''
        <p>hello font scale</p>
      '''
      toolbar: ['fontScale']


  afterEach ->
    spec.destroySimditor()
    editor = null

  it 'should set selection font scaled after click menu', ->
    editor.focus()

    $p = editor.body.find 'p:first'
    $text = $p.contents().first()
    range = document.createRange()
    range.setStart($text[0], 0)
    range.setEnd($text[0], 10)
    editor.selection.range range
    editor.inputManager.focused = true
    editor.trigger 'selectionchanged'

    button = editor.toolbar.findButton('fontScale')
    button.menuEl.find('.menu-item:first').click()

    $span = $p.find('span[style*="font-size"]')
    expect($span.length).toBe(1)
    expect($span.text()).toBe('hello font')

  it 'should be active when selection inside font size tag', ->
    editor.setValue '''
      <p><span style="font-size: 1.5em;">hello font</span> scale</p>
    '''
    editor.focus()

    $span = editor.body.find 'span[style*="font-size"]'
    range = document.createRange()
    range.setStart $span[0], 1
    range.setEnd $span[0], 1
    editor.selection.range range
    editor.inputManager.focused = true
    editor.trigger 'selectionchanged'

    button = editor.toolbar.findButton('fontScale')
    expect(button.active).toBe(true)
