
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
    if @active and @node?.is('[rel=nofollow]')
      @setLink()
    else if @active and !@editor.selection.rangeAtEndOf(@node)
      @popover.show @node
      if @node.attr('href') isnt ""
        @popoverStatus = 3
      else if @withLinkText
        @popoverStatus = 2
      else
        @popoverStatus = 1
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
      @$link = $('<a/>', {
        href: '',
        target: '_blank',
        text: linkText || @_t('linkText')
      })

      if @editor.selection.blockNodes().length > 0
        range.insertNode @$link[0]
      else
        $newBlock = $('<p/>').append(@$link)
        range.insertNode $newBlock[0]

      range.selectNodeContents @$link[0]

      @popover.one 'popovershow', =>
        if linkText
          @popover.urlEl.focus()
          @popover.urlEl[0].select()
          @withLinkText = true
        else
          @popover.textEl.focus()
          @popover.textEl[0].select()
          @withLinkText = false

    @editor.selection.range range
    @editor.trigger 'valuechanged'

  setLink: ->
    text = @node.text()
    href = @node.attr('href')
    if href isnt text
      text = 'http://' + text if text and !/https?:\/\/|^\//ig.test(text)
      @node.attr('href', text)


class LinkPopover extends Popover

  render: ->
    tpl = """
    <div class="popover link-settings">
      <header class="popover-header">
        <h3 class="popover-title">#{ @_t 'linkTextTitle' }</h3>
        <a class="popover-close-handler icon icon-remove"></a>
      </header>
      <div class="popover-content">
        <div class="item">
          <input class="link-text form-control" type="text" placeholder="#{ @_t 'linkText' }"/>
        </div>
        <div class="item">
          <textarea class="link-url form-control" type="text" placeholder="#{ @_t 'linkUrl' }"></textarea>
        </div>
        <div class="item">
          <button type='submit' class="btn btn-primary btn-confirm disabled">
            #{ @_t 'linkUrlSubmit' }
          </button>
        </div>
      </div>
    </div>
    """
    @el.addClass('link-popover')
      .append(tpl)
    @textEl = @el.find '.link-text'
    @urlEl = @el.find '.link-url'
    @unlinkEl = @el.find '.btn-unlink'
    @selectTarget = @el.find '.link-target'
    @confirm = @el.find '.btn-confirm'
    @close = @el.find '.popover-close-handler'

    @textEl.on 'keyup', (e) =>
      return if e.which == 13
      @target.text @textEl.val()
      @editor.inputManager.throttledValueChanged()
      @checkButtonStatus()

    @urlEl.on 'keyup', (e) =>
      return if e.which == 13
      @checkButtonStatus()

    $([@urlEl[0], @textEl[0]]).on 'keydown', (e) =>
      if e.which == 13 or e.which == 27 or
          (!e.shiftKey and e.which == 9 and $(e.target).hasClass('link-url'))
        e.preventDefault()
        range = document.createRange()
        @editor.selection.setRangeAfter @target, range
        @hide()
        @editor.inputManager.throttledValueChanged()

    @confirm.on 'click', (e) =>
      return if e.which == 13
      if @confirm.hasClass('disabled')
        if @textEl.val()
          @urlEl.trigger('focus')
        else
          @textEl.trigger('focus')
        return
      val = @urlEl.val()
      val = 'http://' + val unless /https?:\/\/|^\//ig.test(val) or !val

      @checkButtonStatus()
      @target.attr 'href', val
      @target.text @textEl.val()
      @editor.inputManager.throttledValueChanged()
      @active = true
      @hide()

    @close.on 'click', (e) =>
      @editor.inputManager.throttledValueChanged()
      switch @button.popoverStatus
        when 1
          @button.node.remove()
        when 2
          txtNode = document.createTextNode @target.text()
          @target.replaceWith txtNode

      @active = true
      @hide()

  checkButtonStatus: (val1, val2)->
    val1 or= @textEl.val()
    val2 or= @urlEl.val()
    val2 = 'http://' + val2 unless /https?:\/\/|^\//ig.test(val2) or !val2

    @confirm[if val1 and val2 then 'removeClass' else 'addClass']('disabled')

  show: (args...) ->
    super args...
    val1 = @target.text()
    @textEl.val val1
    @val = @target.attr('href')
    @urlEl.val @val
    @checkButtonStatus(val1, @val)

    @active = false



Simditor.Toolbar.addButton LinkButton
