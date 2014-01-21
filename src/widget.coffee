
class Widget
  @extend: (obj) ->
    return unless obj? and typeof obj is 'object'
    for key, val of obj when key not in ['included', 'extended']
      @[key] = val
    obj.extended?.call(@)

  @include: (obj) ->
    return unless obj? and typeof obj is 'object'
    for key, val of obj when key not in ['included', 'extended']
      @::[key] = val
    obj.included?.call(@)

  @connect: (cls) ->
    return unless typeof cls is 'function' and cls.name
    @::_connectedClasses.push(cls)
    @[cls.name] = cls

  _connectedClasses: []

  _init: ->

  constructor: (opts) ->
    $.extend @opts, opts


    instances = for cls in @_connectedClasses
      name = cls.name.charAt(0).toLowerCase() + cls.name.slice(1)
      @[name] = new cls(@)

    @_init()

    instance._init() for instance in instances

  on: (args...) ->
    $(@).on args...

  trigger: (args...) ->
    $(@).trigger args...

  triggerHandler: (args...) ->
    $(@).triggerHandler args...

  destroy: ->

window.Widget = Widget
