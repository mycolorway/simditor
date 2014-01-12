
Simditor.Format =

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

