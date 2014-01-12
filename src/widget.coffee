
class Widget

  @extend: (opts) ->
    for key, val of opts
      if key is '_load'
        @::_loadCallbacks.push val
      else if key is '_init'
        @::_initCallbacks.push val
      else if key not in ['_loadCallbacks', '_initCallbacks', 'opts']
        @::[key] = val

  _loadCallbacks: []

  _initCallbacks: []

  opts: {}

  constructor: (opts) ->
    $.extend @opts, opts

    @load(@opts)
    load.call(this) for load in @_loadCallbacks

    @init(@opts)
    init.call(this) for init in @_initCallbacks

  on: (args...) ->
    $(this).on args...

  trigger: (args...) ->
    $(this).trigger args...

  triggerHandler: (args...) ->
    $(this).triggerHandler args...

  destroy: ->
