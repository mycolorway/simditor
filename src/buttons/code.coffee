
class CodeButton extends Button

  name: 'code'

  icon: 'code'

  title: '插入代码'

  htmlTag: 'pre'

  disableTag: 'li, table'

  render: (args...) ->
    super args...
    @popover = new CodePopover(@editor)

  status: ($node) ->
    result = super $node

    if @active
      @popover.show($node)
    else if @editor.util.isBlockNode($node)
      @popover.hide()

    result

  command: ->
    range = @editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = @editor.util.closestBlockEl(startNode)
    $endBlock = @editor.util.closestBlockEl(endNode)

    range.setStartBefore $startBlock[0]
    range.setEndAfter $endBlock[0]

    $contents = $(range.extractContents())

    results = []
    $contents.children().each (i, el) =>
      converted = @_convertEl el
      for c in converted
        if results.length and results[results.length - 1].is(@htmlTag) and c.is(@htmlTag)
          results[results.length - 1].append(c.contents())
        else
          results.push(c)

    range.insertNode node[0] for node in results.reverse()
    @editor.selection.setRangeAtEndOf results[0]

    @editor.trigger 'valuechanged'
    @editor.trigger 'selectionchanged'

  _convertEl: (el) ->
    $el = $(el)
    results = []

    if $el.is @htmlTag
      block = $('<p/>').append($el.html().replace('\n', '<br/>'))
      results.push block
    else
      if !$el.text() and $el.children().length == 1 and $el.children().is('br')
        codeStr = '\n'
      else
        codeStr = @editor.formatter.clearHtml($el)
      block = $('<' + @htmlTag + '/>').append(codeStr)
      results.push(block)

    results


class CodePopover extends Popover

  _tpl: """
    <div class="code-settings">
      <div class="settings-field">
        <select class="select-lang">
          <option value="-1">选择程序语言</option>
          <option value="c++">C++</option>
          <option value="css">CSS</option>
          <option value="coffeeScript">CoffeeScript</option>
          <option value="html">Html,XML</option>
          <option value="json">JSON</option>
          <option value="java">Java</option>
          <option value="js">JavaScript</option>
          <option value="markdown">Markdown</option>
          <option value="oc">Objective C</option>
          <option value="php">PHP</option>
          <option value="perl">Perl</option>
          <option value="python">Python</option>
          <option value="ruby">Ruby</option>
          <option value="sql">SQL</option>
        </select>
      </div>
    </div>
  """

  render: ->
    @el.addClass('code-popover')
      .append(@_tpl)
    @selectEl = @el.find '.select-lang'

    @selectEl.on 'change', (e) =>
      lang = @selectEl.val()
      oldLang = @target.attr('data-lang')
      @target.removeClass('lang-' + oldLang)
        .removeAttr('data-lang')

      if @lang isnt -1
        @target.addClass('lang-' + lang) 
        @target.attr('data-lang', lang)

  show: (args...) ->
    super args...
    @lang = @target.attr('data-lang')
    @selectEl.val(@lang) if @lang?


Simditor.Toolbar.addButton(CodeButton)


