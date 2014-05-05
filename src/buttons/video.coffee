class VideoButton extends Button

  _videoTpl: '''
    <p><embed allowFullScreen="true" quality="high" width="620" height="500" align="middle" allowScriptAccess="always" type="application/x-shockwave-flash" src="---video-src---"></embed></p>
  '''

  name: 'video'

  icon: 'video-camera'

  title: '插入视频'

  htmlTag: 'embed'

  disableTag: 'pre, table'

  render: (args...) ->
    super args...
    @popover = new VideoPopover(@)

  parseVideoSrc: (src) ->
    videoSrc = false
    if src && src.match(/\.swf\b/)
      videoSrc = src
    else if src
      $.ajax
        url: "/getvideo?url=#{encodeURIComponent(src)}"
        dataType: 'json'
        async: false
        type: 'GET'
        success: (data)->
          videoSrc = data.flash if data.flash.length > 0
    videoSrc

  loadVideo: (src, target)->
    videoSrc = @parseVideoSrc(src)
    return unless videoSrc

    videoNode = $(@_videoTpl.replace('---video-src---', videoSrc))
    target.after videoNode
    @editor.trigger 'valuechanged'

  command: () ->
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
    videoWraper = $('</p>')
    @editor.selection.insertNode videoWraper, range
    @popover.show videoWraper

Simditor.Toolbar.addButton(VideoButton)

class VideoPopover extends Popover

  _tpl: """
    <div class="link-settings">
      <div class="settings-field">
        <label>视频地址</label>
        <input class="video-src" type="text"/>
        </a>
      </div>
    </div>
  """

  constructor: (@button) ->
    super @button.editor

  render: ->
    @el.addClass('video-popover')
      .append(@_tpl)
    @srcEl = @el.find '.video-src'

    @srcEl.on 'keydown', (e) =>
      if e.which == 13
        e.preventDefault()
        @button.loadVideo @srcEl.val(), @target
        @srcEl.blur()

    @srcEl.on 'blur', =>
      @target.remove()
      @hide()

  show: (args...) ->
    super args...
    @srcEl.val ''
    @srcEl.focus()
