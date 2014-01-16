
Format =

  _allowedTags: ['p', 'ul', 'ol', 'li', 'blockquote', 'hr', 'pre', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'table']

  _load: ->

  _init: ->

    @body.on 'click', 'a', (e) =>
      false

  _decorate: ($el = @body) ->
    @trigger 'decorate', [$el]

  _undecorate: ($el = @body.clone()) ->
    @trigger 'undecorate', [$el]

    # generate `a` tag automatically
    @autolink $el

    # remove empty `p` tag at the end of content
    lastP = $el.children().last 'p'
    while lastP.is 'p' and !lastP.text() and !lastP.find('img').length
      emptyP = lastP
      lastP = lastP.prev 'p'
      emptyP.remove()

    $.trim $el.html()

  autolink: ($el = @body) ->
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

    re = /(https?:\/\/|www\.)[\w\-\.\?&=\/]+/ig
    for $node in linkNodes
      text = $node.text().replace re, (link) ->
        if /^(http(s)?:\/\/|\/)/.test link
          uri = link
        else
          uri = 'http://' + link;

        return '<a href="' + uri + '" rel="nofollow">' + link + '</a>'

      if $node[0].nodeType == 3
        $node.replaceWith text
      else
        $node.html text

    $el

  format: ($el = @body) ->
    if $el.is ':empty'
      $el.append '<p>' + @_placeholderBr + '</p>'
      return $el

    for node in $el.contents()
      if @isBlockNode node
        @cleanNode blockNode if blockNode?
        @cleanNode node
        blockNode = null
      else
        blockNode = $('<p/>').insertBefore(node) unless blockNode?
        blockNode.append(node)

  cleanNode: (node, recursive) ->
    $node = $(node)

    if $node[0].nodeType == 3
      return

    contents = $node.contents()

    if $node.is @_allowedTags.join(',')
      # Clean attributes except `src` `alt` on `img` tag and `href` `target` on `a` tag
      for attr in $.makeArray($node[0].attributes)
        if !($node.is 'img' and attr.name in ['src', 'alt']) and !($node.is 'a' and attr.name in ['href', 'target'])
          $node.removeAttr(attr.name)
    else if $node[0].nodeType == 1 and !$node.is ':empty'
      $('<p/>').append(contents)
        .insertBefore($node)
      $node.remove()
    else
      $node.remove()
      contents = null

    cleanNode n for n in contents if recursive and contents?

