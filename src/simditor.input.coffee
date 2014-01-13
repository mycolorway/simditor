
Simditor.Input =

  _opts:
    tabIndent: true

  _modifierKeys: [16, 17, 18, 91, 93]

  _arrowKeys: [37..40]

  _load: ->

  _init: ->
    @body.on 'keydown', @_onKeyDown
      .on 'mouseUp', @_onMouseUp
      .on 'focus', @_onFocus
      .on 'blur', @_onBlur

    if @textarea.attr 'autofocus'
      setTimeout =>
        @body.focus()
      , 0

  _onFocus: (e) ->
    @el.addClass 'focus'
      .removeClass 'error'

    @focused = true

    @format()

  _onBlur: (e) ->
    @el.removeClass 'focus'
    @focused = false

  _onMouseUp: (e) ->
    @trigger 'selectionchanged'

  _onKeyDown: (e) ->
    if @triggerHandler e == false
      return false

    if e.which in @_modifierKeys or e.which in @_arrowKeys
      return

    metaKey = @metaKey e

    # meta + enter: submit current form
    if e.which == 13 and metaKey
      e.prenvetDefault()
      @el.closest 'form'
        .find 'button:submit'
        .click()
      return

    # safari doesn't support shift + enter default behavior
    if @browser.safari and e.which == 13 and e.shiftKey
      # TODO
      return

    # remove hr node
    if e.which == 8
      # TODO
      return
    
    if e.which == 9 and (opts.tabIndent or @closestBlockNode().is 'pre')
      # TODO
      return

    clearTimeout @_typing if @_typing

    @_typing = setTimeout =>
      @trigger 'valuechanged'
      @trigger 'selectionchanged'
      @_typing = false

  _onKeyUp: (e) ->
    if @triggerHandler e == false
      return false

    if e.which in @_arrowKeys
      @trigger 'selectionchanged'
      return

    if e.which == 8 and @body.is ':empty'
      $('<p/>').append @_placeholderBr
        .appendTo @body
      return

  _nodeInputHandlers:
    p:
      13: ($node, range) ->

      8: ($node, range) ->
  



