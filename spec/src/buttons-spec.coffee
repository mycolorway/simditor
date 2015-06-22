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

  it 'should create code block after clicking code button', ->
    editor.setValue '<p>var test = 1;</p>'
    editor.focus()
    jasmine.clock().tick(100)

    $p = editor.body.find 'p:first'
    $button = editor.toolbar.list.find('.toolbar-item-code')
    expect($button).toExist()

    $text = $p.contents().first()
    range = document.createRange()
    range.setStart($text[0], 0)
    range.setEnd($text[0], 8)
    editor.selection.selectRange range
    $button.mousedown()
    editor.trigger 'selectionchanged'

    expect(editor.getValue()).toBe('<pre><code>var test = 1;</code></pre>')
    editor.el.find('.code-popover .select-lang').val('js').change()
    expect(editor.getValue()).toBe('<pre><code class="lang-js">var test = 1;</code></pre>')

  describe 'table button', ->

    it 'should create a new table after clicking table button and selecting table size', ->
      editor.focus()
      jasmine.clock().tick(100)

      $button = editor.toolbar.list.find('.toolbar-item-table')
      expect(editor.body.find('table')).not.toExist()

      $button.mousedown()
      $('.menu-create-table td').eq(2).mousedown()
      $table = editor.body.find('table')
      expect($table).toExist()
      expect($table.find('tr').length).toBe(2)
      expect($table.find('th, td').length).toBe(6)


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

    it "can align to right", ->
      expect($p1.css('text-align')).toBe('start')
      expect($p2.css('text-align')).toBe('start')
      button = editor.toolbar.list.find('.toolbar-item-alignment').data 'button'
      button.command "right"
      expect($p1.css('text-align')).toBe('right')
      expect($p2.css('text-align')).toBe('right')

    it "can align to center", ->
      button = editor.toolbar.list.find('.toolbar-item-alignment').data 'button'
      button.command "center"
      expect($p1.css('text-align')).toBe('center')
      expect($p2.css('text-align')).toBe('center')

    it "can align to left", ->
      button = editor.toolbar.list.find('.toolbar-item-alignment').data 'button'
      button.command "left"
      expect($p1.css('text-align')).toBe('start')
      expect($p2.css('text-align')).toBe('start')
