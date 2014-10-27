describe 'Core', ->
  editor = null
  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
  afterEach ->
    editor?.destroy()
    $('#test').remove()

  describe '_init & destroy method', ->
    it 'should append template to DOM when constructed', ->
      expect($('.simditor')).toExist()
      expect($('.simditor')).toContainElement('.simditor-wrapper .simditor-placeholder')
      expect($('.simditor')).toContainElement('.simditor-wrapper .simditor-body')
      expect($('.simditor')).toContainElement('textarea')

      expect(editor.el).toHaveClass('simditor')
      expect(editor.body).toHaveClass('simditor-body')
      expect(editor.wrapper).toHaveClass('simditor-wrapper')

    it 'should reset to default when call destroy', ->
      editor.destroy()
      expect($('.simditor')).not.toExist()
      expect($('textarea#test')).toExist()

  describe 'setValue && getValue method', ->
    it 'should set correct value when call setValue', ->
      editor.setValue('Hello, world!')
      expect($('#test').val()).toBe('Hello, world!')

    it 'should return correct value when call getValue', ->
      #setValue call sync() automatic
      editor.setValue('Hello, world!')
      expect(editor.getValue()).toBe('<p>Hello, world!</p>')

  describe 'focus && blur method', ->
    it 'should focus on editor\'s body when call focus and blur when call blue', ->
      editor.focus()
      expect(editor.body).toBeFocused()
      editor.blur()
      expect(editor.body).not.toBeFocused()

  describe 'hidePopover method', ->
    #TODO: add spec later


