describe 'Simditor table button', ->
  editor = null

  beforeEach ->
    jasmine.clock().install()
    editor = spec.generateSimditor
      toolbar: ['table']

  afterEach ->
    jasmine.clock().uninstall()
    spec.destroySimditor()
    editor = null

  it 'should create a new table after clicking and selecting size', ->
    editor.focus()

    $button = editor.toolbar.list.find('.toolbar-item-table')
    expect($button.length).toBe(1)
    expect(editor.body.find('table').length).toBe(0)

    editor.inputManager.focused = true
    editor.trigger 'selectionchanged'
    $button.mousedown()
    $('.menu-create-table td').eq(2).mousedown()
    $table = editor.body.find('table')
    expect($table.length).toBe(1)
    expect($table.find('tr').length).toBe(2)
    expect($table.find('th, td').length).toBe(6)
