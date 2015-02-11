
class StrikethroughButton extends Button

  name: 'strikethrough'

  icon: 'strikethrough'

  htmlTag: 'strike'

  disableTag: 'pre'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

    active = document.queryCommandState('strikethrough') is true
    @setActive active
    active

  command: ->
    document.execCommand 'strikethrough'
    unless @editor.util.support.oninput
      @editor.trigger 'valuechanged'

    # strikethrough command won't trigger selectionchange event automatically
    $(document).trigger 'selectionchange'


Simditor.Toolbar.addButton StrikethroughButton
