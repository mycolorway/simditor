
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
      if width > @maxWidth
        width = @maxWidth
        height = @maxWidth * img.height / img.width
      else
        width = img.width
        height = img.height

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
          <input type="file" title="上传图片" name="upload_file" >
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
    @input = @el.find 'input[name=upload_file]'

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

    @input.on 'click mousedown', (e) =>
      e.stopPropagation()

    @_initUploader()

  _initUploader: ->

    @input.on 'change', (e) =>
      @editor.uploader.upload(@input, {
        inlineImage: true
      })
      @input.val ''

    @editor.uploader.on 'beforeupload', (e, file) =>
      return unless file.inlineImage

      $img = @target.find("img")
      @editor.uploader.readImageFile file.obj, (img) =>
        if img
          @button.loadImage $img, img.src, (success) =>
            return unless success
            @refresh()
            @editor.trigger 'valuechanged'

          @target.append '<div class="mask"></div>'
          $bar = @target.append '<div class="simditor-image-progress-bar"><div><span></span></div></div>'

          if not @editor.uploader.html5
            $bar.text('正在上传...').addClass('hint')

        else
          if simple? && simple.message?
            simple.message("请选择JPG，JPEG，PNG，GIF或ICO格式的图片文件")
          else
            alert("请选择JPG，JPEG，PNG，GIF或ICO格式的图片文件")

          return false


    @editor.uploader.on 'uploadprogress', (e, file, loaded, total) =>
      return unless file.inlineImage

      percent = loaded / total

      if percent > 0.99
        percent = "正在处理...";
        @target.find(".simditor-image-progress-bar").text(percent).addClass('hint')
      else
        percent = (percent * 100).toFixed(0) + "%"
        @target.find(".simditor-image-progress-bar span").width(percent)

    @editor.uploader.on 'uploadsuccess', (e, file, result) =>
      return unless file.inlineImage

      $img = @target.find("img")

      @target.find(".mask, .simditor-image-progress-bar").remove()
      @srcEl.val result.file_path
      @button.loadImage $img, result.file_path, (success) =>
        return unless success
        @editor.trigger 'valuechanged'

    @editor.uploader.on 'uploadcomplete', (e, file, result) =>
      return unless file.inlineImage

    @editor.uploader.on 'uploaderror', (e, file, xhr) =>
      return if xhr.statusText == 'abort'

      @target.find(".mask, .simditor-image-progress-bar").remove()

      if xhr.responseText
        result = $.parseJSON(xhr.responseText)


  show: (args...) ->
    super args...
    $img = @target.find('img')
    @srcEl.val $img.attr('src')


Simditor.Toolbar.addButton(ImageButton)


