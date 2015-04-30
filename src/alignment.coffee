class Alignment extends SimpleModule

  @pluginName: 'Alignment'

  _init: ->
    @editor = @_module

  _command: (position, targetTag="p") ->
    range = @editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = @editor.util.closestBlockEl(startNode)
    $endBlock = @editor.util.closestBlockEl(endNode)

    @editor.selection.save()

    $blockEls =
      if $startBlock.is $endBlock 
        $startBlock
      else
        $startBlock.nextUntil($endBlock).addBack().add $endBlock

    for block in $blockEls.filter(targetTag)
      $(block).attr('data-align', position).data('align', position)

    @editor.selection.restore()
    @editor.trigger 'valuechanged'

  center: (targetTag) ->
    @_command "center", targetTag

  left: (targetTag) ->
    @_command "left", targetTag

  right: (targetTag) ->
    @_command "right", targetTag
