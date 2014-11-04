describe 'Simditor Popover Module', ->
  editor = null
  testPopover = null
  class TestPopover extends Popover
    render: ->
      @el.addClass('test-popover')
      @el.append($('<p>popover</p>'))

  beforeEach ->
    $('<textarea id="test"></textarea>').appendTo 'body'
    editor = new Simditor
      textarea: '#test'
    $('<p id="target">target</p>').appendTo editor.body
    button =
      editor: editor
    testPopover = new TestPopover
      button: button

  afterEach ->
    editor?.destroy()
    $('#test').remove()

  it 'can be inherited from', ->
    expect(testPopover instanceof SimpleModule).toBeTruthy()

  it 'should render specific layout', ->
     expect(editor.el.find('.simditor-popover.test-popover')).toExist()

  it 'should add/remove hover class when hovered', ->
    testPopover.el.trigger 'mouseenter'
    expect(testPopover.el).toHaveClass('hover')
    testPopover.el.trigger 'mouseleave'
    expect(testPopover.el).not.toHaveClass('hover')

  it 'should show up when call show on specified node', ->
    $target = $('#target')

    expect(testPopover).not.toBeVisible()
    testPopover.show($target)
    expect($target).toHaveClass('selected')
    expect(testPopover.el).toBeVisible()
    expect(testPopover.active).toBeTruthy()

  it 'should hide when call hide method', ->
    spyEvent = spyOnEvent(testPopover, 'popoverhide')

    #if not active, shouldn't hide
    testPopover.hide()
    expect(spyEvent).not.toHaveBeenTriggered()

    $target = $('#target')
    spyEvent.reset()
    testPopover.show($target)
    expect(testPopover.el).toBeVisible()
    testPopover.hide()
    expect(spyEvent).toHaveBeenTriggered()
    expect(testPopover.el).not.toBeVisible()