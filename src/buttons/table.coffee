
class TableButton extends Button

  name: 'table'

  icon: 'table'

  htmlTag: 'table'

  disableTag: 'pre, li, blockquote'

  menu: true

  _init: ->
    super()

    $.merge @editor.formatter._allowedTags, ['tbody', 'tr', 'td', 'colgroup', 'col']
    $.extend(@editor.formatter._allowedAttributes, {
      td: ['rowspan', 'colspan'],
      col: ['width']
    })

    @_initShortcuts()

    @editor.on 'decorate', (e, $el) =>
      $el.find('table').each (i, table) =>
        @decorate $(table)

    @editor.on 'undecorate', (e, $el) =>
      $el.find('table').each (i, table) =>
        @undecorate $(table)

    @editor.on 'selectionchanged.table', (e) =>
      @editor.body.find('.simditor-table td').removeClass('active')
      range = @editor.selection.getRange()
      return unless range?
      $container = $(range.commonAncestorContainer)

      if range.collapsed and $container.is('.simditor-table')
        if @editor.selection.rangeAtStartOf $container
          $container = $container.find('td:first')
        else
          $container = $container.find('td:last')
        @editor.selection.setRangeAtEndOf $container

      $container.closest('td', @editor.body)
        .addClass('active')


    @editor.on 'blur.table', (e) =>
      @editor.body.find('.simditor-table td').removeClass('active')

    # press left arrow in td
    #@editor.inputManager.addKeystrokeHandler '37', 'td', (e, $node) =>
      #@editor.util.outdent()
      #true

    # press right arrow in td
    #@editor.inputManager.addKeystrokeHandler '39', 'td', (e, $node) =>
      #@editor.util.indent()
      #true

    # press up arrow in td
    @editor.inputManager.addKeystrokeHandler '38', 'td', (e, $node) =>
      $tr = $node.parent 'tr'
      $prevTr = $tr.prev 'tr'
      return true unless $prevTr.length > 0
      index = $tr.find('td').index($node)
      @editor.selection.setRangeAtEndOf $prevTr.find('td').eq(index)
      true

    # press down arrow in td
    @editor.inputManager.addKeystrokeHandler '40', 'td', (e, $node) =>
      $tr = $node.parent 'tr'
      $nextTr = $tr.next 'tr'
      return true unless $nextTr.length > 0
      index = $tr.find('td').index($node)
      @editor.selection.setRangeAtEndOf $nextTr.find('td').eq(index)
      true

  initResize: ($table) ->
    $wrapper = $table.parent '.simditor-table'

    $colgroup = $table.find 'colgroup'
    if $colgroup.length < 1
      $colgroup = $('<colgroup/>').prependTo $table
      $table.find('tr:first td').each (i, td) =>
        $col = $('<col/>').appendTo $colgroup

      @refreshTableWidth $table


    $resizeHandle = $('<div class="simditor-resize-handle" contenteditable="false"></div>')
      .appendTo($wrapper)

    $wrapper.on 'mousemove', 'td', (e) =>
      return if $wrapper.hasClass('resizing')
      $td = $(e.currentTarget)
      x = e.pageX - $(e.currentTarget).offset().left
      $td = $td.prev() if x < 5 and $td.prev().length > 0

      if $td.next('td').length < 1
        $resizeHandle.hide()
        return

      if $resizeHandle.data('td')?.is($td)
        $resizeHandle.show()
        return

      index = $td.parent().find('td').index($td)
      $col = $colgroup.find('col').eq(index)

      if $resizeHandle.data('col')?.is($col)
        $resizeHandle.show()
        return

      $resizeHandle
        .css( 'left', $td.position().left + $td.outerWidth() - 5)
        .data('td', $td)
        .data('col', $col)
        .show()

    $wrapper.on 'mouseleave', (e) =>
      $resizeHandle.hide()

    $wrapper.on 'mousedown', '.simditor-resize-handle', (e) =>
      $handle = $(e.currentTarget)
      $leftTd = $handle.data 'td'
      $leftCol = $handle.data 'col'
      $rightTd = $leftTd.next('td')
      $rightCol = $leftCol.next('col')
      startX = e.pageX
      startLeftWidth = $leftTd.outerWidth() * 1
      startRightWidth = $rightTd.outerWidth() * 1
      startHandleLeft = parseFloat $handle.css('left')
      tableWidth = $leftTd.closest('table').width()
      minWidth = 50

      $(document).on 'mousemove.simditor-resize-table', (e) =>
        deltaX = e.pageX - startX
        leftWidth = startLeftWidth + deltaX
        rightWidth = startRightWidth - deltaX
        if leftWidth < minWidth
          leftWidth = minWidth
          deltaX = minWidth - startLeftWidth
          rightWidth = startRightWidth - deltaX
        else if rightWidth < minWidth
          rightWidth = minWidth
          deltaX = startRightWidth - minWidth
          leftWidth = startLeftWidth + deltaX

        $leftCol.attr 'width', (leftWidth / tableWidth * 100) + '%'
        $rightCol.attr 'width', (rightWidth / tableWidth * 100) + '%'
        $handle.css 'left', startHandleLeft + deltaX

      $(document).one 'mouseup.simditor-resize-table', (e) =>
        $(document).off '.simditor-resize-table'
        $wrapper.removeClass 'resizing'

      $wrapper.addClass 'resizing'
      false

  _initShortcuts: ->
    @editor.inputManager.addShortcut 'ctrl+alt+up', (e) =>
      @editMenu.find('.menu-item[data-param=insertRowAbove]').click()
      false

    @editor.inputManager.addShortcut 'ctrl+alt+down', (e) =>
      @editMenu.find('.menu-item[data-param=insertRowBelow]').click()
      false

    @editor.inputManager.addShortcut 'ctrl+alt+left', (e) =>
      @editMenu.find('.menu-item[data-param=insertColLeft]').click()
      false

    @editor.inputManager.addShortcut 'ctrl+alt+right', (e) =>
      @editMenu.find('.menu-item[data-param=insertColRight]').click()
      false

  decorate: ($table) ->
    if $table.parent('.simditor-table').length > 0
      @undecorate $table

    $table.wrap '<div class="simditor-table"></div>'
    @initResize $table
    $table.parent()

  undecorate: ($table) ->
    return unless $table.parent('.simditor-table').length > 0
    $table.parent().replaceWith($table)

  renderMenu: ->
    $("""
      <div class="menu-create-table">
      </div>
      <div class="menu-edit-table">
        <ul>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="deleteRow"><span>#{ @_t 'deleteRow' }</span></a></li>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="insertRowAbove"><span>#{ @_t 'insertRowAbove' } ( Ctrl + Alt + ↑ )</span></a></li>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="insertRowBelow"><span>#{ @_t 'insertRowBelow' } ( Ctrl + Alt + ↓ )</span></a></li>
          <li><span class="separator"></span></li>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="deleteCol"><span>#{ @_t 'deleteColumn' }</span></a></li>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="insertColLeft"><span>#{ @_t 'insertColumnLeft' } ( Ctrl + Alt + ← )</span></a></li>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="insertColRight"><span>#{ @_t 'insertColumnRight' } ( Ctrl + Alt + → )</span></a></li>
          <li><span class="separator"></span></li>
          <li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;" data-param="deleteTable"><span>#{ @_t 'deleteTable' }</span></a></li>
        </ul>
      </div>
    """).appendTo(@menuWrapper)

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
      $table = @createTable(rowNum, colNum, true)

      $closestBlock = @editor.util.closestBlockEl()
      if @editor.util.isEmptyNode $closestBlock
        $closestBlock.replaceWith $table
      else
        $closestBlock.after $table

      @decorate $table
      @editor.selection.setRangeAtStartOf $table.find('td:first')
      @editor.trigger 'valuechanged'
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

  refreshTableWidth: ($table)->
    tableWidth = $table.width()
    cols = $table.find('col')
    $table.find('tr:first td').each (i, td) =>
      $col = cols.eq(i)
      $col.attr 'width', ($(td).outerWidth() / tableWidth * 100) + '%'

  setActive: (active) ->
    super active

    if active
      @createMenu.hide()
      @editMenu.show()
    else
      @createMenu.show()
      @editMenu.hide()

  deleteRow: ($td) ->
    $tr = $td.parent 'tr'
    if $tr.siblings('tr').length < 1
      @deleteTable $td
    else
      $newTr = $tr.next 'tr'
      $newTr = $tr.prev 'tr' unless $newTr.length > 0
      index = $tr.find('td').index($td)
      $tr.remove()
      @editor.selection.setRangeAtEndOf $newTr.find('td').eq(index)

  insertRow: ($td, direction = 'after') ->
    $tr = $td.parent 'tr'
    $table = $tr.closest 'table'

    colNum = 0
    $table.find('tr').each (i, tr) =>
      colNum = Math.max colNum, $(tr).find('td').length

    $newTr = $('<tr/>')
    for i in [1..colNum]
      $('<td/>').append(@editor.util.phBr).appendTo($newTr)

    $tr[direction] $newTr
    index = $tr.find('td').index($td)
    @editor.selection.setRangeAtStartOf $newTr.find('td').eq(index)

  deleteCol: ($td) ->
    $tr = $td.parent 'tr'
    if $tr.siblings('tr').length < 1 and $td.siblings('td').length < 1
      @deleteTable $td
    else
      index = $tr.find('td').index($td)
      $newTd = $td.next 'td'
      $newTd = $tr.prev 'td' unless $newTd.length > 0
      $table = $tr.closest 'table'

      $table.find('col').eq(index).remove()
      $table.find('tr').each (i, tr) =>
        $(tr).find('td').eq(index).remove()
      @refreshTableWidth $table

      @editor.selection.setRangeAtEndOf $newTd

  insertCol: ($td, direction = 'after') ->
    $tr = $td.parent 'tr'
    index = $tr.find('td').index($td)
    $table = $td.closest 'table'
    $col = $table.find('col').eq(index)

    $table.find('tr').each (i, tr) =>
      $newTd = $('<td/>').append(@editor.util.phBr)
      $(tr).find('td').eq(index)[direction] $newTd

    $newCol = $('<col/>')
    $col[direction] $newCol

    tableWidth = $table.width()
    width = Math.max parseFloat($col.attr('width')) / 2, 50 / tableWidth * 100
    $col.attr 'width', width + '%'
    $newCol.attr 'width', width + '%'
    @refreshTableWidth $table

    $newTd = if direction == 'after' then $td.next('td') else $td.prev('td')
    @editor.selection.setRangeAtStartOf $newTd

  deleteTable: ($td) ->
    $table = $td.closest '.simditor-table'
    $block = $table.next('p')
    $table.remove()
    @editor.selection.setRangeAtStartOf($block) if $block.length > 0

  command: (param) ->
    range = @editor.selection.getRange()
    $td = $(range.commonAncestorContainer).closest('td')
    return unless $td.length > 0

    if param == 'deleteRow'
      @deleteRow $td
    else if param == 'insertRowAbove'
      @insertRow $td, 'before'
    else if param == 'insertRowBelow'
      @insertRow $td
    else if param == 'deleteCol'
      @deleteCol $td
    else if param == 'insertColLeft'
      @insertCol $td, 'before'
    else if param == 'insertColRight'
      @insertCol $td
    else if param == 'deleteTable'
      @deleteTable $td
    else
      return

    @editor.trigger 'valuechanged'


Simditor.Toolbar.addButton TableButton

