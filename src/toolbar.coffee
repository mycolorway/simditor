
class Toolbar extends SimpleModule

  @pluginName: 'Toolbar'

  opts:
    toolbar: true
    toolbarFloat: true
    toolbarHidden: false
    toolbarFloatOffset: 0

  _tpl:
    wrapper: '<div class="simditor-toolbar"><ul></ul></div>'
    separator: '<li><span class="separator"></span></li>'

  _init: ->
    @editor = @_module
    return unless @opts.toolbar

    unless $.isArray @opts.toolbar
      @opts.toolbar = ['bold', 'italic', 'underline', 'strikethrough', '|', 'ol', 'ul', 'blockquote', 'code', '|', 'link', 'image', '|', 'indent', 'outdent']

    @_render()

    @list.on 'click', (e) =>
      false

    @wrapper.on 'mousedown', (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    $(document).on 'mousedown.simditor' + @editor.id, (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    if not @opts.toolbarHidden and @opts.toolbarFloat
      @wrapper.width @wrapper.outerWidth()
      @wrapper.css 'top', @opts.toolbarFloatOffset
      toolbarHeight = @wrapper.outerHeight()

      unless @editor.util.os.mobile
        $(window).on 'resize.simditor-' + @editor.id, (e) =>
          @wrapper.css 'position', 'static'
          @editor.util.reflow @wrapper
          @wrapper.css 'left', @wrapper.offset().left
          @wrapper.css 'position', ''
        .resize()

      $(window).on 'scroll.simditor-' + @editor.id, (e) =>
        topEdge = @editor.wrapper.offset().top
        bottomEdge = topEdge + @editor.wrapper.outerHeight() - 80
        scrollTop = $(document).scrollTop() + @opts.toolbarFloatOffset

        if scrollTop <= topEdge or scrollTop >= bottomEdge
          @editor.wrapper.removeClass('toolbar-floating')
            .css('padding-top', '')
          if @editor.util.os.mobile
            @wrapper.css 'top', @opts.toolbarFloatOffset
        else
          @editor.wrapper.addClass('toolbar-floating')
            .css('padding-top', toolbarHeight)
          if @editor.util.os.mobile
            @wrapper.css 'top', scrollTop - topEdge + @opts.toolbarFloatOffset

    @editor.on 'selectionchanged', =>
      @toolbarStatus()

    @editor.on 'destroy', =>
      @buttons.length = 0

    $(document).on 'mousedown.simditor-' + @editor.id, (e) =>
      @list.find('li.menu-on').removeClass('menu-on')

  _render: ->
    @buttons = []
    @wrapper = $(@_tpl.wrapper).prependTo(@editor.wrapper)
    @list = @wrapper.find('ul')

    for name in @opts.toolbar
      if name == '|'
        $(@_tpl.separator).appendTo @list
        continue

      unless @constructor.buttons[name]
        throw new Error 'simditor: invalid toolbar button "' + name + '"'
        continue

      @buttons.push new @constructor.buttons[name]
        editor: @editor

    if @opts.toolbarHidden
      @wrapper.hide()
    else
      @editor.placeholderEl.css 'top', @wrapper.outerHeight()

  toolbarStatus: (name) ->
    return unless @editor.inputManager.focused

    buttons = @buttons[..]
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

  findButton: (name) ->
    button = @list.find('.toolbar-item-' + name).data('button')
    button ? null

  @addButton: (btn) ->
    @buttons[btn::name] = btn

  @buttons: {}


