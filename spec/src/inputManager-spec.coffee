describe 'A Simditor instance with inputManager', ->
  editor = null
  beforeEach ->
    jasmine.clock().install()
    editor = spec.generateSimditor()

  afterEach ->
    jasmine.clock().uninstall()
    spec.destroySimditor()
    editor = null

  it 'should render specific layout', ->
    expect(editor.el.find('.simditor-paste-area')).toExist()

  it 'should ensure editor\'s body has content', ->
    editor.body.empty()
    editor.body.focus()
    jasmine.clock().tick(100)

    e = $.Event('keyup', {which: 8, keyCode:8})
    editor.body.trigger e
    expect(editor.body.find('p>br')).toExist()
