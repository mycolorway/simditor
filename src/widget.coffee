
class Widget
  @extend: (obj) ->
    return unless obj?

    if typeof obj is 'function'
      return unless obj.name?
      @::_includedClasses.push(obj)
      @[obj.name] = obj
    else if typeof cls is 'object'
      for key, val of obj when key not in ['included', 'extended']
        @[key] = val
      obj.extended?.call(@)

  @include: (obj) ->
    return unless obj? and typeof obj is 'object'

    for key, val of obj when key not in ['included', 'extended']
      @::[key] = val
    obj.included?.call(@)

  _includedClasses: []

  _init: ->

  constructor: (opts) ->
    $.extend @opts, opts

    @_init()

    for cls in @_includedClasses
      name = cls.name.charAt(0).toLowerCase() + cls.name.slice(1)
      @[name] = new cls(@)

  on: (args...) ->
    $(@).on args...

  trigger: (args...) ->
    $(@).trigger args...

  triggerHandler: (args...) ->
    $(@).triggerHandler args...

  destroy: ->

window.Widget = Widget
