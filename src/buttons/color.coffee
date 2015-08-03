
class ColorButton extends Button

  name: 'color'

  icon: 'tint'

  disableTag: 'pre'

  menu: true

  render: (args...) ->
    super args...

  renderMenu: ->
    $('''
    <ul class="color-list">
      <li><a href="javascript:;" class="font-color font-color-1"></a></li>
      <li><a href="javascript:;" class="font-color font-color-2"></a></li>
      <li><a href="javascript:;" class="font-color font-color-3"></a></li>
      <li><a href="javascript:;" class="font-color font-color-4"></a></li>
      <li><a href="javascript:;" class="font-color font-color-5"></a></li>
      <li><a href="javascript:;" class="font-color font-color-6"></a></li>
      <li><a href="javascript:;" class="font-color font-color-7"></a></li>
      <li><a href="javascript:;" class="font-color font-color-default"></a></li>
    </ul>
    ''').appendTo(@menuWrapper)

    @menuWrapper.on 'mousedown', '.color-list', (e) ->
      false

    @menuWrapper.on 'click', '.font-color', (e) =>
      @wrapper.removeClass('menu-on')
      $link = $(e.currentTarget)

      if $link.hasClass 'font-color-default'
        $p = @editor.body.find 'p, li'
        return unless $p.length > 0
        rgb = window.getComputedStyle($p[0], null).getPropertyValue('color')
        hex = @_convertRgbToHex rgb
      else
        rgb = window.getComputedStyle($link[0], null)
          .getPropertyValue('background-color')
        hex = @_convertRgbToHex rgb

      return unless hex

      range = @editor.selection.range()
      if !$link.hasClass('font-color-default') and range.collapsed
        textNode = document.createTextNode(@_t('coloredText'))
        range.insertNode textNode
        range.selectNodeContents textNode
        @editor.selection.range range

      # Use span[style] instead of font[color]
      document.execCommand 'styleWithCSS', false, true
      document.execCommand 'foreColor', false, hex
      document.execCommand 'styleWithCSS', false, false

      unless @editor.util.support.oninput
        @editor.trigger 'valuechanged'

  _convertRgbToHex:(rgb) ->
    re = /rgb\((\d+),\s?(\d+),\s?(\d+)\)/g
    match = re.exec rgb
    return '' unless match

    rgbToHex = (r, g, b) ->
      componentToHex = (c) ->
        hex = c.toString(16)
        if hex.length == 1 then '0' + hex else hex
      "#" + componentToHex(r) + componentToHex(g) + componentToHex(b)

    rgbToHex match[1] * 1, match[2] * 1, match[3] * 1


Simditor.Toolbar.addButton ColorButton
