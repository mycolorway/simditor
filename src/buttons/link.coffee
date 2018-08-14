
class LinkButton extends Button

  name: 'link'

  icon: 'link'

  htmlTag: 'a'

  disableTag: 'pre'

  render: (args...) ->
    super args...
    @popover = new LinkPopover
      button: @

  _status: ->
    super()

    if @active and !@editor.selection.rangeAtEndOf(@node)
      @popover.show @node
    else
      @popover.hide()

  command: ->
    range = @editor.selection.range()

    if @active
      txtNode = document.createTextNode @node.text()
      @node.replaceWith txtNode
      range.selectNode txtNode
    else
      $contents = $(range.extractContents())
      linkText = @editor.formatter.clearHtml($contents.contents(), false)
      $link = $('<a/>', {
        href: '',
        target: '_blank',
        text: linkText || @_t('linkText')
      })

      if @editor.selection.blockNodes().length > 0
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

    @editor.selection.range range
    @editor.trigger 'valuechanged'


class LinkPopover extends Popover

  render: ->
    tpl = """
    <div class="link-settings">
      <div class="settings-field">
        <label>#{ @_t 'linkText' }</label>
        <input class="link-text" type="text"/>
        <a class="btn-unlink" href="javascript:;" title="#{ @_t 'removeLink' }"
          tabindex="-1">
          <span class="simditor-icon simditor-icon-unlink"></span>
        </a>
      </div>
      <div class="settings-field">
        <label>#{ @_t 'linkUrl' }</label>
        <input class="link-url" type="text"/>
      </div>
      <div class="settings-field">
        <label>#{ @_t 'linkTarget'}</label>
        <select class="link-target">
          <option value="_blank">#{ @_t 'openLinkInNewWindow' } (_blank)</option>
          <option value="_self">#{ @_t 'openLinkInCurrentWindow' } (_self)</option>
        </select>
      </div>
    </div>
    """
    @el.addClass('link-popover')
      .append(tpl)
    @textEl = @el.find '.link-text'
    @urlEl = @el.find '.link-url'
    @unlinkEl = @el.find '.btn-unlink'
    @selectTarget = @el.find '.link-target'

    @textEl.on 'keyup', (e) =>
      return if e.which == 13
      @target.text @textEl.val()
      @editor.inputManager.throttledValueChanged()

    @urlEl.on 'keyup', (e) =>
      return if e.which == 13

      val = @urlEl.val()
      val = 'http://' + val unless /^(http|https|ftp|ftps|file)?:\/\/|^(mailto|tel)?:|^\//ig.test(val) or !val

      @target.attr 'href', val
      @editor.inputManager.throttledValueChanged()

    $([@urlEl[0], @textEl[0]]).on 'keydown', (e) =>
      if e.which == 13 or e.which == 27 or
          (!e.shiftKey and e.which == 9 and $(e.target).hasClass('link-url'))
        e.preventDefault()
        range = document.createRange()
        @editor.selection.setRangeAfter @target, range
        @hide()
        @editor.inputManager.throttledValueChanged()

    @unlinkEl.on 'click', (e) =>
      txtNode = document.createTextNode @target.text()
      @target.replaceWith txtNode
      @hide()

      range = document.createRange()
      @editor.selection.setRangeAfter txtNode, range
      @editor.inputManager.throttledValueChanged()

    @selectTarget.on 'change', (e) =>
      @target.attr 'target', @selectTarget.val()
      @editor.inputManager.throttledValueChanged()

  show: (args...) ->
    super args...
    @textEl.val @target.text()
    @urlEl.val @target.attr('href')



Simditor.Toolbar.addButton LinkButton
