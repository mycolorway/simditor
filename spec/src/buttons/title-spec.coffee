describe 'Simditor title button', ->
  editor = null
  $p = null

  beforeEach ->
    editor = spec.generateSimditor
      content: '''
        <p>paragraph 1</>
      '''
      toolbar: ['title']
    editor.focus()

    $p = editor.body.find('> p')
    editor.selection.setRangeAtStartOf $p
    editor.inputManager.focused = true
    editor.trigger 'selectionchanged'

  afterEach ->
    spec.destroySimditor()
    editor = null

  it "can convert paragraph to h1", ->
    $firstBlock = editor.body.children().first()
    expect($firstBlock.is('p')).toBe(true)
    expect($firstBlock.is('h1')).toBe(false)

    button = editor.toolbar.list.find('.toolbar-item-title').data 'button'
    button.menuEl.find('.menu-item-h1').click()
    $firstBlock = editor.body.children().first()
    expect($firstBlock.is('p')).toBe(false)
    expect($firstBlock.is('h1')).toBe(true)

    button.menuEl.find('.menu-item-normal').click()
    $firstBlock = editor.body.children().first()
    expect($firstBlock.is('p')).toBe(true)
    expect($firstBlock.is('h1')).toBe(false)

  it "can convert paragraph to h5", ->
    $firstBlock = editor.body.children().first()
    expect($firstBlock.is('p')).toBe(true)
    expect($firstBlock.is('h5')).toBe(false)

    button = editor.toolbar.list.find('.toolbar-item-title').data 'button'
    button.menuEl.find('.menu-item-h5').click()
    $firstBlock = editor.body.children().first()
    expect($firstBlock.is('p')).toBe(false)
    expect($firstBlock.is('h5')).toBe(true)

    button.menuEl.find('.menu-item-normal').click()
    $firstBlock = editor.body.children().first()
    expect($firstBlock.is('p')).toBe(true)
    expect($firstBlock.is('h5')).toBe(false)
