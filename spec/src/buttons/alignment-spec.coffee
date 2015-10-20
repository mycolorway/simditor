describe 'Simditor alignment button', ->
  editor = null
  $p1 = null
  $p2 = null

  beforeEach ->
    editor = spec.generateSimditor
      content: '''
        <p>paragraph 1</>
        <p>paragraph 2</>
      '''
      toolbar: ['alignment']
    editor.focus()

    $p = editor.body.find('> p')
    $p1 = $p.first()
    $p2 = $p.eq(1)
    range = document.createRange()
    editor.selection.setRangeAtEndOf $p2, range
    range.setStart $p1[0], 0
    editor.selection.range range
    editor.inputManager.focused = true
    editor.trigger 'selectionchanged'

  afterEach ->
    spec.destroySimditor()
    editor = null

  it "can align to right", ->
    leftValues = ['left', 'start', '-moz-left', '-webkit-auto']
    expect(leftValues).toContain($p1.css('text-align'))
    expect(leftValues).toContain($p2.css('text-align'))
    button = editor.toolbar.list.find('.toolbar-item-alignment').data 'button'
    button.command "right"
    expect($p1.css('text-align')).toBe('right')
    expect($p2.css('text-align')).toBe('right')
    expect(button.el.hasClass('active')).toBe(true)
    expect(button.el.hasClass('align-right')).toBe(true)

  it "can align to center", ->
    button = editor.toolbar.list.find('.toolbar-item-alignment').data 'button'
    button.command "center"
    expect($p1.css('text-align')).toBe('center')
    expect($p2.css('text-align')).toBe('center')
    expect(button.el.hasClass('active')).toBe(true)
    expect(button.el.hasClass('align-center')).toBe(true)

  it "can align to left", ->
    leftValues = ['left', 'start', '-moz-left', '-webkit-auto']
    button = editor.toolbar.list.find('.toolbar-item-alignment').data 'button'
    button.command "left"
    expect(leftValues).toContain($p1.css('text-align'))
    expect(leftValues).toContain($p2.css('text-align'))
    expect(button.el.hasClass('active')).toBe(false)
    expect(button.el.hasClass('align-left')).toBe(true)
