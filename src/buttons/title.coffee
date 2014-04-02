
class TitleButton extends Button

  name: 'title'

  title: '标题文字'

  htmlTag: 'h1, h2, h3, h4'

  disableTag: 'pre, table'

  menu: [{
    name: 'normal',
    text: '普通文本',
    param: 'p'
  }, '|', {
    name: 'h1',
    text: '标题 1',
    param: 'h1'
  }, {
    name: 'h2',
    text: '标题 2',
    param: 'h2'
  }, {
    name: 'h3',
    text: '标题 3',
    param: 'h3'
  }]

  setActive: (active, param) ->
    @active = active
    if active
      @el.addClass('active active-' + param)
    else
      @el.removeClass('active active-p active-h1 active-h2 active-h3')

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

    if $node?
      param = $node[0].tagName?.toLowerCase()
      @setActive $node.is(@htmlTag), param
    @active

  command: (param) ->
    range = @editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = @editor.util.closestBlockEl(startNode)
    $endBlock = @editor.util.closestBlockEl(endNode)

    @editor.selection.save()

    range.setStartBefore $startBlock[0]
    range.setEndAfter $endBlock[0]

    $contents = $(range.extractContents())

    results = []
    $contents.children().each (i, el) =>
      converted = @_convertEl el, param
      results.push(c) for c in converted

    range.insertNode node[0] for node in results.reverse()
    @editor.selection.restore()

    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'

  _convertEl: (el, param) ->
    $el = $(el)
    results = []

    if $el.is param
      results.push $el
    else
      $block = $('<' + param + '/>').append($el.contents())
      results.push($block)

    results


Simditor.Toolbar.addButton(TitleButton)

