
class Widget

  @extend: (opts) ->
    for key, val of opts
      if key is '_load'
        @::_loadCallbacks.push val
      else if key is '_init'
        @::_initCallbacks.push val
      else if key is 'opts'
        $.extend(@::_extendOpts, val)
      else if key not in ['_loadCallbacks', '_initCallbacks', 'opts']
        @::[key] = val

  _loadCallbacks: []

  _initCallbacks: []

  _extendOpts: {}

  _load: ->

  _init: ->

  opts: {}

  constructor: (opts) ->
    $.extend @opts, @_extendOpts, opts

    @_load(@opts)
    load.call(this) for load in @_loadCallbacks

    @_init(@opts)
    init.call(this) for init in @_initCallbacks

  on: (args...) ->
    $(this).on args...

  trigger: (args...) ->
    $(this).trigger args...

  triggerHandler: (args...) ->
    $(this).triggerHandler args...

  destroy: ->
