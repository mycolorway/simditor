
Toolbar =

  opts:
    toolbar: true
    toolbarFloat: true

  _toolbarTpl: 
    wrapper: '<div class="simditor-toobar"></div>'
    item: '<li><a tabindex="-1" unselectable="on" class="toolbar-item" href="javascript:;"><span></span></a></li>'
    menuWrapper: '<div class="toolbar-menu"><ul></ul></div>'
    menuItem: '<li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;"><span></span></a></li>'
    separator: '<li><span class="separator"></span></li>'

  _load: ->

  _init: ->
    return unless @opts.toolbar

    unless $.isArray opts.toolbar
      opts.toolbar = ['bold', 'italic', 'underline', 'ol', 'ul']

    @_renderToolbar()
    
    @toolbarList.on 'click', (e) =>
      false

    @toolbarWrapper.on 'mousedown', (e) =>
      @toolbarList.find('.menu-on').removeClass('.menu-on')

    $(document).on 'mousedown.simditor', (e) =>
      @toolbarList.find('.menu-on').removeClass('.menu-on')

    @toolbarList.on 'mousedown', 'a.toolbar-item', (e) =>
      e.preventDefault()
      btn = $(e.currentTarget)
      return if btn.hasClass 'disabled'

      config = btn.data 'config'

      if config.menu
        btn.parent('li').toggleClass('menu-on')
      else
        @commands[config.cmd](config.param)

    @toolbarList.on 'mousedown', 'a.menu-item', (e) =>
      e.preventDefault()
      btn = $(e.currentTarget)
      return if btn.hasClass 'disabled'

      $li = btn.closest('li').removeClass('menu-on')
      $parentBtn = $li.find('a.toolbar-item')

      config = btn.data 'config'
      parentConfig = $parentBtn.data 'config'

      @commands[config.cmd](config.param)

    if @opts.toolbarFloat
      $(window).on 'scroll.simditor-' + @id, (e) =>
        topEdge = @wrapper.offset().top
        bottomEdge = topEdge + @wrapper.outerHeight() - 100
        scrollTop = $(document).scrollTop()
        top = 0

        if scrollTop < topEdge
          top = 0
          @toolbarWrapper.removeClass('floating')
        else if bottomEdge >= scrollTop >= topEdge
          top = scrollTop - topEdge
          @toolbarWrapper.addClass('floating')
        else
          top = bottomEdge - topEdge
          @toolbarWrapper.addClass('floating')
        }

        @toolbarWrapper.css 'top', top

    @on 'selectionchange', =>
      @toolbarStatus()

  _renderToolbar: ->
    @toolbarWrapper = $(@_toolbarTpl.wrapper).prependTo(@wrapper)
    @toolbarList = @toolbarWrapper.find('ul')

    for name in @opts.toolbar
      if name == '|'
        $(@_toolbarTpl.separator).appendTo @toolbarList
        continue

      config = @_buttons[name]
      unless config
        throw new Error 'simditor: invalid toolbar button "' + name + '"'
        continue

      $itemEl = $(@_toolbarTpl.item).appendTo @toolbarList
      $btnEl = $itemEl.find 'a.toolbar-item'

      config.name = name
      $btnEl.attr(
        'data-command': config.cmd
        'title': config.title
      )
      .addClass('toolbar-item-' + name)
      .data('config', config)

      $btnEl.find('span')
        .addClass(if config.icon then 'fa fa-' + config.icon else '')
        .text(config.text)

      continue unless config.menu

      $menuWrapper = $(@_toolbarTpl.menuWrapper).appendTo($itemEl)

      if typeof config.menu == 'function'
        config.menu.call(this, $menuWrapper, =>
          $itemEl.removeClass('menu-on')
        )
      else
        $menuEl = $('<ul/>').appendTo $menuWrapper
        for menuItem in config.menu
          if menuItem == '|'
            $(@_toolbarTpl.separator).appendTo $menuEl
            continue

          $menuItemEl = $(@_toolbarTpl.menuItem).appendTo $menuEl
          $menuBtntnEl = $menuItemEl.find('a.menu-item')
            .attr(
              'data-command': menuItem.cmd
              'title': menuItem.title
            )
            .addClass('menu-item-' + menuItem.name)
            .data('config', menuItem)
            .data('')
            .find('span')
            .text(menuItem.text)

  toolbarStatus: (name) ->
    return unless @focused

    buttons = if name then [name] else @opts.toolbar[..]
    @traverseUp (node) =>
      removeIndex = []
      for name, i in buttons
        checkStatus = _buttons[name].status
        removeIndex.push[i] if !checkStatus or checkStatus.call(this, $(node)) == false

      buttons.splice(i, 1) for i in remoeIndex
      return false if buttons.length == 0

  _buttons:
    bold:
      icon: 'bold'
      title: '加粗文字'
      cmd: 'bold'
      status: ($node) ->

    italic:
      icon: 'italic'
      title: '斜体文字'
      cmd: 'italic'
      status: ($node) ->

    underline:
      icon: 'underline'
      title: '下划线文字'
      cmd: 'underline'
      status: ($node) ->

    ol:
      icon: 'list-ol'
      title: '有序列表'
      cmd: 'list'
      param: 'ol'
      status: ($node) ->

    ol:
      icon: 'list-ul'
      title: '无序列表'
      cmd: 'list'
      param: 'ul'
      status: ($node) ->

  commands:
    bold: ->

    italic: ->

    underline: ->

    list: (type) ->
