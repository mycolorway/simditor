
class Button

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

  constructor: (@toolbar) ->
    @render()

    @el.on 'mousedown', (e) =>
      e.preventDefault()
      return if @el.hasClass 'disabled'

      if @menu
        @toolbar.wrapper.toggleClass('menu-on')
      else
        @command()

    @toolbar.list.on 'mousedown', 'a.menu-item', (e) =>
      e.preventDefault()
      btn = $(e.currentTarget)
      return if btn.hasClass 'disabled' or (@needFocus and !@toolbar.editor.inputManager.focused)

      @toolbar.wrapper.removeClass('menu-on')
      param = btn.data('param')
      @command(param)

    @toolbar.editor.on 'blur', =>
      @setActive false
      @setDisabled false

    if @shortcut?
      @toolbar.editor.inputManager.addShortcut @shortcut, (e) =>
        @el.mousedown()

  render: ->
    @wrapper = $(@_tpl.item).appendTo @toolbar.list
    @el = @wrapper.find 'a.toolbar-item'

    @el.attr('title', @title)
      .addClass('toolbar-item-' + @name)
      .data('button', this)

    @el.find('span')
      .addClass(if @icon then 'fa fa-' + @icon else '')
      .text(@text)

    return unless @menu

    @menuWrapper = $(@_tpl.menuWrapper).appendTo(@wrapper)
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
          'title': menuItem.title
        )
        .addClass('menu-item-' + menuItem.name)
        .data('param', menuItem.param)
        .find('span')
        .text(menuItem.text)

  setActive: (active) ->
    @active = active
    @el.toggleClass('active', @active)

  setDisabled: (disabled) ->
    @disabled = disabled
    @el.toggleClass('disabled', @disabled)

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return @disabled if @disabled

    @setActive $node.is(@htmlTag) if $node?
    @active

  command: (param) ->
