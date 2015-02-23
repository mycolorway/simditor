
class Button extends SimpleModule

  _tpl:
    item: '<li><a tabindex="-1" unselectable="on" class="toolbar-item" href="javascript:;"><span></span></a></li>'
    menuWrapper: '<div class="toolbar-menu"></div>'
    menuItem: '<li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;"><span></span></a></li>'
    separator: '<li><span class="separator"></span></li>'

  name: ''

  icon: ''

  title: ''

  text: ''

  htmlTag: ''

  disableTag: ''

  menu: false

  active: false

  disabled: false

  needFocus: true

  shortcut: null

  constructor: (opts) ->
    @editor = opts.editor
    @title = @_t(@name)
    super opts

  _init: ->
    @render()

    @el.on 'mousedown', (e) =>
      e.preventDefault()
      return false if @el.hasClass('disabled') or (@needFocus and !@editor.inputManager.focused)

      if @menu
        @wrapper.toggleClass('menu-on')
          .siblings('li')
          .removeClass('menu-on')

        if @wrapper.is('.menu-on')
          exceed = @menuWrapper.offset().left + @menuWrapper.outerWidth() + 5 -
            @editor.wrapper.offset().left - @editor.wrapper.outerWidth()

          if exceed > 0
            @menuWrapper.css
              'left': 'auto'
              'right': 0

          @trigger 'menuexpand'

        return false

      param = @el.data('param')
      @command(param)
      false

    @wrapper.on 'click', 'a.menu-item', (e) =>
      e.preventDefault()
      btn = $(e.currentTarget)
      @wrapper.removeClass('menu-on')
      return false if btn.hasClass('disabled') or (@needFocus and !@editor.inputManager.focused)

      @editor.toolbar.wrapper.removeClass('menu-on')
      param = btn.data('param')
      @command(param)
      false

    @wrapper.on 'mousedown', 'a.menu-item', (e) =>
      false

    @editor.on 'blur', =>
      return if @editor.sourceMode
      @setActive false
      @setDisabled false


    if @shortcut?
      @editor.inputManager.addShortcut @shortcut, (e) =>
        @el.mousedown()
        false

    for tag in @htmlTag.split ','
      tag = $.trim tag
      if tag && $.inArray(tag, @editor.formatter._allowedTags) < 0
        @editor.formatter._allowedTags.push tag

  render: ->
    @wrapper = $(@_tpl.item).appendTo @editor.toolbar.list
    @el = @wrapper.find 'a.toolbar-item'

    @el.attr('title', @title)
      .addClass("toolbar-item-#{@name}")
      .data('button', @)

    @el.find('span')
      .addClass(if @icon then "simditor-icon simditor-icon-#{@icon}" else '')
      .text(@text)

    return unless @menu

    @menuWrapper = $(@_tpl.menuWrapper).appendTo(@wrapper)
    @menuWrapper.addClass "toolbar-menu-#{@name}"
    @renderMenu()

  renderMenu: ->
    return unless $.isArray @menu

    @menuEl = $('<ul/>').appendTo @menuWrapper
    for menuItem in @menu
      if menuItem == '|'
        $(@_tpl.separator).appendTo @menuEl
        continue

      $menuItemEl = $(@_tpl.menuItem).appendTo @menuEl
      $menuBtntnEl = $menuItemEl.find('a.menu-item')
        .attr(
          'title': menuItem.title ? menuItem.text,
          'data-param': menuItem.param
        )
        .addClass('menu-item-' + menuItem.name)
        .find('span')
        .text(menuItem.text)

  setActive: (active) ->
    return if active == @active
    @active = active
    @el.toggleClass('active', @active)
    @editor.toolbar.trigger 'buttonstatus', [@]

  setDisabled: (disabled) ->
    return if disabled == @disabled
    @disabled = disabled
    @el.toggleClass('disabled', @disabled)
    @editor.toolbar.trigger 'buttonstatus', [@]

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

    @setActive $node.is(@htmlTag) if $node?
    @active

  command: (param) ->

  _t: (args...) ->
    result = super args...
    result = @editor._t args... unless result
    result


Simditor.Button = Button
