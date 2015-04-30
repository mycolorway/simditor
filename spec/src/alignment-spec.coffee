describe 'A Simditor instance with alignment manager', ->
  editor = null
  beforeEach ->
    jasmine.clock().install()
    editor = spec.generateSimditor()

  afterEach ->
    jasmine.clock().uninstall()
    spec.destroySimditor()
    editor = null

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
      editor.alignment.left()
      expect($p1.attr('data-align')).toBe('left')
      expect($p2.attr('data-align')).toBe('left')

    it "to center", ->
      editor.alignment.center()
      expect($p1.attr('data-align')).toBe('center')
      expect($p2.attr('data-align')).toBe('center')

    it "to right", ->
      editor.alignment.right()
      expect($p1.attr('data-align')).toBe('right')
      expect($p2.attr('data-align')).toBe('right') 
