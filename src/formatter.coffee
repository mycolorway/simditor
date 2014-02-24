
class Formatter extends Plugin

  @className: 'Formatter'

  constructor: (args...) ->
    super args...
    @editor = @widget

  _init: ->
    @editor.body.on 'click', 'a', (e) =>
      false

  _allowedTags: ['a', 'img', 'b', 'strong', 'i', 'u', 'p', 'ul', 'ol', 'li', 'blockquote', 'pre', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6']

  _allowedAttributes:
    img: ['src', 'alt', 'width', 'height', 'data-origin-src', 'data-origin-size', 'data-origin-name']
    a: ['href', 'target']
    pre: ['data-lang']

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
        if $node.is('a') or $node.closest('a', $el).length
          return

        if $node.contents().length
          findLinkNode $node
        else if text = $node.text() and /https?:\/\/|www\./ig.test(text)
          linkNodes.push $node

    findLinkNode $el

    re = /(https?:\/\/|www\.)[\w\-\.\?&=\/#%]+/ig
    for $node in linkNodes
      text = $node.text();
      replaceEls = [];
      match = null;
      lastIndex = 0;

      while (match = re.exec(text)) != null
        replaceEls.push document.createTextNode(text.substring(lastIndex, match.index))
        lastIndex = re.lastIndex
        uri = if /^(http(s)?:\/\/|\/)/.test(match[0]) then match[0] else 'http://' + match[0]
        replaceEls.push $('<a href="' + uri + '" rel="nofollow">' + match[0] + '</a>')[0]

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
      if @editor.util.isBlockNode(node) or $(node).is('img')
        blockNode = null
      else
        blockNode = $('<p/>').insertBefore(node) unless blockNode?
        blockNode.append(node)

    $el

  cleanNode: (node, recursive) ->
    $node = $(node)

    if $node[0].nodeType == 3
      return

    contents = $node.contents()
    isDecoration = $node.is('[class^="simditor-"]')

    if $node.is(@_allowedTags.join(',')) or isDecoration
      # img inside a is not allowed
      if $node.is('a') and $node.find('img').length > 0
        contents.first().unwrap()

      # Clean attributes except `src` `alt` on `img` tag and `href` `target` on `a` tag
      unless isDecoration
        allowedAttributes = @_allowedAttributes[$node[0].tagName.toLowerCase()]
        for attr in $.makeArray($node[0].attributes)
            $node.removeAttr(attr.name) unless allowedAttributes? and attr.name in allowedAttributes
    else if $node[0].nodeType == 1 and !$node.is ':empty'
      #$('<p/>').append(contents)
        #.insertBefore($node)
      contents.first().unwrap()
    else
      $node.remove()
      contents = null

    @cleanNode(n, true) for n in contents if recursive and contents?
    null

  clearHtml: (html, lineBreak = true) ->
    container = $('<div/>').append(html)
    result = ''

    container.contents().each (i, node) =>
      if node.nodeType == 3
        result += node.nodeValue
      else if node.nodeType == 1
        $node = $(node)
        contents = $node.contents()
        result += @clearHtml contents if contents.length > 0
        if lineBreak and $node.is 'p, div, li, tr, pre, address, artticle, aside, dd, figcaption, footer, h1, h2, h3, h4, h5, h6, header'
          result += '\n'

    result


