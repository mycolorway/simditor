
class Module

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

  on: (args...) ->
    $(@).on args...

  one: (args...) ->
    $(@).one args...

  off: (args...) ->
    $(@).off args...

  trigger: (args...) ->
    $(@).trigger args...

  triggerHandler: (args...) ->
    $(@).triggerHandler args...


class Widget extends Module

  @connect: (cls) ->
    return unless typeof cls is 'function'
    @::_connectedClasses.push(cls)
    @[cls.name] = cls if cls.name

  _connectedClasses: []

  _init: ->

  opts: {}

  constructor: (opts) ->
    $.extend @opts, opts


    instances = for cls in @_connectedClasses
      name = cls.name.charAt(0).toLowerCase() + cls.name.slice(1)
      @[name] = new cls(@)

    @_init()

    instance._init?() for instance in instances

  destroy: ->


class Plugin extends Module

  opts: {}

  constructor: (@widget) ->
    $.extend(@opts, @widget.opts)

  _init: ->


window.Module = Module
window.Widget = Widget
window.Plugin = Plugin


# Hack: IE doesn't support Function.name
if Function::name == undefined && Object.defineProperty != undefined
  Object.defineProperty(Function.prototype, 'name', {
    get: ->
      funcNameRegex = /function\s([^(]{1,})\(/
      results = funcNameRegex.exec(this.toString())
      if results && results.length > 1 then results[1].trim() else ""
    set: (value) ->
  })
