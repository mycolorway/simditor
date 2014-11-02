#TODO: rewrite all
describe 'Simditor InputManager Module', ->
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
      expect(editor.inputManager.editor).toBe(editor)

    it 'should render pasteArea to DOM', ->
      expect(editor.el.find('div.simditor-paste-area')).toExist()
      expect(editor.el.find('div.simditor-paste-area')).toHaveAttr('contentEditable')

    it 'should render cleanPasteArea to DOM', ->
      expect(editor.el.find('textarea.simditor-clean-paste-area')).toExist()


  describe 'onFocus && onBlur method', ->
    it 'should add/remove focus class when call _onFocus/onBlur method', ->
      editor.inputManager._onFocus()
      expect(editor.el).toHaveClass('focus')

      editor.inputManager._onBlur()
      expect(editor.el).not.toHaveClass('focus')

  describe 'addKeystrokeHandler', ->
    it 'should add key stroke to its instance', ->
      tmpCallback = ->
        console.log 'this is a test'
      editor.inputManager.addKeystrokeHandler 13, 'ele', tmpCallback
      expect(editor.inputManager._keystrokeHandlers[13]?['ele']).toBe(tmpCallback)