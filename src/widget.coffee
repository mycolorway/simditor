
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
    return unless typeof cls is 'function'
    @::_connectedClasses.push(cls)
    @[cls.name] = cls if cls.name

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

# Hack: IE doesn't support Function.name
if Function::name == undefined && Object.defineProperty != undefined
  Object.defineProperty(Function.prototype, 'name', {
    get: ->
      funcNameRegex = /function\s([^(]{1,})\(/
      results = funcNameRegex.exec(this.toString())
      if results && results.length > 1 then results[1].trim() else ""
    set: (value) ->
  })
