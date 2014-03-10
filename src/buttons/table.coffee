
class TableButton extends Button

  name: 'table'

  icon: 'table'

  title: '表格'

  htmlTag: 'table'

  disableTag: 'pre, li, blockquote'

  menu: true

  constructor: (args...) ->
    super args...

    @editor.on 'decorate', (e, $el) =>
      $el.find('table').each (i, table) =>
        @decorate $(table)

    @editor.on 'undecorate', (e, $el) =>
      $el.find('table').each (i, table) =>
        @undecorate $(table)

    @editor.on 'selectionchanged.table', (e) =>
      @editor.body.find('.simditor-table td').removeClass('active')
      range = @editor.selection.getRange()
      $(range.commonAncestorContainer)
        .closest('td', @editor.body)
        .addClass('active')

    @editor.on 'blur.table', (e) =>
      @editor.body.find('.simditor-table td').removeClass('active')

  decorate: ($table) ->
    return if $table.parent('.simditor-table').length > 0
    $table.wrap '<div class="simditor-table"></div>'
    $table.parent()

  undecorate: ($table) ->
    return unless $table.parent('.simditor-table').length > 0
    $table.parent().replaceWith($table)

  renderMenu: ->
    $('''
      <div class="menu-create-table">
      </div>
      <div class="menu-edit-table">
        <ul>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="deleteTable"><span>删除表格</span></a></li>
        </ul>
      </div>
    ''').appendTo(@menuWrapper)

    @createMenu = @menuWrapper.find('.menu-create-table')
    @editMenu = @menuWrapper.find('.menu-edit-table')
    @createTable(6, 6).appendTo @createMenu

    @createMenu.on 'mouseenter', 'td', (e) =>
      @createMenu.find('td').removeClass('selected')

      $td = $(e.currentTarget)
      $tr = $td.parent()
      num = $tr.find('td').index($td) + 1
      $tr.prevAll('tr').addBack().find('td:lt(' + num + ')').addClass('selected')

    @createMenu.on 'mouseleave', (e) =>
      $(e.currentTarget).find('td').removeClass('selected')

    @createMenu.on 'mousedown', 'td', (e) =>
      @wrapper.removeClass('menu-on')
      return unless @editor.inputManager.focused

      $td = $(e.currentTarget)
      $tr = $td.parent()
      colNum = $tr.find('td').index($td) + 1
      rowNum = $tr.prevAll('tr').length + 1
      $table = @decorate @createTable(rowNum, colNum, true)

      $closestBlock = @editor.util.closestBlockEl()
      if @editor.util.isEmptyNode $closestBlock
        $closestBlock.replaceWith $table
      else
        $closestBlock.after $table

      @editor.selection.setRangeAtStartOf $table.find('td:first')
      @editor.trigger 'valuechanged'
      @editor.trigger 'selectionchanged'
      false

  createTable: (row, col, phBr) ->
    $table = $('<table/>')
    $tbody = $('<tbody/>').appendTo $table
    for r in [0...row]
      $tr = $('<tr/>').appendTo $tbody
      for c in [0...col]
        $td = $('<td/>').appendTo $tr
        $td.append(@editor.util.phBr) if phBr
    $table

  setActive: (active) ->
    super active

    if active
      @createMenu.hide()
      @editMenu.show()
    else
      @createMenu.show()
      @editMenu.hide()

  command: (param) ->
    #if param == 'deleteTable'
      # TODO


Simditor.Toolbar.addButton TableButton

