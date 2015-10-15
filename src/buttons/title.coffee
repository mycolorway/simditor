
class TitleButton extends Button

  name: 'title'

  htmlTag: 'h1, h2, h3, h4, h5'

  disableTag: 'pre, table'

  _init: ->
    @menu = [{
      name: 'normal',
      text: @_t('normalText'),
      param: 'p'
    }, '|', {
      name: 'h1',
      text: @_t('title') + ' 1',
      param: 'h1'
    }, {
      name: 'h2',
      text: @_t('title') + ' 2',
      param: 'h2'
    }, {
      name: 'h3',
      text: @_t('title') + ' 3',
      param: 'h3'
    }, {
      name: 'h4',
      text: @_t('title') + ' 4',
      param: 'h4'
    }, {
      name: 'h5',
      text: @_t('title') + ' 5',
      param: 'h5'
    }]
    super()

  setActive: (active, param) ->
    super active

    param ||= @node[0].tagName.toLowerCase() if active
    @el.removeClass 'active-p active-h1 active-h2 active-h3 active-h4 active-h5'
    @el.addClass('active active-' + param) if active

  command: (param) ->
    $rootNodes = @editor.selection.rootNodes()
    @editor.selection.save()


    $rootNodes.each (i, node) =>
      $node = $ node
      return if $node.is('blockquote') or $node.is(param) or
        $node.is(@disableTag) or @editor.util.isDecoratedNode($node)

      $('<' + param + '/>').append($node.contents())
        .replaceAll($node)

    @editor.selection.restore()
    @editor.trigger 'valuechanged'


Simditor.Toolbar.addButton TitleButton
