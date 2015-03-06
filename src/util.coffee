
class Util extends SimpleModule

  @pluginName: 'Util'

  _init: ->
    @editor = @_module
    @phBr = '' if @browser.msie and @browser.version < 11

  phBr: '<br/>'

  os: (->
    os = {}
    if /Mac/.test navigator.appVersion
      os.mac = true
    else if /Linux/.test navigator.appVersion
      os.linux = true
    else if /Win/.test navigator.appVersion
      os.win = true
    else if /X11/.test navigator.appVersion
      os.unix = true

    if /Mobi/.test navigator.appVersion
      os.mobile = true

    os
  )()

  browser: (->
    ua = navigator.userAgent
    ie = /(msie|trident)/i.test(ua)
    chrome = /chrome|crios/i.test(ua)
    safari = /safari/i.test(ua) && !chrome
    firefox = /firefox/i.test(ua)

    if ie
      msie: true
      version: ua.match(/(msie |rv:)(\d+(\.\d+)?)/i)?[2] * 1
    else if chrome
      webkit: true
      chrome: true
      version: ua.match(/(?:chrome|crios)\/(\d+(\.\d+)?)/i)?[1] * 1
    else if safari
      webkit: true
      safari: true
      version: ua.match(/version\/(\d+(\.\d+)?)/i)?[1] * 1
    else if firefox
      mozilla: true
      firefox: true
      version: ua.match(/firefox\/(\d+(\.\d+)?)/i)?[1] * 1
    else
      {}
  )()

  support: do ->
    onselectionchange: do ->
      # NOTE: not working on firefox
      onselectionchange = document.onselectionchange
      if onselectionchange != undefined
        try
          document.onselectionchange = 0
          return document.onselectionchange == null
        catch e
        finally
          document.onselectionchange = onselectionchange
      false
    oninput: do ->
      # NOTE: `oninput` event not working on contenteditable on IE
      # `document` wouldn't return undefined of this event, for it's exists but not for contenteditable.
      # So we have to block the whole browser for Simditor.
      not /(msie|trident)/i.test(navigator.userAgent)


  # force element to reflow, about relow: 
  # http://blog.letitialew.com/post/30425074101/repaints-and-reflows-manipulating-the-dom-responsibly
  reflow: (el = document) ->
    $(el)[0].offsetHeight

  metaKey: (e) ->
    isMac = /Mac/.test navigator.userAgent
    if isMac then e.metaKey else e.ctrlKey

  isEmptyNode: (node) ->
    $node = $(node)
    $node.is(':empty') or (!$node.text() and !$node.find(':not(br, span, div)').length)

  blockNodes: ["div","p","ul","ol","li","blockquote","hr","pre","h1","h2","h3","h4","table"]

  isBlockNode: (node) ->
    node = $(node)[0]
    if !node or node.nodeType == 3
      return false

    new RegExp("^(#{@blockNodes.join('|')})$").test node.nodeName.toLowerCase()

  closestBlockEl: (node) ->
    unless node?
      range = @editor.selection.getRange()
      node = range?.commonAncestorContainer

    $node = $(node)

    return null unless $node.length

    blockEl = $node.parentsUntil(@editor.body).addBack()
    blockEl = blockEl.filter (i) =>
      @isBlockNode blockEl.eq(i)

    if blockEl.length then blockEl.last() else null

  furthestNode: (node, filter) ->
    unless node?
      range = @editor.selection.getRange()
      node = range?.commonAncestorContainer

    $node = $(node)

    return null unless $node.length

    blockEl = $node.parentsUntil(@editor.body).addBack()
    blockEl = blockEl.filter (i) =>
      $n = blockEl.eq(i)
      if $.isFunction filter
        return filter $n
      else
        return $n.is(filter)

    if blockEl.length then blockEl.first() else null


  furthestBlockEl: (node) ->
    @furthestNode(node, $.proxy(@isBlockNode, @))

  getNodeLength: (node) ->
    switch node.nodeType
      when 7, 10 then 0
      when 3, 8 then node.length
      else node.childNodes.length


  traverseUp:(callback, node) ->
    unless node?
      range = @editor.selection.getRange()
      node = range?.commonAncestorContainer

    if !node? or !$.contains(@editor.body[0], node)
      return false

    nodes = $(node).parentsUntil(@editor.body).get()
    nodes.unshift node
    for n in nodes
      result = callback n
      break if result == false

  indent: () ->
    $blockEl = @editor.util.closestBlockEl()
    return false unless $blockEl and $blockEl.length > 0

    if $blockEl.is('pre')
      spaceNode = document.createTextNode '\u00A0\u00A0'
      @editor.selection.insertNode spaceNode
    else if $blockEl.is('li')
      $parentLi = $blockEl.prev('li')
      return false if $parentLi.length < 1

      @editor.selection.save()
      tagName = $blockEl.parent()[0].tagName
      $childList = $parentLi.children('ul, ol')

      if $childList.length > 0
        $childList.append $blockEl
      else
        $('<' + tagName + '/>')
          .append($blockEl)
          .appendTo($parentLi)

      @editor.selection.restore()
    else if $blockEl.is 'p, h1, h2, h3, h4'
      indentLevel = $blockEl.attr('data-indent') ? 0
      indentLevel = indentLevel * 1 + 1
      indentLevel = 10 if indentLevel > 10
      $blockEl.attr 'data-indent', indentLevel
    else if $blockEl.is 'table'
      range = @editor.selection.getRange()
      $td = $(range.commonAncestorContainer).closest('td')
      $nextTd = $td.next('td')
      $nextTd = $td.parent('tr').next('tr').find('td:first') unless $nextTd.length > 0
      return false unless $td.length > 0 and $nextTd.length > 0
      @editor.selection.setRangeAtEndOf $nextTd
    else
      spaceNode = document.createTextNode '\u00A0\u00A0\u00A0\u00A0'
      @editor.selection.insertNode spaceNode

    @editor.trigger 'valuechanged'
    true

  outdent: () ->
    $blockEl = @editor.util.closestBlockEl()
    return false unless $blockEl and $blockEl.length > 0

    if $blockEl.is('pre')
      # TODO: outdent in code block
      return false
    else if $blockEl.is('li')
      $parent = $blockEl.parent()
      $parentLi = $parent.parent('li')

      if $parentLi.length < 1
        button = @editor.toolbar.findButton $parent[0].tagName.toLowerCase()
        button?.command()
        return false

      @editor.selection.save()

      if $blockEl.next('li').length > 0
        $('<' + $parent[0].tagName + '/>')
          .append($blockEl.nextAll('li'))
          .appendTo($blockEl)

      $blockEl.insertAfter $parentLi
      $parent.remove() if $parent.children('li').length < 1
      @editor.selection.restore()
    else if $blockEl.is 'p, h1, h2, h3, h4'
      indentLevel = $blockEl.attr('data-indent') ? 0
      indentLevel = indentLevel * 1 - 1
      indentLevel = 0 if indentLevel < 0
      $blockEl.attr 'data-indent', indentLevel
    else if $blockEl.is 'table'
      range = @editor.selection.getRange()
      $td = $(range.commonAncestorContainer).closest('td')
      $prevTd = $td.prev('td')
      $prevTd = $td.parent('tr').prev('tr').find('td:last') unless $prevTd.length > 0
      return false unless $td.length > 0 and $prevTd.length > 0
      @editor.selection.setRangeAtEndOf $prevTd
    else
      return false

    @editor.trigger 'valuechanged'
    true

  # convert base64 data url to blob object for pasting images in firefox and IE11
  dataURLtoBlob: (dataURL) ->
    hasBlobConstructor = window.Blob && (->
      try
        return Boolean(new Blob())
      catch e
        return false
    )()

    hasArrayBufferViewSupport = hasBlobConstructor && window.Uint8Array && (->
      try
        return new Blob([new Uint8Array(100)]).size == 100
      catch e
        return false
    )()

    BlobBuilder = window.BlobBuilder || window.WebKitBlobBuilder ||
      window.MozBlobBuilder || window.MSBlobBuilder;

    return false unless (hasBlobConstructor || BlobBuilder) && window.atob && window.ArrayBuffer && window.Uint8Array

    if dataURL.split(',')[0].indexOf('base64') >= 0
      # Convert base64 to raw binary data held in a string:
      byteString = atob(dataURL.split(',')[1])
    else
      # Convert base64/URLEncoded data component to raw binary data:
      byteString = decodeURIComponent(dataURL.split(',')[1])

    # Write the bytes of the string to an ArrayBuffer:
    arrayBuffer = new ArrayBuffer(byteString.length)
    intArray = new Uint8Array(arrayBuffer)
    for i in [0..byteString.length]
      intArray[i] = byteString.charCodeAt(i)

    # Separate out the mime component:
    mimeString = dataURL.split(',')[0].split(':')[1].split(';')[0]
    # Write the ArrayBuffer (or ArrayBufferView) to a blob:
    if hasBlobConstructor
      return new Blob([if hasArrayBufferViewSupport then intArray else arrayBuffer], {type: mimeString})
    bb = new BlobBuilder()
    bb.append(arrayBuffer)
    bb.getBlob(mimeString)

  throttle: (func, wait) ->
    delayedCallTimeout = null
    previousCallTime = 0
    stopDelayedCall = ->
      if delayedCallTimeout
        clearTimeout delayedCallTimeout
        delayedCallTimeout = null

    ->
      now = Date.now()
      previousCallTime ||= now
      remaining = wait - (now - previousCallTime)
      result = null
      if 0 < remaining < wait
        previousCallTime = now
        stopDelayedCall()
        args = arguments
        delayedCallTimeout = setTimeout ->
          previousCallTime = 0
          delayedCallTimeout = null
          result = func.apply null, args
        , wait
      else
        stopDelayedCall()
        previousCallTime = 0 if previousCallTime isnt now
        result = func.apply null, arguments
      result

  formatHTML: (html) ->
    re = /<(\/?)(.+?)(\/?)>/g
    result = ''
    level = 0
    lastMatch = null
    indentString = '  '
    repeatString = (str, n) ->
      new Array(n + 1).join(str)

    while (match = re.exec(html)) != null
      match.isBlockNode = $.inArray(match[2], @blockNodes) > -1
      match.isStartTag = match[1] != '/' and match[3] != '/'
      match.isEndTag = match[1] == '/' or match[3] == '/'

      cursor = if lastMatch then lastMatch.index + lastMatch[0].length else 0
      result += str if (str = html.substring(cursor, match.index)).length > 0 and $.trim(str)

      level -= 1 if match.isBlockNode and match.isEndTag and !match.isStartTag
      if match.isBlockNode and match.isStartTag
        result += '\n' if !(lastMatch and lastMatch.isBlockNode and lastMatch.isEndTag)
        result += repeatString(indentString, level)
      result += match[0]
      result += '\n' if match.isBlockNode and match.isEndTag
      level += 1 if match.isBlockNode and match.isStartTag

      lastMatch = match

    $.trim result

