
class HrButton extends Button

  name: 'hr'

  icon: 'minus'

  htmlTag: 'hr'

  status: ($node) ->
    true

  command: ->
    $rootBlock = @editor.util.furthestBlockEl()
    $nextBlock = $rootBlock.next()

    if $nextBlock.length > 0
      @editor.selection.save()
    else
      $newBlock = $('<p/>').append @editor.util.phBr

    $hr = $('<hr/>').insertAfter $rootBlock

    if $newBlock
      $newBlock.insertAfter $hr
      @editor.selection.setRangeAtStartOf $newBlock
    else
      @editor.selection.restore()

    @editor.trigger 'valuechanged'


Simditor.Toolbar.addButton HrButton

