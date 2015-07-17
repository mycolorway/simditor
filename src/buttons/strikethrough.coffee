
class StrikethroughButton extends Button

  name: 'strikethrough'

  icon: 'strikethrough'

  htmlTag: 'strike'

  disableTag: 'pre'

  _activeStatus: ->
    active = document.queryCommandState('strikethrough') is true
    @setActive active
    @active

  command: ->
    document.execCommand 'strikethrough'
    unless @editor.util.support.oninput
      @editor.trigger 'valuechanged'

    # strikethrough command won't trigger selectionchange event automatically
    $(document).trigger 'selectionchange'


Simditor.Toolbar.addButton StrikethroughButton
