describe 'UndoManager', ->
  editor = null
  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
    tmp = '''
    <p>Simditor 是团队协作工具 <a href="http://tower.im">Tower</a> 使用的富文本编辑器。</p>
    <p>相比传统的编辑器它的特点是：</p>
    <ul id="list">
      <li>功能精简，加载快速</li>
      <li id="list-item-2">输出格式化的标准<span id="test-span"> HTML </span></li>
      <li>每一个功能都有非常优秀的使用体验</li>
    </ul>
    <pre>"this is a code snippet"</pre>
    <p>兼容的浏览器：IE10+、Chrome、Firefox、Safari。</p>
    '''
    tmp = $(tmp)
    tmp.appendTo '.simditor-body'
    editor.sync()

  afterEach ->
    editor?.destroy()
    $('#test').remove()

  describe '_init method', ->
    it 'should link editor\'s instance', ->
      expect(editor.undoManager.editor).toBe(editor)

  describe 'caret position method', ->
    compareArray = (arr1, arr2) ->
      arr1.toString() == arr2.toString()

    it 'should get correct offset when call _getNodeOffset method', ->
      expect(editor.undoManager._getNodeOffset($('#list-item-2')[0])).toBe(3)
      expect(editor.undoManager._getNodeOffset($('#list')[0])).toBe(5)

    it 'should get correct postion array when call _getNodePosition method', ->
      position = editor.undoManager._getNodePosition($('#test-span')[0], 0)
      expect(compareArray(position, [5, 3, 1, 0])).toBeTruthy()
      position = editor.undoManager._getNodePosition($('#test-span')[0], 1)
      expect(compareArray(position, [5, 3, 1, 1])).toBeTruthy()

    it 'should return correct element when call _getNodeByPosition method', ->
      expect(editor.undoManager._getNodeByPosition([5, 3, 1, 0])).toBe($('#test-span')[0])
      expect(editor.undoManager._getNodeByPosition([5, 3, 1, 1])).toBe($('#test-span')[0])

  describe '_pushUndoState', ->
    it 'should push correct state', ->
      editor.body.empty()
      tpl = '''
        <p>test</p>
      '''
      $(tpl).appendTo '.simditor-body'

      editor.undoManager._pushUndoState()
      expect(editor.undoManager._stack[0].html).toBe('<p>test</p>')
      $(tpl).appendTo '.simditor-body'
      editor.undoManager._pushUndoState()
      expect(editor.undoManager._stack[1].html).toBe('<p>test</p><p>test</p>')

  describe 'undo & redo method', ->
    prepareState = ->
      editor.body.empty()
      editor.setValue('<p>test1</p>')
      editor.undoManager._pushUndoState()
      editor.setValue('<p>test1test2</p>')
      editor.undoManager._pushUndoState()

    it 'should return to last state when call undo method', ->
      prepareState()
      expect(editor.getValue()).toBe('<p>test1test2</p>')
      expect(editor.undoManager._index).toBe(1)

      spyEvent = spyOnEvent(editor, 'valuechanged')
      editor.undoManager.undo()
      expect(editor.getValue()).toBe('<p>test1</p>')
      expect(editor.undoManager._index).toBe(0)
      expect(spyEvent).toHaveBeenTriggered()

      #if it's last state, undo shouldn't take any action
      spyEvent.reset()
      editor.undoManager.undo()
      expect(spyEvent).not.toHaveBeenTriggered()

    it 'should back to former state when call redo method', ->
      prepareState()

      editor.undoManager.undo()
      expect(editor.getValue()).toBe('<p>test1</p>')
      spyEvent = spyOnEvent(editor, 'valuechanged')

      editor.undoManager.redo()
      expect(editor.getValue()).toBe('<p>test1test2</p>')
      expect(editor.undoManager._index).toBe(1)
      expect(spyEvent).toHaveBeenTriggered()

      #if it's closet state, redo shouldn't take any action
      spyEvent.reset()
      editor.undoManager.redo()
      expect(spyEvent).not.toHaveBeenTriggered()
