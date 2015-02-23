
class LinkButton extends Button

  name: 'link'

  icon: 'link'

  htmlTag: 'a'

  disableTag: 'pre'

  render: (args...) ->
    super args...
    @popover = new LinkPopover
      button: @

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

    return @active unless $node?

    showPopover = true
    if !$node.is(@htmlTag) or $node.is('[class^="simditor-"]')
      @setActive false
      showPopover = false
    else if @editor.selection.rangeAtEndOf($node)
      @setActive true
      showPopover = false
    else
      @setActive true

    if showPopover
      @popover.show($node)
    else if @editor.util.isBlockNode($node)
      @popover.hide()

    @active

  command: ->
    range = @editor.selection.getRange()

    if @active
      $link = $(range.commonAncestorContainer).closest('a')
      txtNode = document.createTextNode $link.text()
      $link.replaceWith txtNode
      range.selectNode txtNode
    else
      startNode = range.startContainer
      endNode = range.endContainer
      $startBlock = @editor.util.closestBlockEl(startNode)
      $endBlock = @editor.util.closestBlockEl(endNode)

      $contents = $(range.extractContents())
      linkText = @editor.formatter.clearHtml($contents.contents(), false)
      $link = $('<a/>', {
        href: 'http://www.example.com',
        target: '_blank',
        text: linkText || @_t('linkText')
      })

      if $startBlock[0] == $endBlock[0]
        range.insertNode $link[0]
      else
        $newBlock = $('<p/>').append($link)
        range.insertNode $newBlock[0]

      range.selectNodeContents $link[0]

      @popover.one 'popovershow', =>
        if linkText
          @popover.urlEl.focus()
          @popover.urlEl[0].select()
        else
          @popover.textEl.focus()
          @popover.textEl[0].select()

    @editor.selection.selectRange range
    @editor.trigger 'valuechanged'


class LinkPopover extends Popover

  render: ->
    tpl = """
      <div class="link-settings">
        <div class="settings-field">
          <label>#{ @_t 'text' }</label>
          <input class="link-text" type="text"/>
          <a class="btn-unlink" href="javascript:;" title="#{ @_t 'removeLink' }" tabindex="-1"><span class="simditor-icon simditor-icon-unlink"></span></a>
        </div>
        <div class="settings-field">
          <label>#{ @_t 'linkUrl' }</label>
          <input class="link-url" type="text"/>
        </div>
      </div>
    """
    @el.addClass('link-popover')
      .append(tpl)
    @textEl = @el.find '.link-text'
    @urlEl = @el.find '.link-url'
    @unlinkEl = @el.find '.btn-unlink'

    @textEl.on 'keyup', (e) =>
      return if e.which == 13
      @target.text @textEl.val()

    @urlEl.on 'keyup', (e) =>
      return if e.which == 13

      val = @urlEl.val()
      val = 'http://' + val unless /https?:\/\/|^\//ig.test(val) or !val

      @target.attr 'href', val

    $([@urlEl[0], @textEl[0]]).on 'keydown', (e) =>
      if e.which == 13 or e.which == 27 or (!e.shiftKey and e.which == 9 and $(e.target).hasClass('link-url'))
        e.preventDefault()
        setTimeout =>
          range = document.createRange()
          @editor.selection.setRangeAfter @target, range
          @hide()
          @editor.trigger 'valuechanged'
        , 0

    @unlinkEl.on 'click', (e) =>
      txtNode = document.createTextNode @target.text()
      @target.replaceWith txtNode
      @hide()

      range = document.createRange()
      @editor.selection.setRangeAfter txtNode, range
      @editor.trigger 'valuechanged'

  show: (args...) ->
    super args...
    @textEl.val @target.text()
    @urlEl.val @target.attr('href')



Simditor.Toolbar.addButton LinkButton

