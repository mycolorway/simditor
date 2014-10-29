describe 'Toolbar', ->
  editor = null
  toolbar = ['bold','title',  'italic', 'underline', 'strikethrough', 'color', 'ol', 'ul', 'blockquote', 'code', 'table', 'link', 'image', 'hr', 'indent', 'outdent']
  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
      toolbar: toolbar

  afterEach ->
    editor?.destroy()
    $('#test').remove()

  compareArray = (arr1, arr2) ->
    arr1.toString() == arr2.toString()

  describe '_init method', ->
    it 'should link editor\'s instance', ->
      expect(editor.toolbar.editor).toBe(editor)

    it 'should remove menu-on class on li when click toolbar', ->
      editor.toolbar.list.find('li').eq(0).addClass('menu-on')
      editor.toolbar.wrapper.trigger('mousedown')
      expect(editor.toolbar.list.find('li').eq(0)).not.toHaveClass('menu-on')

    #TODO: add float css spec

  describe 'render method', ->
    it 'should create button\'s instance to its buttons array', ->
      expect(editor.toolbar.buttons.length).toBe(toolbar.length)
      nameArray = []
      nameArray.push button.name for button in editor.toolbar.buttons
      expect(compareArray(nameArray, toolbar)).toBeTruthy()

    it 'should prepend toolbar to editor\'s wrapper', ->
      expect(editor.wrapper.find('.simditor-toolbar')).toExist()
      expect(editor.wrapper.find('.simditor-toolbar>ul>li').length).toBe(toolbar.length)

  describe 'findButton method', ->
    it 'should find correct button', ->
      expect(editor.toolbar.findButton('bold').name).toBe('bold')

    it 'it should return null when wrong arg give', ->
      expect(editor.toolbar.findButton('error')).toBeNull()

  describe 'toolbarStatus', ->
    #TODO: add spec later