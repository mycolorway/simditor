
class HrButton extends Button

  name: 'hr'

  icon: 'minus'

  htmlTag: 'hr'

  _status: ->

  command: ->
    $rootBlock = @editor.selection.rootNodes().first()
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
