describe 'UndoManager', ->
  editor = null
  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
  afterEach ->
    editor?.destroy()
    $('#test').remove()
  describe '_init method', ->
    it 'should link editor\'s instance', ->
      console.log editor.undoManager
      expect(editor.undoManager.editor).toBe(editor)

  describe 'caret position method', ->
    it '_getNodeOffset', ->

    it '_getNodePosition', ->

    it '_getNodeByPosition', ->

    it 'caetPosition', ->

  describe '_pushUndoState', ->
    it 'should push correct state', ->
      editor.body.empty()
      tpl = '''
        <p>test</p>
      '''
      tpl = $(tpl)
      tpl.appendTo '.simditor-body'

      editor.undoManager._pushUndoState()
      expect(editor.undoManager._stack[0].html).toBe('<p>test</p>')