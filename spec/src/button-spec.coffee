describe 'Simditor Button Module', ->
  editor = null
  class TestButton extends Button
    name: 'test'
    title: 'test'
    htmlTag: 'b, strong'
    disableTag: 'pre'
    shortcut: 'shift+68'
    title: 'test'
    active: false
    menu: [{
      name: 'subMenu',
      text: 'subMenu',
      param: true
    }]

    render: ->
      super()

    command: (param) ->
      $(document).trigger 'testbuttonworked' if param


  Simditor.Toolbar.addButton TestButton

  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
      toolbar: ['test']
    $('<p>test</p><pre id="dis">test disabled tag</pre><b id="act">test active tag</b>')
      .appendTo editor.body
    editor.focus()
  afterEach ->
    editor?.destroy()
    $('#test').remove()

  setRange = (ele, offsetStart, offsetEnd) ->
    ele = ele[0]
    range = document.createRange()
    unless offset
      offset = 0
    range.setStart ele, offsetStart
    range.setEnd ele, offsetEnd
    editor.focus()
    editor.selection.selectRange range

  it 'should render specific layout', ->
    expect(editor.wrapper.find('a.toolbar-item.toolbar-item-test')).toExist()
    expect(editor.toolbar.findButton('test').name).toBe('test')

  it 'should expand menu when clicked', ->
    btn = editor.toolbar.findButton('test');
    btnLink = editor.wrapper.find('a.toolbar-item.toolbar-item-test');

    spyEvent = spyOnEvent(btn, 'menuexpand')
    btnLink.trigger 'mousedown'
    expect(btnLink.parent()).toHaveClass('menu-on')
    expect(spyEvent).toHaveBeenTriggered()

  it 'should exec custom command when click menu-item', ->
    btnLink = editor.wrapper.find('a.toolbar-item.toolbar-item-test');
    btnLink.trigger 'mousedown'
    spyEvent = spyOnEvent(document, 'testbuttonworked')

    btnLink.parent().find('.menu-item-subMenu').trigger 'click'
    expect(spyEvent).toHaveBeenTriggered()

  it 'should be disabled when in disabled tag', ->
    setRange($('#dis'), 0, 1)
    editor.trigger 'selectionchanged'
    btnLink = editor.wrapper.find('a.toolbar-item.toolbar-item-test');
    expect(btnLink).toHaveClass('disabled')

  it 'should be active when in active tag', ->
    setRange($('#act'), 0, 1)
    editor.trigger 'selectionchanged'
    btnLink = editor.wrapper.find('a.toolbar-item.toolbar-item-test');
    expect(btnLink).toHaveClass('active')
