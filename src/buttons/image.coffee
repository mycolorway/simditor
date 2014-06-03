
class ImageButton extends Button

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

    #@editor.on 'decorate', (e, $el) =>
      #$el.find('img:not([data-non-image])').each (i, img) =>
        #@decorate $(img)

    #@editor.on 'undecorate', (e, $el) =>
      #$el.find('img:not([data-non-image])').each (i, img) =>
        #@undecorate $(img)

    @editor.body.on 'click', 'img:not([data-non-image])', (e) =>
      $img = $(e.currentTarget)

      if $img.hasClass 'selected'
        return false
      else
        #@popover.show $img
        range = document.createRange()
        range.selectNode $img[0]
        @editor.selection.selectRange range
        @editor.trigger 'selectionchanged'

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

      if file.img
        $img = $(file.img)
      else
        $img = @createImage(file.name)
        $img.click()
        file.img = $img

      $img.addClass 'uploading'
      file.progressEl = $('<div class="simditor-upload-progress"><span></span></div>')
        .appendTo(@editor.wrapper)

      @editor.uploader.readImageFile file.obj, (img) =>
        src = if img then img.src else @defaultImage

        @loadImage $img, src, () =>
          @popover.refresh()
          @popover.srcEl.val('正在上传...')

          imgPosition = $img.position()
          file.progressEl.css({
              top: imgPosition.top  + @editor.toolbar.wrapper.outerHeight(),
              left: imgPosition.left,
              width: $img.width(),
              height: $img.height()
            })
          file.progressEl.addClass('loading') unless @editor.uploader.html5

    @editor.uploader.on 'uploadprogress', (e, file, loaded, total) =>
      return unless file.inline

      percent = loaded / total
      percent = (percent * 100).toFixed(0)
      percent = 99 if percent > 99
      file.progressEl.find("span").text(percent)

    @editor.uploader.on 'uploadsuccess', (e, file, result) =>
      return unless file.inline

      $img = file.img.removeClass 'uploading'
      @loadImage $img, result.file_path, () =>
        file.progressEl.remove()

        @popover.srcEl.val result.file_path
        @editor.trigger 'valuechanged'
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
          simple.message(msg)
        else
          alert(msg)

      $img = file.img.removeClass 'uploading'
      @loadImage $img, @defaultImage, =>
        @popover.refresh()
        @popover.srcEl.val $img.attr('src')

        file.progressEl.remove()
        @editor.trigger 'valuechanged'

  status: ($node) ->
    @setDisabled $node.is(@disableTag) if $node?
    return true if @disabled

  #decorate: ($img) ->
    #$parent = $img.parent()
    #return if $parent.is('.simditor-image')

    #$(@_wrapperTpl)
      #.width($img.width())
      #.insertBefore($img)
      #.prepend($img)

  #undecorate: ($img) ->
    #$parent = $img.parent('.simditor-image')
    #return if $parent.length < 1

    #unless /^data:image/.test($img.attr('src'))
      #$img.insertBefore $parent

    #$parent.remove()

  loadImage: ($img, src, callback) ->
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
        'data-image-size': img.width + ',' + img.height
      })

      callback(img)

    img.onerror = =>
      callback(false)

    img.src = src

  createImage: (name = 'Image') ->
    range = @editor.selection.getRange()
    range.deleteContents()

    $img = $('<img/>').attr('alt', name)
    range.insertNode $img[0]
    $img

  command: (src) ->
    $img = @createImage()

    @loadImage $img, src or @defaultImage, =>
      @editor.trigger 'valuechanged'
      $img.click()

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

        @timer = null
      , 200

    @srcEl.on 'keydown', (e) =>
      if e.which == 13 or e.which == 27 or e.which == 9
        e.preventDefault()

        if e.which == 13 and !@target.hasClass('uploading')
          src = @srcEl.val()
          @button.loadImage @target, src, (success) =>
            return unless success
            @refresh()
            @editor.trigger 'valuechanged'

        @srcEl.blur()
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
        img: @target
      })
      createInput()

  show: (args...) ->
    super args...
    $img = @target
    if $img.hasClass 'uploading'
      @srcEl.val '正在上传'
    else
      @srcEl.val $img.attr('src')


Simditor.Toolbar.addButton(ImageButton)
