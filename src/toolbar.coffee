
class Toolbar extends Plugin

  @className: 'Toolbar'

  opts:
    toolbar: true
    toolbarFloat: true

  _tpl: 
    wrapper: '<div class="simditor-toolbar"><ul></ul></div>'
    separator: '<li><span class="separator"></span></li>'

  constructor: (args...) ->
    super args...
    @editor = @widget

  _init: ->
    return unless @opts.toolbar

    unless $.isArray @opts.toolbar
      @opts.toolbar = ['bold', 'italic', 'underline', '|', 'ol', 'ul', 'blockquote', 'code', '|', 'link', 'image', '|', 'indent', 'outdent']

    @_render()
    
    @list.on 'click', (e) =>
      false

    @wrapper.on 'mousedown', (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    $(document).on 'mousedown.simditor', (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    if @opts.toolbarFloat
      $(window).on 'scroll.simditor-' + @editor.id, (e) =>
        topEdge = @editor.wrapper.offset().top
        bottomEdge = topEdge + @editor.wrapper.outerHeight() - 100
        scrollTop = $(document).scrollTop()
        top = 0

        if scrollTop <= topEdge
          top = 0
          @wrapper.removeClass('floating')
        else if bottomEdge > scrollTop > topEdge
          top = scrollTop - topEdge
          @wrapper.addClass('floating')
        else
          top = bottomEdge - topEdge
          @wrapper.addClass('floating')

        @wrapper.css 'top', top

    @editor.on 'selectionchanged', =>
      @toolbarStatus()

    @editor.on 'destroy', =>
      @_buttons.length = 0


  _render: ->
    @wrapper = $(@_tpl.wrapper).prependTo(@editor.wrapper)
    @list = @wrapper.find('ul')
    @editor.wrapper.addClass('toolbar-enabled')

    for name in @opts.toolbar
      if name == '|'
        $(@_tpl.separator).appendTo @list
        continue

      unless @constructor.buttons[name]
        throw new Error 'simditor: invalid toolbar button "' + name + '"'
        continue
      
      @_buttons.push new @constructor.buttons[name](@editor)

  toolbarStatus: (name) ->
    return unless @editor.inputManager.focused

    buttons = @_buttons[..]
    @editor.util.traverseUp (node) =>
      removeButtons = []
      for button, i in buttons
        continue if name? and button.name isnt name
        removeButtons.push button if !button.status or button.status($(node)) is true

      for button in removeButtons
        i = $.inArray(button, buttons)
        buttons.splice(i, 1)
      return false if buttons.length == 0

    #button.setActive false for button in buttons unless success

  # button instances
  _buttons: []

  @addButton: (btn) ->
    @buttons[btn::name] = btn

  @buttons: {}


