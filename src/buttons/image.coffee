
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

  constructor: (args...) ->
    super args...

    @defaultImage = @editor.opts.defaultImage
    @maxWidth = @editor.body.width()
    @maxHeight = $(window).height()

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
        @popover.hide()
        $imgWrapper.removeClass('selected')
      else
        @editor.body.blur()
        @editor.body.find('.simditor-image').removeClass('selected')
        $imgWrapper.addClass('selected').focus()
        $img = $imgWrapper.find('img')
        $imgWrapper.width $img.width()
        $imgWrapper.height $img.height()
        @popover.show $imgWrapper

      false

    @editor.body.on 'click', '.simditor-image', (e) =>
      false

    @editor.on 'selectionchanged', =>
      @popover.hide() if @popover.active

    @editor.body.on 'keydown', '.simditor-image', (e) =>
      return unless e.which == 8
      @popover.hide()
      $(e.currentTarget).remove()
      @editor.trigger 'valuechanged'
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
        'data-origin-name': src,
        'data-origin-src': src,
        'data-origin-size': width + ',' + height
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
          <input type="file" title="上传图片" name="upload_file" accept="image/*">
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

    @_initUploader()

  _initUploader: ->
    unless @editor.uploader?
      @el.find('.btn-upload').remove()
      return

    @input = @el.find 'input:file'

    @input.on 'click mousedown', (e) =>
      e.stopPropagation()

    @input.on 'change', (e) =>
      @editor.uploader.upload(@input, {
        inline: true
      })
      @input.val ''

    @editor.uploader.on 'beforeupload', (e, file) =>
      return unless file.inline

      if @target
        $img = @target.find("img")
      else
        $img = @button.createImage()
        $img.mousedown()

      @editor.uploader.readImageFile file.obj, (img) =>
        prepare = () =>
          @srcEl.val('正在上传...')
          @target.append '<div class="mask"></div>'
          $bar = $('<div class="simditor-image-progress-bar"><div><span></span></div></div>').appendTo @target
          $bar.text('正在上传').addClass('hint') unless @editor.uploader.html5

        if img
          @button.loadImage $img, img.src, () =>
            @refresh()
            prepare()
        else
          prepare()

    @editor.uploader.on 'uploadprogress', (e, file, loaded, total) =>
      return unless file.inline

      percent = loaded / total

      if percent > 0.99
        percent = "正在处理";
        @target.find(".simditor-image-progress-bar").text(percent).addClass('hint')
      else
        percent = (percent * 100).toFixed(0) + "%"
        @target.find(".simditor-image-progress-bar span").width(percent)

    @editor.uploader.on 'uploadsuccess', (e, file, result) =>
      return unless file.inline

      $img = @target.find("img")
      @button.loadImage $img, result.file_path, () =>
        @target.find(".mask, .simditor-image-progress-bar").remove()
        @srcEl.val result.file_path
        @editor.trigger 'valuechanged'

    @editor.uploader.on 'uploaderror', (e, file, xhr) =>
      return if xhr.statusText == 'abort'

      $img = @target.find("img")
      @target.find(".mask, .simditor-image-progress-bar").remove()
      @button.loadImage $img, @button.defaultImage, =>
        @editor.trigger 'valuechanged'

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


  show: (args...) ->
    super args...
    $img = @target.find('img')
    @srcEl.val $img.attr('src')


Simditor.Toolbar.addButton(ImageButton)


