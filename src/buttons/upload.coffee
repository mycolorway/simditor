
class UploadButton extends ImageButton

  name: 'upload'

  icon: 'upload'

  insertImage: (src, name) ->
    $img = @createImage(name)

    @loadImage $img, src, =>
      @editor.trigger 'valuechanged'
      @editor.util.reflow $img

      @popover.one 'popovershow', =>
        @popover.srcEl.focus()
        @popover.srcEl[0].select()

    $img

  command: ->
    @editor.trigger 'uploadclick'

Simditor.Toolbar.addButton UploadButton
