
Simditor.Input =

  _modifierKeys: []

  _arrowKeys: []

  _valueKeys: []

  _load: ->

  _init: ->
    @body.on 'keydown', @onKeyDown
      .on 'mouseUp', @onMouseUp
      .on 'focus', @onFocus
      .on 'blur', @onBlur

    if @textarea.attr 'autofocus'
      setTimeout =>
        @body.focus()
      , 0

