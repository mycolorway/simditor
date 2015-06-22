describe 'A Simditor instance with keystroke manager', ->
  editor = null
  beforeEach ->
    jasmine.clock().install()
    editor = spec.generateSimditor()

  afterEach ->
    jasmine.clock().uninstall()
    spec.destroySimditor()
    editor = null

  triggerKeyStroke = (key, opts = {}) ->
    e = $.Event('keydown', $.extend({which: key}, opts))
    editor.body.trigger e

  it 'should leave blockquote when press return on last line of blockquote', ->
    editor.focus()
    editor.selection.setRangeAtStartOf(editor.body.find('blockquote > p:last'))
    expect(editor.body.find('blockquote > p').length).toBe(2)
    triggerKeyStroke 13
    expect(editor.body.find('blockquote > p').length).toBe(1)

  it 'should delete blockquote when press delete at start of blockquote', ->
    editor.focus()
    jasmine.clock().tick(100)
    editor.selection.setRangeAtStartOf(editor.body.find('blockquote > p:first'))
    expect(editor.body.find('blockquote')).toExist()
    triggerKeyStroke 8
    expect(editor.body.find('blockquote')).not.toExist()

  it 'should remove hr when press delete after hr', ->
    editor.focus()
    jasmine.clock().tick(100)
    editor.selection.setRangeAtStartOf(editor.body.find('p:last'))
    expect(editor.body.find('hr')).toExist()
    triggerKeyStroke 8
    expect(editor.body.find('hr')).not.toExist()

  it 'should insert \\n by pressing return in code block', ->
    editor.focus()
    jasmine.clock().tick(100)
    $pre = editor.body.find('pre')
    editor.selection.setRangeAtEndOf($pre)
    expect($pre.text().indexOf('\n')).toBe(-1)
    triggerKeyStroke 13
    expect($pre.text().indexOf('\n') > -1).toBe(true)

  it 'should leave code block by pressing shift + return', ->
    editor.focus()
    jasmine.clock().tick(100)
    $pre = editor.body.find('pre')
    editor.selection.setRangeAtEndOf($pre)
    triggerKeyStroke 13,
      shiftKey: true
    expect(editor.util.closestBlockEl()).not.toBeMatchedBy('pre')

  it 'should delete code block by pressing delete at start of pre', ->
    editor.focus()
    jasmine.clock().tick(100)
    $pre = editor.body.find('pre')
    editor.selection.setRangeAtStartOf($pre)
    triggerKeyStroke 8
    expect(editor.body.find('pre')).not.toExist()
