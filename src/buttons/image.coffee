
class ImageButton extends Button

  _wrapperTpl: """
    <div class="simditor-image" contenteditable="false" tabindex="-1">
      <div class="simditor-image-resize-handle right"></div>
      <div class="simditor-image-resize-handle bottom"></div>
      <div class="simditor-image-resize-handle right-bottom"></div>
    </div>
  """

  name: 'image'

  icon: 'picture-o'

  title: '插入图片'

  htmlTag: 'img'

  disableTag: 'pre, table'

  defaultImage: ''

  maxWidth: 0

  maxHeight: 0

  menu: [{
    name: 'upload-image',
    text: '本地图片'
  }, {
    name: 'external-image',
    text: '外链图片'
  }]

  constructor: (@editor) ->
    @menu = false unless @editor.uploader?
    super @editor

    @defaultImage = @editor.opts.defaultImage
    @maxWidth = @editor.opts.maxImageWidth || @editor.body.width()
    @maxHeight = @editor.opts.maxImageHeight || $(window).height()

    @editor.on 'decorate', (e, $el) =>
      $el.find('img').each (i, img) =>
        @decorate $(img)

    @editor.on 'undecorate', (e, $el) =>
      $el.find('img').each (i, img) =>
        @undecorate $(img)

    @editor.body.on 'mousedown', '.simditor-image', (e) =>
      $imgWrapper = $(e.currentTarget)

      if $imgWrapper.hasClass 'selected'
        @popover.srcEl.blur()
        $imgWrapper.focus()
      else
        @editor.body.blur()
        @editor.body.find('.simditor-image').removeClass('selected')
        $imgWrapper.addClass('selected').focus()
        @popover.show $imgWrapper

      false

    @editor.body.on 'click', '.simditor-image', (e) =>
      false

    @editor.on 'selectionchanged.image', =>
      range = @editor.selection.getRange()
      return unless range?
      $container = $(range.commonAncestorContainer)

      if range.collapsed and $container.is('.simditor-image')
        $container.mousedown()
      else if @popover.active
        @popover.hide()

    @editor.body.on 'keydown', '.simditor-image', (e) =>
      return unless e.which == 8
      @popover.hide()

      newBlockEl = $('<p/>').append(@editor.util.phBr)
      $(e.currentTarget).replaceWith newBlockEl

      range = document.createRange()
      @editor.selection.setRangeAtStartOf newBlockEl, range
      @editor.trigger 'valuechanged'
      @editor.trigger 'selectionchanged'
      return false

  render: (args...) ->
    super args...
    @popover = new ImagePopover(@)

  renderMenu: ->
    super()

    $uploadItem = @menuEl.find('.menu-item-upload-image')
    $input = null

    createInput = =>
      $input.remove() if $input
      $input = $('<input type="file" title="上传图片" name="upload_file" accept="image/*">')
        .appendTo($uploadItem)

    createInput()

    $uploadItem.on 'click mousedown', 'input[name=upload_file]', (e) =>
      e.stopPropagation()

    $uploadItem.on 'change', 'input[name=upload_file]', (e) =>
      if @editor.inputManager.focused
        @editor.uploader.upload($input, {
          inline: true
        })
        createInput()
      else if @editor.inputManager.lastCaretPosition
        @editor.one 'focus', (e) =>
          @editor.uploader.upload($input, {
            inline: true
          })
          createInput()
        @editor.undoManager.caretPosition @editor.inputManager.lastCaretPosition
      @wrapper.removeClass('menu-on')

    @_initUploader()

  _initUploader: ->
    unless @editor.uploader?
      @el.find('.btn-upload').remove()
      return

    @editor.uploader.on 'beforeupload', (e, file) =>
      return unless file.inline

      if file.imgWrapper
        $img = file.imgWrapper.find("img")
      else
        $img = @createImage()
        $img.mousedown()
        file.imgWrapper = $img.parent '.simditor-image'

      @editor.uploader.readImageFile file.obj, (img) =>
        prepare = () =>
          @popover.srcEl.val('正在上传...')
          file.imgWrapper.append '<div class="mask"></div>'
          $progress = $('<div class="simditor-image-progress"><span></span></div>').appendTo file.imgWrapper
          $progress.addClass('loading') unless @editor.uploader.html5

        if img
          @loadImage $img, img.src, () =>
            @popover.refresh()
            prepare()
        else
          prepare()

    @editor.uploader.on 'uploadprogress', (e, file, loaded, total) =>
      return unless file.inline

      percent = loaded / total
      percent = (percent * 100).toFixed(0)
      percent = 99 if percent > 99

      file.imgWrapper.find(".simditor-image-progress span").text(percent)

      file.imgWrapper.find('.mask').css({
        top: percent + '%',
        height: (100 - percent) + '%'
      })

    @editor.uploader.on 'uploadsuccess', (e, file, result) =>
      return unless file.inline

      $img = file.imgWrapper.find("img")
      @loadImage $img, result.file_path, () =>
        file.imgWrapper.find(".mask, .simditor-image-progress").remove()
        @popover.srcEl.val result.file_path
        @editor.trigger 'valuechanged'

    @editor.uploader.on 'uploaderror', (e, file, xhr) =>
      return unless file.inline
      return if xhr.statusText == 'abort'

      if xhr.responseText
        try
          result = $.parseJSON xhr.responseText
          msg = result.msg
        catch e
          msg = '上传出错了'

        if simple? and simple.message?
          simple.message(msg)
        else
          alert(msg)

      $img = file.imgWrapper.find("img")
      @loadImage $img, @defaultImage, =>
        @popover.refresh()
        @popover.srcEl.val $img.attr('src')
        file.imgWrapper.find(".mask, .simditor-image-progress").remove()
        @editor.trigger 'valuechanged'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

  decorate: ($img) ->
    $parent = $img.parent()
    return if $parent.is('.simditor-image')

    $wrapper = $(@_wrapperTpl)
      .width($img.width())

    if $parent.is('p')
      $wrapper.prepend($img)
        .replaceAll($parent)
    else
      $wrapper.insertBefore($img)
        .prepend($img)

  undecorate: ($img) ->
    $wrapper = $img.parent('.simditor-image')
    return if $wrapper.length < 1

    unless /^data:image/.test($img.attr('src'))
      $('<p/>').append($img).insertAfter($wrapper)
    $wrapper.remove()

  loadImage: ($img, src, callback) ->
    $wrapper = $img.parent('.simditor-image')
    img = new Image()

    img.onload = =>
      width = img.width
      height = img.height
      if width > @maxWidth
        height = @maxWidth * height / width
        width = @maxWidth
      if height > @maxHeight
        width = @maxHeight * width / height
        height = @maxHeight

      $img.attr({
        src: src,
        width: width,
        height: height,
        'data-origin-src': src,
        'data-origin-name': '图片',
        'data-origin-size': img.width + ',' + img.height
      })

      $wrapper.width(width)
        .height(height)

      callback(true)

    img.onerror = =>
      callback(false)

    img.src = src

  createImage: () ->
    range = @editor.selection.getRange()
    startNode = range.startContainer
    endNode = range.endContainer
    $startBlock = @editor.util.closestBlockEl(startNode)
    $endBlock = @editor.util.closestBlockEl(endNode)

    range.deleteContents()

    if $startBlock[0] == $endBlock[0]
      if $startBlock.is 'li'
        $startBlock = @editor.util.furthestNode($startBlock, 'ul, ol')
        $endBlock = $startBlock
        range.setEndAfter($startBlock[0])
        range.collapse(false)
      else if $startBlock.is 'p'
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
    $img

  command: () ->
    $img = @createImage()

    @loadImage $img, @defaultImage, =>
      @editor.trigger 'valuechanged'
      $img.mousedown()

      @popover.one 'popovershow', =>
        @popover.srcEl.focus()
        @popover.srcEl[0].select()


class ImagePopover extends Popover

  _tpl: """
    <div class="link-settings">
      <div class="settings-field">
        <label>图片地址</label>
        <input class="image-src" type="text"/>
        <a class="btn-upload" href="javascript:;" title="上传图片" tabindex="-1">
          <span class="fa fa-upload"></span>
        </a>
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

        @timer = null
      , 200

    @srcEl.on 'keydown', (e) =>
      if e.which == 13 or e.which == 27 or e.which == 9
        e.preventDefault()
        @srcEl.blur()
        @target.removeClass('selected')
        @hide()

    @editor.on 'valuechanged', (e) =>
      @refresh() if @active

    @_initUploader()

  _initUploader: ->
    $uploadBtn = @el.find('.btn-upload')
    unless @editor.uploader?
      $uploadBtn.remove()
      return

    createInput = =>
      @input.remove() if @input
      @input = $('<input type="file" title="上传图片" name="upload_file" accept="image/*">')
        .appendTo($uploadBtn)

    createInput()

    @el.on 'click mousedown', 'input[name=upload_file]', (e) =>
      e.stopPropagation()

    @el.on 'change', 'input[name=upload_file]', (e) =>
      @editor.uploader.upload(@input, {
        inline: true,
        imgWrapper: @target
      })
      createInput()

  show: (args...) ->
    super args...
    $img = @target.find('img')
    @srcEl.val $img.attr('src')


Simditor.Toolbar.addButton(ImageButton)
