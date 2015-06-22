describe 'A Simditor instance with indentation manager', ->
  editor = null
  beforeEach ->
    jasmine.clock().install()
    editor = spec.generateSimditor()

  afterEach ->
    jasmine.clock().uninstall()
    spec.destroySimditor()
    editor = null

  it 'should indent paragraph when pressing tab', ->
    editor.focus()
    jasmine.clock().tick(100)

    $p = editor.body.find('> p')
    $p1 = $p.first()
    $p2 = $p.eq(1)
    range = document.createRange()
    editor.selection.setRangeAtEndOf $p2, range
    range.setStart $p1[0], 0
    editor.selection.selectRange range

    expect(parseInt($p1.css('margin-left'))).toBe(0)
    expect(parseInt($p2.css('margin-left'))).toBe(0)
    editor.indentation.indent()
    expect(parseInt($p1.css('margin-left'))).toBe(editor.opts.indentWidth)
    expect(parseInt($p2.css('margin-left'))).toBe(editor.opts.indentWidth)
    editor.indentation.indent(true)
    expect(parseInt($p1.css('margin-left'))).toBe(0)
    expect(parseInt($p2.css('margin-left'))).toBe(0)

  it 'should indent list when pressing tab in ul', ->
    editor.focus()
    jasmine.clock().tick(100)

    $ul = editor.body.find '> ul'
    $li = $ul.find('li')
    $li1 = $li.eq(1)
    $li2 = $li.eq(2)
    range = document.createRange()
    editor.selection.setRangeAtEndOf $li2, range
    range.setStart $li1[0], 0
    editor.selection.selectRange range

    expect($li1.parentsUntil(editor.body, 'ul').length).toBe(1)
    expect($li2.parentsUntil(editor.body, 'ul').length).toBe(1)
    editor.indentation.indent()
    expect($li1.parentsUntil(editor.body, 'ul').length).toBe(2)
    expect($li2.parentsUntil(editor.body, 'ul').length).toBe(2)
    editor.indentation.indent(true)
    expect($li1.parentsUntil(editor.body, 'ul').length).toBe(1)
    expect($li2.parentsUntil(editor.body, 'ul').length).toBe(1)
