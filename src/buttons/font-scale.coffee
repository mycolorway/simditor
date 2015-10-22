
class FontScaleButton extends Button

  name: 'fontScale'

  icon: 'font'

  disableTag: 'pre'

  htmlTag: 'span'

  sizeMap:
    'x-large': '1.5em'
    'large': '1.25em'
    'small': '.75em'
    'x-small': '.5em'

  _init: ->
    @menu = [{
      name: '150%'
      text: @_t('fontScaleXLarge')
      param: '5'
    }, {
      name: '125%'
      text: @_t('fontScaleLarge')
      param: '4'
    }, {
      name: '100%'
      text: @_t('fontScaleNormal')
      param: '3'
    }, {
      name: '75%'
      text: @_t('fontScaleSmall')
      param: '2'
    }, {
      name: '50%'
      text: @_t('fontScaleXSmall')
      param: '1'
    }]
    super()

  _activeStatus: ->
    range = @editor.selection.range()
    startNodes = @editor.selection.startNodes()
    endNodes = @editor.selection.endNodes()
    startNode = startNodes.filter('span[style*="font-size"]')
    endNode = endNodes.filter('span[style*="font-size"]')
    active = startNodes.length > 0 and endNodes.length > 0 and startNode.is(endNode)
    @setActive active
    @active

  command: (param)->
    range = @editor.selection.range()
    return if range.collapsed

    # Use span[style] instead of font[size]
    document.execCommand 'styleWithCSS', false, true
    document.execCommand 'fontSize', false, param
    document.execCommand 'styleWithCSS', false, false
    @editor.selection.reset()
    @editor.selection.range()

    containerNode = @editor.selection.containerNode()

    if containerNode[0].nodeType is Node.TEXT_NODE
      $scales = containerNode.closest('span[style*="font-size"]')
    else
      $scales = containerNode.find('span[style*="font-size"]')

    $scales.each (i, n) =>
      $span = $(n)
      size = n.style.fontSize

      if /large|x-large|small|x-small/.test(size)
        $span.css('fontSize', @sizeMap[size])
      else if size is 'medium'
        $span.replaceWith $span.contents()

    @editor.trigger 'valuechanged'

Simditor.Toolbar.addButton FontScaleButton
