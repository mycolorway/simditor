describe 'A Simditor instance with buttons', ->
  editor = null
  beforeEach ->
    jasmine.clock().install()
    editor = spec.generateSimditor()

  afterEach ->
    jasmine.clock().uninstall()
    spec.destroySimditor()
    editor = null

  it 'should set selection bold after clicking bold button', ->
    editor.focus()
    jasmine.clock().tick(100)

    $p = editor.body.find 'p:first'
    $button = editor.toolbar.list.find('.toolbar-item-bold')
    expect($button).toExist()

    $text = $p.contents().first()
    range = document.createRange()
    range.setStart($text[0], 0)
    range.setEnd($text[0], 8)
    editor.selection.selectRange range
    $button.mousedown()
    expect($p.find('b')).toExist()
