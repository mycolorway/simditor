
class ImageButton extends Button

  name: 'image'

  icon: 'picture-o'

  title: '插入图片'

  htmlTag: 'img'

  disableTag: 'pre, table'

  defaultImage: ''

  needFocus: false

  #maxWidth: 0

  #maxHeight: 0

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
    #@maxWidth = @editor.opts.maxImageWidth || @editor.body.width()
    #@maxHeight = @editor.opts.maxImageHeight || $(window).height()

    @editor.body.on 'click', 'img:not([data-non-image])', (e) =>
      $img = $(e.currentTarget)

      #@popover.show $img
      range = document.createRange()
      range.selectNode $img[0]
      @editor.selection.selectRange range
      setTimeout =>
        @editor.body.focus()
        @editor.trigger 'selectionchanged'
      , 0

      false

    @editor.body.on 'mouseup', 'img:not([data-non-image])', (e) =>
      return false


    @editor.on 'selectionchanged.image', =>
      range = @editor.selection.sel.getRangeAt(0)
      return unless range?

      $contents = $(range.cloneContents()).contents()
      if $contents.length == 1 and $contents.is('img:not([data-non-image])')
        $img = $(range.startContainer).contents().eq(range.startOffset)
        @popover.show $img
      else
        @popover.hide()

    @editor.on 'valuechanged.image', =>
      $masks = @editor.wrapper.find('.simditor-image-loading')
      return unless $masks.length > 0
      $masks.each (i, mask) =>
        $mask = $(mask)
        $img = $mask.data 'img'
        unless $img and $img.parent().length > 0
          $mask.remove()
          if $img
            file = $img.data 'file'
            if file
              @editor.uploader.cancel file
              if @editor.body.find('img.uploading').length < 1
                @editor.uploader.trigger 'uploadready', [file]


  render: (args...) ->
    super args...
    @popover = new ImagePopover(@)

  renderMenu: ->
    super()

    $uploadItem = @menuEl.find('.menu-item-upload-image')
    $input = null

    createInput = =>
      $input.remove() if $input
      $input = $('<input type="file" title="上传图片" accept="image/*">')
        .appendTo($uploadItem)

    createInput()

    $uploadItem.on 'click mousedown', 'input[type=file]', (e) =>
      e.stopPropagation()

    $uploadItem.on 'change', 'input[type=file]', (e) =>
      if @editor.inputManager.focused
        @editor.uploader.upload($input, {
          inline: true
        })
        createInput()
      else
        @editor.one 'focus', (e) =>
          @editor.uploader.upload($input, {
            inline: true
          })
          createInput()
        @editor.focus()
      @wrapper.removeClass('menu-on')

    @_initUploader()

  _initUploader: ->
    unless @editor.uploader?
      @el.find('.btn-upload').remove()
      return

    @editor.uploader.on 'beforeupload', (e, file) =>
      return unless file.inline

      if file.img
        $img = $(file.img)
      else
        $img = @createImage(file.name)
        #$img.click()
        file.img = $img

      $img.addClass 'uploading'
      $img.data 'file', file

      @editor.uploader.readImageFile file.obj, (img) =>
        return unless $img.hasClass('uploading')
        src = if img then img.src else @defaultImage

        @loadImage $img, src, =>
          @popover.refresh()
          @popover.srcEl.val('正在上传...')
            .prop('disabled', true)

    @editor.uploader.on 'uploadprogress', (e, file, loaded, total) =>
      return unless file.inline

      percent = loaded / total
      percent = (percent * 100).toFixed(0)
      percent = '' if percent > 99

      $mask = file.img.data('mask')
      if $mask
        $img = $mask.data('img')
        if $img and $img.parent().length > 0
          $mask.find("span").text(percent)
        else
          $mask.remove()

    @editor.uploader.on 'uploadsuccess', (e, file, result) =>
      return unless file.inline

      $img = file.img
      $img.removeData 'file'
      $img.removeClass 'uploading'

      $mask = $img.data('mask')
      $mask.remove() if $mask
      $img.removeData 'mask'

      if result.success == false
        msg = result.msg || '上传被拒绝了'
        if simple? and simple.message?
          simple.message
            content: msg
        else
          alert msg
        $img.attr 'src', @defaultImage
      else
        $img.attr 'src', result.file_path

      @popover.srcEl.prop('disabled', false)

      @editor.trigger 'valuechanged'
      if @editor.body.find('img.uploading').length < 1
        @editor.uploader.trigger 'uploadready', [file, result]


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
          simple.message
            content: msg
        else
          alert msg

      $img = file.img
      $img.removeData 'file'
      $img.removeClass 'uploading'

      $mask = $img.data('mask')
      $mask.remove() if $mask
      $img.removeData 'mask'

      $img.attr 'src', @defaultImage
      @popover.srcEl.prop('disabled', false)

      @editor.trigger 'valuechanged'
      if @editor.body.find('img.uploading').length < 1
        @editor.uploader.trigger 'uploadready', [file, result]


  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

  loadImage: ($img, src, callback) ->
    $mask = $img.data('mask')
    if !$mask
      $mask = $('<div class="simditor-image-loading"><span></span></div>')
        .hide()
        .appendTo(@editor.wrapper)
      $mask.addClass('uploading') if $img.hasClass('uploading') and @editor.uploader.html5
      $img.data('mask', $mask)
      $mask.data('img', $img)

    img = new Image()

    img.onload = =>
      width = img.width
      height = img.height
      #if width > @maxWidth
        #height = @maxWidth * height / width
        #width = @maxWidth
      #if height > @maxHeight
        #width = @maxHeight * width / height
        #height = @maxHeight

      $img.attr({
        src: src,
        #width: width,
        #height: height,
        'data-image-size': width + ',' + height
      })

      if $img.hasClass 'uploading' # img being uploaded
        @editor.body[0].offsetHeight # force reflow
        wrapperOffset = @editor.wrapper.offset()
        imgOffset = $img.offset()
        $mask.css({
          top: imgOffset.top - wrapperOffset.top,
          left: imgOffset.left - wrapperOffset.left,
          width: $img.width(),
          height: $img.height()
        }).show()
      else
        $mask.remove()
        $img.removeData('mask')

      callback(img)

    img.onerror = =>
      callback(false)
      $mask.remove()
      $img.removeData('mask')

    img.src = src

  createImage: (name = 'Image') ->
    @editor.focus() unless @editor.inputManager.focused
    range = @editor.selection.getRange()
    range.deleteContents()

    $block = @editor.util.closestBlockEl()
    if $block.is('p') and !@editor.util.isEmptyNode $block
      $block = $('<p/>').append(@editor.util.phBr).insertAfter($block)
      @editor.selection.setRangeAtStartOf $block, range
    #else if $block.is('li')
      #$block = @editor.util.furthestNode $block, 'ul, ol'
      #$block = $('<p/>').append(@editor.util.phBr).insertAfter($block)
      #@editor.selection.setRangeAtStartOf $block, range

    $img = $('<img/>').attr('alt', name)
    range.insertNode $img[0]

    $nextBlock = $block.next 'p'
    unless $nextBlock.length > 0
      $nextBlock = $('<p/>').append(@editor.util.phBr).insertAfter($block)
    @editor.selection.setRangeAtStartOf $nextBlock

    $img

  command: (src) ->
    $img = @createImage()

    @loadImage $img, src or @defaultImage, =>
      @editor.trigger 'valuechanged'
      $img[0].offsetHeight
      $img.click()

      @popover.one 'popovershow', =>
        @popover.srcEl.focus()
        @popover.srcEl[0].select()


class ImagePopover extends Popover

  _tpl: """
    <div class="link-settings">
      <div class="settings-field">
        <label>图片地址</label>
        <input class="image-src" type="text" tabindex="1" />
        <a class="btn-upload" href="javascript:;" title="上传图片" tabindex="-1">
          <span class="fa fa-upload"></span>
        </a>
      </div>
      <div class="settings-field">
        <label>图片尺寸</label>
        <input class="image-size" id="image-width" type="text" tabindex="2" />
        <span class="times">×</span>
        <input class="image-size" id="image-height" type="text" tabindex="3" />
        <a class="btn-restore" href="javascript:;" title="还原尺寸" tabindex="-1">
          <span class="fa fa-reply"></span>
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

    @srcEl.on 'keydown', (e) =>
      if e.which == 13 or e.which == 27
        e.preventDefault()

        if e.which == 13 and !@target.hasClass('uploading')
          src = @srcEl.val()
          @button.loadImage @target, src, (success) =>
            return unless success
            @button.editor.body.focus()
            @button.editor.selection.setRangeAfter @target
            @hide()
            @editor.trigger 'valuechanged'
        else
          @button.editor.body.focus()
          @button.editor.selection.setRangeAfter @target
          @hide()

    @widthEl = @el.find '#image-width'
    @heightEl = @el.find '#image-height'

    @el.find('.image-size').on 'blur', (e) =>
      @_resizeImg $(e.currentTarget)
    @el.find('.image-size').on 'keyup', (e) =>
      inputEl = $(e.currentTarget)
      if e.which == 13 or e.which == 27
        e.preventDefault()
        if e.which == 13
          @_resizeImg inputEl
        else
          @_restoreImg()

        @button.editor.body.focus()
        @button.editor.selection.setRangeAfter @target
        @hide()
      else if e.which == 9
        @el.data('popover').refresh()
      else
        @_resizeImg inputEl, true

    @el.find('.btn-restore').on 'click', (e) =>
      @_restoreImg()
      @el.data('popover').refresh()

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
      @input = $('<input type="file" title="上传图片" accept="image/*">')
        .appendTo($uploadBtn)

    createInput()

    @el.on 'click mousedown', 'input[type=file]', (e) =>
      e.stopPropagation()

    @el.on 'change', 'input[type=file]', (e) =>
      @editor.uploader.upload(@input, {
        inline: true,
        img: @target
      })
      createInput()

  _resizeImg: (inputEl, onlySetVal = false) ->
    value = inputEl.val() * 1
    return  unless $.isNumeric(value) or value < 0

    if inputEl.is @widthEl
      height = @height * value / @width
      @heightEl.val height
    else
      width = @width * value / @height
      @widthEl.val width

    unless onlySetVal
      @target.css
        width: width || value
        height: height || value

  _restoreImg: ->
    size = @target.data('image-size')?.split(",") || [@width, @height]
    @target.css
      width: size[0] * 1
      height: size[1] * 1
    @widthEl.val(size[0])
    @heightEl.val(size[1])

  show: (args...) ->
    super args...
    $img = @target
    @width = $img.width()
    @height = $img.height()

    if $img.hasClass 'uploading'
      @srcEl.val '正在上传'
    else
      @srcEl.val $img.attr('src')
      @widthEl.val @width
      @heightEl.val @height


Simditor.Toolbar.addButton(ImageButton)
