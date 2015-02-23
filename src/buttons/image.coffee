
class ImageButton extends Button

  name: 'image'

  icon: 'picture-o'

  htmlTag: 'img'

  disableTag: 'pre, table'

  defaultImage: ''

  needFocus: false

  _init: () ->
    if @editor.opts.imageButton
      if Array.isArray(@editor.opts.imageButton)
        @menu = []
        for item in @editor.opts.imageButton
          @menu.push
            name: item + '-image'
            text: @_t(item + 'Image')
      else
        @menu = false
    else
      if @editor.uploader?
        @menu = [{
          name: 'upload-image',
          text: @_t 'uploadImage'
        }, {
          name: 'external-image',
          text: @_t 'externalImage'
        }]
      else
        @menu = false

    @defaultImage = @editor.opts.defaultImage

    @editor.body.on 'click', 'img:not([data-non-image])', (e) =>
      $img = $(e.currentTarget)

      #@popover.show $img
      range = document.createRange()
      range.selectNode $img[0]
      @editor.selection.selectRange range
      @editor.trigger 'selectionchanged' unless @editor.util.support.onselectionchange

      false

    @editor.body.on 'mouseup', 'img:not([data-non-image])', (e) =>
      return false


    @editor.on 'selectionchanged.image', =>
      range = @editor.selection.getRange()
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

    super()

  render: (args...) ->
    super args...
    @popover = new ImagePopover
      button: @

    if @editor.opts.imageButton == 'upload'
      @_initUploader @el

  renderMenu: ->
    super()
    @_initUploader()

  _initUploader: ($uploadItem = @menuEl.find('.menu-item-upload-image')) ->
    unless @editor.uploader?
      @el.find('.btn-upload').remove()
      return

    $input = null
    createInput = =>
      $input.remove() if $input
      $input = $('<input type="file" title="' + @_t('uploadImage') + '" accept="image/*">')
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
          if @popover.active
            @popover.refresh()
            @popover.srcEl.val(@_t('uploading'))
              .prop('disabled', true)

    @editor.uploader.on 'uploadprogress', $.proxy @editor.util.throttle((e, file, loaded, total) ->
      return unless file.inline

      $mask = file.img.data('mask')
      return unless $mask

      $img = $mask.data('img')
      unless $img.hasClass('uploading') and $img.parent().length > 0
        $mask.remove()
        return

      percent = loaded / total
      percent = (percent * 100).toFixed(0)
      percent = 99 if percent > 99
      $mask.find('.progress').height "#{100 - percent}%"
    , 500), @

    @editor.uploader.on 'uploadsuccess', (e, file, result) =>
      return unless file.inline

      $img = file.img
      return unless $img.hasClass('uploading') and $img.parent().length > 0

      $img.removeData 'file'
      $img.removeClass 'uploading'
        .removeClass 'loading'

      $mask = $img.data('mask')
      $mask.remove() if $mask
      $img.removeData 'mask'

      # in case mime type of response isnt correct
      if typeof result != 'object'
        try
          result = $.parseJSON result
        catch e
          result =
            success: false

      if result.success == false
        msg = result.msg || @_t('uploadFailed')
        alert msg
        $img.attr 'src', @defaultImage
      else
        $img.attr 'src', result.file_path

      if @popover.active
        @popover.srcEl.prop('disabled', false)
        @popover.srcEl.val result.file_path

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
          msg = @_t('uploadError')

        alert msg

      $img = file.img
      return unless $img.hasClass('uploading') and $img.parent().length > 0

      $img.removeData 'file'
      $img.removeClass 'uploading'
        .removeClass 'loading'

      $mask = $img.data('mask')
      $mask.remove() if $mask
      $img.removeData 'mask'

      $img.attr 'src', @defaultImage
      if @popover.active
        @popover.srcEl.prop('disabled', false)
        @popover.srcEl.val @defaultImage

      @editor.trigger 'valuechanged'
      if @editor.body.find('img.uploading').length < 1
        @editor.uploader.trigger 'uploadready', [file, result]


  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

  loadImage: ($img, src, callback) ->
    positionMask = =>
      imgOffset = $img.offset()
      wrapperOffset = @editor.wrapper.offset()
      $mask.css({
        top: imgOffset.top - wrapperOffset.top
        left: imgOffset.left - wrapperOffset.left
        width: $img.width(),
        height: $img.height()
      }).show()

    $img.addClass('loading')
    $mask = $img.data('mask')
    if !$mask
      $mask = $('<div class="simditor-image-loading"><div class="progress"></div></div>')
        .hide()
        .appendTo(@editor.wrapper)
      positionMask()
      $img.data('mask', $mask)
      $mask.data('img', $img)

    img = new Image()

    img.onload = =>
      return if !$img.hasClass('loading') and !$img.hasClass('uploading')

      width = img.width
      height = img.height

      $img.attr
        src: src,
        'data-image-size': width + ',' + height
      .removeClass('loading')

      if $img.hasClass('uploading') # img being uploaded
        @editor.util.reflow @editor.body
        positionMask()
      else
        $mask.remove()
        $img.removeData('mask')

      callback(img)

    img.onerror = =>
      callback(false)
      $mask.remove()
      $img.removeData('mask')
        .removeClass('loading')

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

    @loadImage $img, src || @defaultImage, =>
      @editor.trigger 'valuechanged'
      @editor.util.reflow $img
      $img.click()

      @popover.one 'popovershow', =>
        @popover.srcEl.focus()
        @popover.srcEl[0].select()


class ImagePopover extends Popover

  offset:
    top: 6
    left: -4

  render: ->
    tpl = """
      <div class="link-settings">
        <div class="settings-field">
          <label>#{ @_t 'imageUrl' }</label>
          <input class="image-src" type="text" tabindex="1" />
          <a class="btn-upload" href="javascript:;" title="#{ @_t 'uploadImage' }" tabindex="-1">
            <span class="simditor-icon simditor-icon-upload"></span>
          </a>
        </div>
        <div class="settings-field">
          <label>#{ @_t 'imageSize' }</label>
          <input class="image-size" id="image-width" type="text" tabindex="2" />
          <span class="times">×</span>
          <input class="image-size" id="image-height" type="text" tabindex="3" />
          <a class="btn-restore" href="javascript:;" title="#{ @_t 'restoreImageSize' }" tabindex="-1">
            <span class="simditor-icon simditor-icon-undo"></span>
          </a>
        </div>
      </div>
    """
    @el.addClass('image-popover')
      .append(tpl)
    @srcEl = @el.find '.image-src'

    @srcEl.on 'keydown', (e) =>
      return unless e.which == 13 or e.which == 27
      e.preventDefault()

      hideAndFocus = =>
        @button.editor.body.focus()
        @button.editor.selection.setRangeAfter @target
        @hide()

      if e.which == 13 and !@target.hasClass('uploading')
        src = @srcEl.val()

        if /^data:image/.test(src) and not @editor.uploader
          hideAndFocus()
          return

        @button.loadImage @target, src, (success) =>
          return unless success

          if /^data:image/.test(src)
            blob = @editor.util.dataURLtoBlob src
            blob.name = "Base64 Image.png"
            @editor.uploader.upload blob,
              inline: true
              img: @target
          else
            hideAndFocus()
            @editor.trigger 'valuechanged'
      else
        hideAndFocus()

    @widthEl = @el.find '#image-width'
    @heightEl = @el.find '#image-height'

    @el.find('.image-size').on 'blur', (e) =>
      @_resizeImg $(e.currentTarget)
      @el.data('popover').refresh()

    @el.find('.image-size').on 'keyup', (e) =>
      inputEl = $(e.currentTarget)
      unless e.which == 13 or e.which == 27 or e.which == 9
        @_resizeImg inputEl, true

    @el.find('.image-size').on 'keydown', (e) =>
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
      @input = $('<input type="file" title="' + @_t('uploadImage') + '" accept="image/*">')
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
    return unless $.isNumeric(value) or value < 0

    if inputEl.is @widthEl
      height = @height * value / @width
      @heightEl.val height
    else
      width = @width * value / @height
      @widthEl.val width

    unless onlySetVal
      @target.attr
        width: width || value
        height: height || value

  _restoreImg: ->
    size = @target.data('image-size')?.split(",") || [@width, @height]
    @target.attr
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
      @srcEl.val @_t('uploading')
        .prop 'disabled', true
    else
      @srcEl.val $img.attr('src')
        .prop 'disabled', false
      @widthEl.val @width
      @heightEl.val @height


Simditor.Toolbar.addButton ImageButton
