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

  describe 'aligning paragraph', ->
    $p1 = null
    $p2 = null

    beforeEach ->
      editor.focus()
      jasmine.clock().tick(100)

      $p = editor.body.find('> p')
      $p1 = $p.first()
      $p2 = $p.eq(1)
      range = document.createRange()
      editor.selection.setRangeAtEndOf $p2, range
      range.setStart $p1[0], 0
      editor.selection.selectRange range      

    it "to left", ->
      expect($p1.attr('data-align')).toBe(undefined)
      expect($p2.attr('data-align')).toBe(undefined)
      button = editor.toolbar.list.find('.toolbar-item-alignment').data 'button'
      button.command "left"
      expect($p1.attr('data-align')).toBe('left')
      expect($p2.attr('data-align')).toBe('left')

    it "to center", ->
      button = editor.toolbar.list.find('.toolbar-item-alignment').data 'button'
      button.command "center"
      expect($p1.attr('data-align')).toBe('center')
      expect($p2.attr('data-align')).toBe('center')

    it "to right", ->
      button = editor.toolbar.list.find('.toolbar-item-alignment').data 'button'
      button.command "right"
      expect($p1.attr('data-align')).toBe('right')
      expect($p2.attr('data-align')).toBe('right') 
