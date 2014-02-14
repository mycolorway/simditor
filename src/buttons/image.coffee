
class ImageButton extends Button

  _wrapperTpl: """
    <div class="simditor-image" contenteditable="false">
      <div class="simditor-image-resize-handle right"></div>
      <div class="simditor-image-resize-handle bottom"></div>
      <div class="simditor-image-resize-handle right-bottom"></div>
    </div>
  """

  name: 'image'

  icon: 'picture-o'

  title: '插入图片'

  htmlTag: 'img'

  disableTag: 'pre, a, b, strong, i, u, table'

  defaultImage: ''

  maxWidth: 0

  constructor: (args...) ->
    super args...

    @defaultImage = @editor.opts.defaultImage
    @maxWidth = @editor.wrapper.width()

    @editor.on 'decorate', (e, $el) =>
      $el.find('img').each (i, img) =>
        @decorate $(img)

    @editor.on 'undecorate', (e, $el) =>
      $el.find('img').each (i, img) =>
        @undecorate $(img)

    @editor.body.on 'mousedown', '.simditor-image', (e) =>
      @editor.body.blur()
      @editor.body.find('.simditor-image').removeClass('selected')
      $img = $(e.currentTarget).addClass('selected').focus()
      @popover.show $img
      false

    @editor.on 'selectionchanged', =>
      @popover.hide()

    $(document).on 'keydown.simditor-' + @editor.id, (e) =>
      $img = @editor.body.find('.simditor-image.selected')
      if e.which == 8 and $img.length > 0
        @popover.hide()
        $img.remove()
        return false

  render: (args...) ->
    super args...
    @popover = new ImagePopover(@)

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

  decorate: ($img) ->
    $wrapper = $img.parent('.simditor-image')
    return if $wrapper.length > 0

    $wrapper = $(@_wrapperTpl)
      .insertBefore($img)
      .prepend($img)

  undecorate: ($img) ->
    $wrapper = $img.parent('.simditor-image')
    return if $wrapper.length < 1

    $img.insertAfter $wrapper
    $wrapper.remove()

  loadImage: ($img, src, callback) ->
    $wrapper = $img.parent('.simditor-image')
    img = new Image()

    img.onload = =>
      if width > @maxWidth
        width = @maxWidth
        height = @maxWidth * img.height / img.width
      else
        width = img.width
        height = img.height

      $img.attr({
        src: src,
        width: width,
        height: height
      })

      $wrapper.width(width)
        .height(height)

      callback(true)

    img.onerror = =>
      callback(false)

    img.src = src

  command: ->
    range = @editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = @editor.util.closestBlockEl(startNode)
    $endBlock = @editor.util.closestBlockEl(endNode)

    range.deleteContents()

    if $startBlock[0] == $endBlock[0] and $startBlock.is('p')
      if @editor.util.isEmptyNode $startBlock
        range.selectNode $startBlock[0]
        range.deleteContents()
      else if @editor.selection.rangeAtEndOf $startBlock, range
        range.setEndAfter($startBlock[0])
        range.collapse(false)
      else if @editor.selection.rangeAtStartOf $startBlock, range
        range.setEndBefore($startBlock[0])
        range.collapse(false)
      else
        $breakedEl = @editor.selection.breakBlockEl($startBlock, range)
        range.setEndBefore($breakedEl[0])
        range.collapse(false)

    $img = $('<img/>')
    range.insertNode $img[0]
    @decorate $img

    @loadImage $img, @defaultImage, =>
      @editor.trigger 'valuechanged'
      #@editor.trigger 'selectionchanged'
      $img.mousedown()

      setTimeout =>
        @popover.srcEl.focus()
        @popover.srcEl[0].select()



class ImagePopover extends Popover

  _tpl: """
    <div class="link-settings">
      <div class="settings-field">
        <label>地址</label>
        <input class="image-src" type="text"/>
      </div>
      <div class="settings-field">
        <label>标题</label>
        <input class="image-title" type="text"/>
      </div>
    </div>
  """

  offset:
    top: 6
    left: -4

  constructor: (@button) ->
    super @button.editor

  render: ->
    @el.addClass('image-popover')
      .append(@_tpl)
    @srcEl = @el.find '.image-src'
    @titleEl = @el.find '.image-title'

    @srcEl.on 'keyup', (e) =>
      return if e.which == 13
      clearTimeout @timer if @timer

      @timer = setTimeout =>
        src = @srcEl.val()
        $img = @target.find('img')
        @button.loadImage $img, src, (success) =>
          return unless success
          @refresh()
          @editor.trigger 'valuechanged'
      , 200

    @titleEl.on 'keyup', (e) =>
      return if e.which == 13
      @target.find('img').attr 'title', @titleEl.val()

    $([@srcEl[0], @titleEl[0]]).on 'keydown', (e) =>
      if e.which == 13 or e.which == 27 or (e.which == 9 and $(e.target).hasClass('image-title'))
        e.preventDefault()
        @target.removeClass('selected')
        @hide()
        #setTimeout =>
          #$nextBlock = @target.next()
          #range = document.createRange()
          #@editor.selection.setRangeAtStartOf @target.next(), range
          #@editor.body.focus()
        #, 0

  show: (args...) ->
    super args...
    $img = @target.find('img')
    @srcEl.val $img.attr('src')
    @titleEl.val $img.attr('title')

  #hide: ->
    #super()
    #@srcEl.blur()
    #@titleEl.blur()


Simditor.Toolbar.addButton(ImageButton)


