describe 'Simditor Toolbar Module', ->
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

  it 'should remove menu-on class on li when click toolbar', ->
    editor.toolbar.list.find('li').eq(0).addClass('menu-on')
    editor.toolbar.wrapper.trigger('mousedown')
    expect(editor.toolbar.list.find('li').eq(0)).not.toHaveClass('menu-on')

  #TODO: add css spec

  it 'should create button\'s instance to its buttons array', ->
    expect(editor.toolbar.buttons.length).toBe(toolbar.length)
    nameArray = []
    nameArray.push button.name for button in editor.toolbar.buttons
    expect(compareArray(nameArray, toolbar)).toBeTruthy()

  it 'should render toolbar to editor\'s wrapper', ->
    expect(editor.wrapper.find('.simditor-toolbar')).toExist()
    expect(editor.wrapper.find('.simditor-toolbar  >ul > li >.toolbar-item').length).toBe(toolbar.length)

  it 'should find correct button when call findButton', ->
    expect(editor.toolbar.findButton('bold').name).toBe('bold')
    #give incorrect button name
    expect(editor.toolbar.findButton('error')).toBeNull()

  #TODO: add spec later