
Simditor.Util =

  _load: ->
    if @browser.msie
      @_placeholderBr = ''

  _placeholderBr: '<br/>'
  
  browser: (->
    ua = navigator.userAgent
    ie = /(msie|trident)/i.test(ua)
    chrome = /chrome|crios/i.test(ua)
    safari = /safari/i.test(ua) && !chrome
    firefox = /firefox/i.test(ua)

    if ie
      msie: true
      version: ua.match(/(msie |rv:)(\d+(\.\d+)?)/i)[2]
    else if chrome
      webkit: true
      chrome: true
      version: ua.match(/(?:chrome|crios)\/(\d+(\.\d+)?)/i)[1]
    else if safari
      webkit: true
      chrome: true
      version: ua.match(/version\/(\d+(\.\d+)?)/i)[1]
    else if firefox
      mozilla: true
      firefox: true
      version: ua.match(/firefox\/(\d+(\.\d+)?)/i)[1]
    else
      {}
  )()

  metaKey: (e) ->
    isMac = /Mac/.test navigator.userAgent
    isMac ? e.metaKey : e.ctrlKey

  isBlockNode: (node) ->
    node = $(node)[0]
    if !node or node.nodeType == 3
      return false

    /^(div|p|ul|ol|li|blockquote|hr|pre|h1|h2|h3|h4|h5|h6|table)$/.test node.nodeName.toLowerCase()

  closestBlockNode: (node) ->


