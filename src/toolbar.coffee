
class Toolbar extends SimpleModule

  @pluginName: 'Toolbar'

  opts:
    toolbar: true
    toolbarFloat: true
    toolbarHidden: false
    toolbarFloatOffset: 0
    toolbarScrollContainer: window

  _tpl:
    wrapper: '<div class="simditor-toolbar"><ul></ul></div>'
    separator: '<li><span class="separator"></span></li>'

  _init: ->
    @editor = @_module
    return unless @opts.toolbar

    unless $.isArray @opts.toolbar
      @opts.toolbar = ['bold', 'italic', 'underline', 'strikethrough', '|',
        'ol', 'ul', 'blockquote', 'code', '|', 'link', 'image', '|',
        'indent', 'outdent']

    @_render()

    @list.on 'click', (e) ->
      false

    @wrapper.on 'mousedown', (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    $(document).on 'mousedown.simditor' + @editor.id, (e) =>
      @list.find('.menu-on').removeClass('.menu-on')

    if not @opts.toolbarHidden and @opts.toolbarFloat
      scrollContainerOffset = if @opts.toolbarScrollContainer == window then {top: 0, left: 0} else $(@opts.toolbarScrollContainer).offset()
      @wrapper.css 'top', scrollContainerOffset.top + @opts.toolbarFloatOffset
      toolbarHeight = 0

      initToolbarFloat = =>
        @wrapper.css 'position', 'static'
        @wrapper.width 'auto'
        @editor.util.reflow @wrapper
        @wrapper.width @wrapper.outerWidth() # set width for fixed element
        @wrapper.css 'left', if @editor.util.os.mobile
          @wrapper.position().left
        else
          @wrapper.offset().left - scrollContainerOffset.left
        @wrapper.css 'position', ''
        toolbarHeight = @wrapper.outerHeight()
        @editor.placeholderEl.css 'top', scrollContainerOffset.top
        true

      floatInitialized = null
      $(window).on 'resize.simditor-' + @editor.id, (e) ->
        floatInitialized = initToolbarFloat()

      $(@opts.toolbarScrollContainer).on 'scroll.simditor-' + @editor.id, (e) =>
        return unless @wrapper.is(':visible')
        topEdge = if @opts.toolbarScrollContainer == window
          @editor.wrapper.get(0).getBoundingClientRect().top
        else
          @editor.wrapper.offset().top - scrollContainerOffset.top


        bottomEdge = topEdge + @editor.wrapper.outerHeight() - 80

        # scrollTop = $(document).scrollTop() + @opts.toolbarFloatOffset
        scrollTop = $(@opts.toolbarScrollContainer).scrollTop() + @opts.toolbarFloatOffset

        if topEdge > 0 or bottomEdge < 0
          @editor.wrapper.removeClass('toolbar-floating')
            .css('padding-top', '')
          if @editor.util.os.mobile
            @wrapper.css 'top', @opts.toolbarFloatOffset
        else
          floatInitialized ||= initToolbarFloat()
          @editor.wrapper.addClass('toolbar-floating')
            .css('padding-top', toolbarHeight)
          if @editor.util.os.mobile
            @wrapper.css 'top', scrollTop - topEdge + @opts.toolbarFloatOffset

    @editor.on 'destroy', =>
      @buttons.length = 0

    $(document).on "mousedown.simditor-#{@editor.id}", (e) =>
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
        throw new Error "simditor: invalid toolbar button #{name}"
        continue

      @buttons.push new @constructor.buttons[name]
        editor: @editor

    @wrapper.hide() if @opts.toolbarHidden

  findButton: (name) ->
    button = @list.find('.toolbar-item-' + name).data('button')
    button ? null

  @addButton: (btn) ->
    @buttons[btn::name] = btn

  @buttons: {}
