
class ListButton extends Button

  type: ''

  disableTag: 'pre, table'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled
    return @active unless $node?

    anotherType = if @type == 'ul' then 'ol' else 'ul'
    if $node.is anotherType
      @setActive false
      return true
    else
      @setActive $node.is(@htmlTag)
      return @active

  command: (param) ->
    range = @editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = @editor.util.closestBlockEl(startNode)
    $endBlock = @editor.util.closestBlockEl(endNode)

    @editor.selection.save()

    range.setStartBefore $startBlock[0]
    range.setEndAfter $endBlock[0]

    if $startBlock.is('li') and $endBlock.is('li')
      $furthestStart = @editor.util.furthestNode $startBlock, 'ul, ol'
      $furthestEnd = @editor.util.furthestNode $endBlock, 'ul, ol'
      if $furthestStart.is $furthestEnd
        getListLevel = ($li) ->
          lvl = 1
          while !$li.parent().is $furthestStart
            lvl += 1
            $li = $li.parent()
          return lvl

        startLevel = getListLevel $startBlock
        endLevel = getListLevel $endBlock

        if startLevel > endLevel
          $parent = $endBlock.parent()
        else
          $parent = $startBlock.parent()

        range.setStartBefore $parent[0]
        range.setEndAfter $parent[0]
      else
        range.setStartBefore $furthestStart[0]
        range.setEndAfter $furthestEnd[0]

    $contents = $(range.extractContents())

    results = []
    $contents.children().each (i, el) =>
      converted = @_convertEl el
      for c in converted
        if results.length and results[results.length - 1].is(@type) and c.is(@type)
          results[results.length - 1].append(c.children())
        else
          results.push(c)

    range.insertNode node[0] for node in results.reverse()
    @editor.selection.restore()

    @editor.trigger 'valuechanged'

  _convertEl: (el) ->
    $el = $(el)
    results = []
    anotherType = if @type == 'ul' then 'ol' else 'ul'
    
    if $el.is @type
      $el.children('li').each (i, li) =>
        $li = $(li)
        $childList = $li.children('ul, ol').remove()
        block = $('<p/>').append($(li).html() || @editor.util.phBr)
        results.push block
        results.push $childList if $childList.length > 0
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
      block.find('li').append($el.html() || @editor.util.phBr)
      results.push(block)

    results


class OrderListButton extends ListButton
  type: 'ol'
  name: 'ol'
  icon: 'list-ol'
  htmlTag: 'ol'
  shortcut: 'cmd+/'
  _init: ->
    if @editor.util.os.mac
      @title = @title + ' ( Cmd + / )'
    else
      @title = @title + ' ( ctrl + / )'
      @shortcut = 'ctrl+/'
    super()

class UnorderListButton extends ListButton
  type: 'ul'
  name: 'ul'
  icon: 'list-ul'
  htmlTag: 'ul'
  shortcut: 'cmd+.'
  _init: ->
    if @editor.util.os.mac
      @title = @title + ' ( Cmd + . )'
    else
      @title = @title + ' ( Ctrl + . )'
      @shortcut = 'ctrl+.'
    super()

Simditor.Toolbar.addButton OrderListButton
Simditor.Toolbar.addButton UnorderListButton

