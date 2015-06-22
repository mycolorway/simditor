class AlignmentButton extends Button

  name: "alignment"

  icon: 'align-left'

  htmlTag: 'p, h1, h2, h3, h4'

  _init: ->
    @menu = [{
      name: 'left',
      text: @_t('alignLeft'),
      icon: 'align-left',
      param: 'left'
    }, {
      name: 'center',
      text: @_t('alignCenter'),
      icon: 'align-center',
      param: 'center'
    }, {
      name: 'right',
      text: @_t('alignRight'),
      icon: 'align-right',
      param: 'right'
    }]
    super()

  setActive: (active, align = 'left') ->
    align = 'left' unless align in ['left', 'center', 'right']
    if align == 'left'
      super false
    else
      super active

    @el.removeClass 'align-left align-center align-right'
    @el.addClass('align-' + align) if active
    @setIcon 'align-' + align
    @menuEl.find('.menu-item').show().end()
        .find('.menu-item-' + align).hide()

  status: ($node) ->
    return true unless $node?
    return unless @editor.util.isBlockNode $node

    @setDisabled !$node.is(@htmlTag)
    if @disabled
      @setActive false
      return true

    @setActive true, $node.css('text-align')
    @active

  command: (align) ->
    if ['left', 'center', 'right'].indexOf(align) < 0
      throw new Error("invalid #{align}")

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

    for block in $blockEls.filter(@htmlTag)
      $(block).css('text-align', if align == 'left' then '' else align)

    @editor.selection.restore()
    @editor.trigger 'valuechanged'

Simditor.Toolbar.addButton AlignmentButton
