
class Toolbar

  opts:
    toolbar: true
    toolbarFloat: true

  _tpl: 
    wrapper: '<div class="simditor-toobar"></div>'
    separator: '<li><span class="separator"></span></li>'

  constructor: ->
    $.extend(@opts, @editor.opts)
    return unless @opts.toolbar

    unless $.isArray opts.toolbar
      opts.toolbar = ['bold', 'italic', 'underline', 'ol', 'ul']

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

        if scrollTop < topEdge
          top = 0
          @wrapper.removeClass('floating')
        else if bottomEdge >= scrollTop >= topEdge
          top = scrollTop - topEdge
          @wrapper.addClass('floating')
        else
          top = bottomEdge - topEdge
          @wrapper.addClass('floating')
        }

        @wrapper.css 'top', top

    @editor.on 'selectionchange', =>
      @toolbarStatus()

  _render: ->
    @wrapper = $(@_tpl.wrapper).prependTo(@editor.wrapper)
    @list = @wrapper.find('ul')

    for name in @opts.toolbar
      if name == '|'
        $(@_tpl.separator).appendTo @list
        continue

      unless @constructor.buttons[name]
        throw new Error 'simditor: invalid toolbar button "' + name + '"'
        continue
      
      new @constructor.buttons[name](@)

  toolbarStatus: (name) ->
    return unless @editor.inputManager.focused

    buttons = if name then [name] else @opts.toolbar[..]
    @editor.util.traverseUp (node) =>
      removeIndex = []
      for name, i in buttons
        checkStatus = @constructor.buttons[name].status
        removeIndex.push[i] if !checkStatus or checkStatus.call(this, $(node)) == true

      buttons.splice(i, 1) for i in remoeIndex
      return false if buttons.length == 0

  @addButton: (btn) ->
    @buttons[btn::name] = btn

  @buttons: {}
