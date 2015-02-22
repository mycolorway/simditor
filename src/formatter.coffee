
class Formatter extends SimpleModule

  @pluginName: 'Formatter'

  opts:
    allowedTags: null
    allowedAttributes: null

  _init: ->
    @editor = @_module

    @_allowedTags = @opts.allowedTags || ['br', 'a', 'img', 'b', 'strong', 'i', 'u', 'font', 'p', 'ul', 'ol', 'li', 'blockquote', 'pre', 'h1', 'h2', 'h3', 'h4', 'hr']
    @_allowedAttributes = @opts.allowedAttributes ||
      img: ['src', 'alt', 'width', 'height', 'data-image-src', 'data-image-size', 'data-image-name', 'data-non-image']
      a: ['href', 'target']
      font: ['color']
      pre: ['data-lang', 'class']
      p: ['data-indent']
      h1: ['data-indent']
      h2: ['data-indent']
      h3: ['data-indent']
      h4: ['data-indent']

    @editor.body.on 'click', 'a', (e) =>
      false

  decorate: ($el = @editor.body) ->
    @editor.trigger 'decorate', [$el]

  undecorate: ($el = @editor.body.clone()) ->
    @editor.trigger 'undecorate', [$el]
    $.trim $el.html()

  autolink: ($el = @editor.body) ->
    linkNodes = []

    findLinkNode = ($parentNode) ->
      $parentNode.contents().each (i, node) ->
        $node = $(node)
        if $node.is('a') or $node.closest('a, pre', $el).length
          return

        if $node.contents().length
          findLinkNode $node
        else if (text = $node.text()) and /https?:\/\/|www\./ig.test(text)
          linkNodes.push $node

    findLinkNode $el

    re = /(https?:\/\/|www\.)[\w\-\.\?&=\/#%:,@\!\+]+/ig
    for $node in linkNodes
      text = $node.text()
      replaceEls = []
      match = null
      lastIndex = 0

      while (match = re.exec(text)) != null
        replaceEls.push document.createTextNode(text.substring(lastIndex, match.index))
        lastIndex = re.lastIndex
        uri = if /^(http(s)?:\/\/|\/)/.test(match[0]) then match[0] else 'http://' + match[0]
        replaceEls.push $('<a href="' + uri + '" rel="nofollow"></a>').text(match[0])[0]

      replaceEls.push document.createTextNode(text.substring(lastIndex))
      $node.replaceWith $(replaceEls)

    $el

  # make sure the direct children is block node
  format: ($el = @editor.body) ->
    if $el.is ':empty'
      $el.append '<p>' + @editor.util.phBr + '</p>'
      return $el

    @cleanNode(n, true) for n in $el.contents()

    for node in $el.contents()
      $node = $(node)
      if $node.is('br')
        blockNode = null if blockNode?
        $node.remove()
      else if @editor.util.isBlockNode(node)
        if $node.is('li')
          if blockNode and blockNode.is('ul, ol')
            blockNode.append node
          else
            blockNode = $('<ul/>').insertBefore(node)
            blockNode.append node
        else
          blockNode = null
      else
        blockNode = $('<p/>').insertBefore(node) if !blockNode or blockNode.is('ul, ol')
        blockNode.append(node)

    $el

  cleanNode: (node, recursive) ->
    $node = $(node)
    return unless $node.length > 0

    if $node[0].nodeType == 3
      text = $node.text().replace(/(\r\n|\n|\r)/gm, '')
      if text
        textNode = document.createTextNode text
        $node.replaceWith textNode
      else
        $node.remove()
      return

    contents = $node.contents()
    isDecoration = $node.is('[class^="simditor-"]')

    if $node.is(@_allowedTags.join(',')) or isDecoration
      # img inside a is not allowed
      if $node.is('a') and ($childImg = $node.find('img')).length > 0
        $node.replaceWith $childImg
        $node = $childImg
        contents = null

      # exclude uploading img
      if $node.is('img') and $node.hasClass('uploading')
        $node.remove()

      # Clean attributes except `src` `alt` on `img` tag and `href` `target` on `a` tag
      unless isDecoration
        allowedAttributes = @_allowedAttributes[$node[0].tagName.toLowerCase()]
        for attr in $.makeArray($node[0].attributes)
            $node.removeAttr(attr.name) unless allowedAttributes? and attr.name in allowedAttributes
    else if $node[0].nodeType == 1 and !$node.is ':empty'
      if $node.is('div, article, dl, header, footer, tr')
        $node.append('<br/>')
        contents.first().unwrap()
      else if $node.is 'table'
        $p = $('<p/>')
        $node.find('tr').each (i, tr) =>
          $p.append($(tr).text() + '<br/>')
        $node.replaceWith $p
        contents = null
      else if $node.is 'thead, tfoot'
        $node.remove()
        contents = null
      else if $node.is 'th'
        $td = $('<td/>').append $node.contents()
        $node.replaceWith $td
      else
        contents.first().unwrap()
    else
      $node.remove()
      contents = null

    @cleanNode(n, true) for n in contents if recursive and contents? and !$node.is('pre')
    null

  clearHtml: (html, lineBreak = true) ->
    container = $('<div/>').append(html)
    contents = container.contents()
    result = ''

    contents.each (i, node) =>
      if node.nodeType == 3
        result += node.nodeValue
      else if node.nodeType == 1
        $node = $(node)
        children = $node.contents()
        result += @clearHtml children if children.length > 0
        if lineBreak and i < contents.length - 1 and $node.is 'br, p, div, li, tr, pre, address, artticle, aside, dl, figcaption, footer, h1, h2, h3, h4, header'
          result += '\n'

    result

  # remove empty nodes and useless paragraph
  beautify: ($contents) ->
    uselessP = ($el) ->
      !!($el.is('p') and !$el.text() and $el.children(':not(br)').length < 1)

    $contents.each (i, el) =>
      $el = $(el)
      $el.remove() if $el.is(':not(img, br, col, td, hr, [class^="simditor-"]):empty')
      $el.remove() if uselessP($el) #and uselessP($el.prev())
      $el.find(':not(img, br, col, td, hr, [class^="simditor-"]):empty').remove()
