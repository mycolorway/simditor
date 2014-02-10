
class LinkButton extends Button

  name: 'link'

  icon: 'link'

  title: '插入链接'

  htmlTag: 'a'

  disableTag: 'pre'

  render: (args...) ->
    super args...
    @popover = new LinkPopover(@toolbar.editor)

  status: ($node) ->
    super $node

    if @active
      @popover.show($node)
    else
      @popover.hide()

    @active

  command: ->
    editor =  @toolbar.editor
    range = editor.selection.getRange()

    if @active
      $link = $(range.commonAncestorContainer).closest('a')
      txtNode = document.createTextNode $link.text()
      $link.replaceWith txtNode
      range.selectNode txtNode
    else
      startNode = range.startContainer
      endNode = range.endContainer
      $startBlock = editor.util.closestBlockEl(startNode)
      $endBlock = editor.util.closestBlockEl(endNode)

      $contents = $(range.extractContents())
      $link = $('<a/>', {
        href: 'http://www.example.com',
        target: '_blank',
        text: editor.formatter.clearHtml($contents.contents(), false) || '链接文字'
      })

      if $startBlock[0] == $endBlock[0]
        range.insertNode $link[0]
      else
        $newBlock = $('<p/>').append($link)
        range.insertNode $newBlock[0]

      range.selectNodeContents $link[0]

    editor.selection.selectRange range

    @popover.one 'popovershow', =>
      @popover.el.find('.link-text').focus()
      @popover.textEl.focus()
      @popover.textEl[0].select()

    @toolbar.editor.trigger 'valuechanged'
    @toolbar.editor.trigger 'selectionchanged'


class LinkPopover extends Popover

  _tpl: """
    <div class="link-settings">
      <div class="settings-field">
        <label>文本</label>
        <input class="link-text" type="text"/>
      </div>
      <div class="settings-field">
        <label>链接</label>
        <input class="link-url" type="text"/>
      </div>
    </div>
  """

  render: ->
    @el.addClass('link-popover')
      .append(@_tpl)
    @textEl = @el.find '.link-text'
    @urlEl = @el.find '.link-url'

    @textEl.on 'keyup', (e) =>
      return if e.which == 13
      @target.text @textEl.val()

    @urlEl.on 'keyup', (e) =>
      return if e.which == 13
      @target.attr 'href', @urlEl.val()

    $([@urlEl[0], @textEl[0]]).on 'keydown', (e) =>
      if e.which == 13 or e.which == 27
        setTimeout =>
          range = document.createRange()
          @editor.selection.setRangeAfter @target, range
          @editor.body.focus()
          @hide()
        , 0

  show: (args...) ->
    super args...
    @textEl.val @target.text()
    @urlEl.val @target.attr('href')



Simditor.Toolbar.addButton(LinkButton)

