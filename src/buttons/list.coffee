
class ListButton extends Button

  type: ''

  command: (param) ->
    super()
    editor =  @toolbar.editor
    range = editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = editor.util.closestBlockEl(startNode)
    $endBlock = editor.util.closestBlockEl(endNode)

    editor.selection.save()

    range.setStartBefore $startBlock[0]
    range.setEndAfter $endBlock[0]

    if $startBlock.is('li') and $endBlock.is('li') and $startBlock.parent()[0] == $endBlock.parent()[0]
      $breakedEl = $startBlock.parent()

    $contents = $(range.extractContents())

    if $breakedEl?
      $contents.wrapInner('<' + $breakedEl[0].tagName + '/>')
      if editor.selection.rangeAtStartOf $breakedEl, range
        range.setEndBefore($breakedEl[0])
        range.collapse()
      else if editor.selection.rangeAtEndOf $breakedEl, range
        range.setEndAfter($breakedEl[0])
        range.collapse()
      else
        $breakedEl = editor.selection.breakBlockEl($breakedEl, range)
        range.setEndBefore($breakedEl[0])
        range.collapse()

    results = []
    $contents.children().each (i, el) =>
      converted = @_convertEl el
      for c in converted
        if results.length and results[results.length - 1].is(@type) and c.is(@type)
          results[results.length - 1].append(c.children())
        else
          results.push(c)

    range.insertNode node[0] for node in results.reverse()
    editor.selection.restore()

    @toolbar.editor.trigger 'valuechanged'
    @toolbar.editor.trigger 'selectionchanged'

  _convertEl: (el) ->
    editor = @toolbar.editor
    $el = $(el)
    results = []
    anotherType = if @type == 'ul' then 'ol' else 'ul'
    
    if $el.is @type
      $el.find('li').each (i, li) =>
        block = $('<p/>').append($(li).html() || editor.util.phBr)
        results.push(block)
    else if $el.is anotherType
      block = $('<' + @type + '/>').append($el.html())
      results.push(block)
    else if $el.is 'blockquote'
      children = @_convertEl child for child in $el.children().get()
      $.merge results, children
    else if $el.is 'table'
      # TODO
    else
      block = $('<' + @type + '><li></li></' + @type + '>')
      block.find('li').append($el.html() || editor.util.phBr)
      results.push(block)

    results


class OrderListButton extends ListButton
  type: 'ol'
  name: 'ol'
  title: '有序列表'
  icon: 'list-ol'
  htmlTag: 'ol'

class UnorderListButton extends ListButton
  type: 'ul'
  name: 'ul'
  title: '无序列表'
  icon: 'list-ul'
  htmlTag: 'ul'

Simditor.Toolbar.addButton(OrderListButton)
Simditor.Toolbar.addButton(UnorderListButton)

