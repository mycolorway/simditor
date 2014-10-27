describe 'Selection', ->
  editor = null
  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
  afterEach ->
    editor?.destroy()
    $('#test').remove()

  compareRange = (range1, range2) ->
    return false unless range1.endContainer? or range2.endContainer?
    return false unless range1.endContainer == range2.endContainer \
      or range1.endOffset == range2.endOffset \
      or range1.startContainer == range2.startContainer \
      or range1.startOffset == rang2.startOffset
    true

  describe '_init method', ->
    it 'should link editor instance and get document\s selection', ->
      expect(editor.selection.editor).toBe(editor)
      expect(editor.selection.sel).toBe(document.getSelection())

  describe 'selectRange && getRange', ->
    it '', ->
      tmp = $('<p id="test1">this is <b id="test2">test</b> text</p>').appendTo '.simditor-body'
      range = document.createRange();
      range.setStart $('#test1')[0], 0
      range.setEnd $('#test2')[0], 0
      editor.focus()
      editor.selection.selectRange range
      #range not support equal
      expect(editor.selection.getRange().toString() == range.toString()).toBe(true)
      editor.selection.clear()
      expect(editor.selection.getRange()).toBe(null)

describe 'operate range method', ->
    beforeEach ->
      tmp = $('<p id="test1">this <b id="test2">is</b> <b id="test3">test</b>text</p>')
      .appendTo '.simditor-body'
      editor.sync()
      range = document.createRange()
      range.setStart $('#test1')[0], 0
      range.setEnd $('#test2')[0], 0
      editor.focus()
      editor.selection.selectRange range
    it 'should set correct range when call setRangeAfter method', ->
      editor.selection.setRangeAfter $('#test3')
      expect(editor.selection.getRange().startOffset).toBe(4)

    it 'should set correct range when call  setRangeBefore method', ->
      editor.selection.setRangeBefore $('#test3')
      expect(editor.selection.getRange().startOffset).toBe(3)

    it 'should set correct range when call  setRangeAtStartOf method', ->
      editor.selection.setRangeAtStartOf $('#test3')
      expect(editor.selection.getRange().endContainer).toBe($('#test3')[0])

    it 'should set correct range when call  setRangeAtEndOf ,method', ->
      #TODO: Add more test
      editor.selection.setRangeAtEndOf $('#test3')
      expect(editor.selection.getRange().endContainer).toBe($('#test3')[0])

  describe 'save and restore', ->
    #TODO: add spec

