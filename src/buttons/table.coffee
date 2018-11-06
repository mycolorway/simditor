
class TableButton extends Button

  name: 'table'

  icon: 'table'

  htmlTag: 'table'

  disableTag: 'pre, li, blockquote'

  menu: true

  _init: ->
    super()

    $.merge(
      @editor.formatter._allowedTags,
      ['thead', 'th', 'tbody', 'tr', 'td', 'colgroup', 'col']
    )

    $.extend @editor.formatter._allowedAttributes,
      td: ['rowspan', 'colspan'],
      col: ['width']

    $.extend @editor.formatter._allowedStyles,
      td: ['text-align']
      th: ['text-align']

    @_initShortcuts()
    @_initResize()

    @editor.on 'decorate', (e, $el) =>
      $el.find('table').each (i, table) =>
        @decorate $(table)

    @editor.on 'undecorate', (e, $el) =>
      $el.find('table').each (i, table) =>
        @undecorate $(table)

    @editor.on 'selectionchanged.table', (e) =>
      @editor.body.find('.simditor-table td, .simditor-table th')
        .removeClass('active')
      range = @editor.selection.range()
      return unless range
      $container = @editor.selection.containerNode()

      if range.collapsed and $container.is('.simditor-table')
        @editor.selection.setRangeAtEndOf $container

      $container.closest('td, th', @editor.body)
        .addClass('active')

    @editor.on 'blur.table', (e) =>
      @editor.body.find('.simditor-table td, .simditor-table th')
        .removeClass('active')

    # press up arrow in td
    @editor.keystroke.add 'up', 'td', (e, $node) =>
      @_tdNav($node, 'up')
      true

    @editor.keystroke.add 'up', 'th', (e, $node) =>
      @_tdNav($node, 'up')
      true

    # press down arrow in td
    @editor.keystroke.add 'down', 'td', (e, $node) =>
      @_tdNav($node, 'down')
      true

    @editor.keystroke.add 'down', 'th', (e, $node) =>
      @_tdNav($node, 'down')
      true

  _tdNav: ($td, direction = 'up') ->
    action = if direction == 'up' then 'prev' else 'next'
    [parentTag, anotherTag] = if direction == 'up'
      ['tbody', 'thead']
    else
      ['thead', 'tbody']
    $tr = $td.parent 'tr'
    $anotherTr = @["_#{action}Row"]($tr)
    return true unless $anotherTr.length > 0
    index = $tr.find('td, th').index($td)
    @editor.selection.setRangeAtEndOf $anotherTr.find('td, th').eq(index)

  _nextRow: ($tr) ->
    $nextTr = $tr.next 'tr'
    if $nextTr.length < 1 and $tr.parent('thead').length > 0
      $nextTr = $tr.parent('thead').next('tbody').find('tr:first')
    $nextTr

  _prevRow: ($tr) ->
    $prevTr = $tr.prev 'tr'
    if $prevTr.length < 1 and $tr.parent('tbody').length > 0
      $prevTr = $tr.parent('tbody').prev('thead').find('tr')
    $prevTr

  _initResize: ->
    $editor = @editor

    $(document).on 'mousemove.simditor-table', '.simditor-table td, .simditor-table th', (e) ->
      $wrapper = $(@).parents '.simditor-table'
      $resizeHandle = $wrapper.find '.simditor-resize-handle'
      $colgroup = $wrapper.find 'colgroup'

      return if $wrapper.hasClass 'resizing'

      $td = $(e.currentTarget)
      x = e.pageX - $(e.currentTarget).offset().left
      $td = $td.prev() if x < 5 and $td.prev().length > 0

      if $td.next('td, th').length < 1
        $resizeHandle.hide()
        return

      if $resizeHandle.data('td')?.is($td)
        $resizeHandle.show()
        return

      index = $td.parent().find('td, th').index($td)
      $col = $colgroup.find('col').eq(index)

      if $resizeHandle.data('col')?.is($col)
        $resizeHandle.show()
        return

      $resizeHandle
        .css( 'left', $td.position().left + $td.outerWidth() - 5)
        .data('td', $td)
        .data('col', $col)
        .show()

    $(document).on 'mouseleave.simditor-table', '.simditor-table', (e) ->
      $(@).find('.simditor-resize-handle').hide()

    $(document).on 'mousedown.simditor-resize-handle', '.simditor-resize-handle', (e) ->
      $wrapper = $(@).parent('.simditor-table')
      $handle = $(e.currentTarget)
      $leftTd = $handle.data 'td'
      $leftCol = $handle.data 'col'
      $rightTd = $leftTd.next('td, th')
      $rightCol = $leftCol.next('col')
      startX = e.pageX
      startLeftWidth = $leftTd.outerWidth() * 1
      startRightWidth = $rightTd.outerWidth() * 1
      startHandleLeft = parseFloat $handle.css('left')
      tableWidth = $leftTd.closest('table').width()
      minWidth = 50

      $(document).on 'mousemove.simditor-resize-table', (e) ->
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

      $(document).one 'mouseup.simditor-resize-table', (e) ->
        $editor.sync()
        $(document).off '.simditor-resize-table'
        $wrapper.removeClass 'resizing'

      $wrapper.addClass 'resizing'
      false

  _initShortcuts: ->
    @editor.hotkeys.add 'ctrl+alt+up', (e) =>
      @editMenu.find('.menu-item[data-param=insertRowAbove]').click()
      false

    @editor.hotkeys.add 'ctrl+alt+down', (e) =>
      @editMenu.find('.menu-item[data-param=insertRowBelow]').click()
      false

    @editor.hotkeys.add 'ctrl+alt+left', (e) =>
      @editMenu.find('.menu-item[data-param=insertColLeft]').click()
      false

    @editor.hotkeys.add 'ctrl+alt+right', (e) =>
      @editMenu.find('.menu-item[data-param=insertColRight]').click()
      false

  decorate: ($table) ->
    if $table.parent('.simditor-table').length > 0
      @undecorate $table

    $table.wrap '<div class="simditor-table"></div>'

    $wrapper = $table.parent '.simditor-table'
    $colgroup = $table.find 'colgroup'

    # table must have a thead
    if $table.find('thead').length < 1
      $thead = $('<thead />')
      $headRow = $table.find('tr').first()
      $thead.append $headRow
      @_changeCellTag $headRow, 'th'

      $tbody = $table.find 'tbody'
      if $tbody.length > 0
        $tbody.before $thead
      else
        $table.prepend $thead

    if $colgroup.length < 1
      $colgroup = $('<colgroup/>').prependTo $table
      $table.find('thead tr th').each (i, td) ->
        $col = $('<col/>').appendTo $colgroup

      @refreshTableWidth $table

    $resizeHandle = $ '<div />',
      class: 'simditor-resize-handle'
      contenteditable: 'false'
    .appendTo($wrapper)

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
          <li>
            <a tabindex="-1" unselectable="on" class="menu-item"
              href="javascript:;" data-param="deleteRow">
              <span>#{ @_t 'deleteRow' }</span>
            </a>
          </li>
          <li>
            <a tabindex="-1" unselectable="on" class="menu-item"
              href="javascript:;" data-param="insertRowAbove">
              <span>#{ @_t 'insertRowAbove' } ( Ctrl + Alt + ↑ )</span>
            </a>
          </li>
          <li>
            <a tabindex="-1" unselectable="on" class="menu-item"
              href="javascript:;" data-param="insertRowBelow">
              <span>#{ @_t 'insertRowBelow' } ( Ctrl + Alt + ↓ )</span>
            </a>
          </li>
          <li><span class="separator"></span></li>
          <li>
            <a tabindex="-1" unselectable="on" class="menu-item"
              href="javascript:;" data-param="deleteCol">
              <span>#{ @_t 'deleteColumn' }</span>
            </a>
          </li>
          <li>
            <a tabindex="-1" unselectable="on" class="menu-item"
              href="javascript:;" data-param="insertColLeft">
              <span>#{ @_t 'insertColumnLeft' } ( Ctrl + Alt + ← )</span>
            </a>
          </li>
          <li>
            <a tabindex="-1" unselectable="on" class="menu-item"
              href="javascript:;" data-param="insertColRight">
              <span>#{ @_t 'insertColumnRight' } ( Ctrl + Alt + → )</span>
            </a>
          </li>
          <li><span class="separator"></span></li>
          <li>
            <a tabindex="-1" unselectable="on" class="menu-item"
              href="javascript:;" data-param="deleteTable">
              <span>#{ @_t 'deleteTable' }</span>
            </a>
          </li>
        </ul>
      </div>
    """).appendTo(@menuWrapper)

    @createMenu = @menuWrapper.find('.menu-create-table')
    @editMenu = @menuWrapper.find('.menu-edit-table')
    $table = @createTable(6, 6).appendTo @createMenu

    @createMenu.on 'mouseenter', 'td, th', (e) =>
      @createMenu.find('td, th').removeClass('selected')

      $td = $(e.currentTarget)
      $tr = $td.parent()
      num = $tr.find('td, th').index($td) + 1
      $trs = $tr.prevAll('tr').addBack()
      $trs = $trs.add($table.find('thead tr')) if $tr.parent().is('tbody')
      $trs.find("td:lt(#{num}), th:lt(#{num})").addClass('selected')

    @createMenu.on 'mouseleave', (e) ->
      $(e.currentTarget).find('td, th').removeClass('selected')

    @createMenu.on 'mousedown', 'td, th', (e) =>
      @wrapper.removeClass('menu-on')
      return unless @editor.inputManager.focused

      $td = $(e.currentTarget)
      $tr = $td.parent()
      colNum = $tr.find('td').index($td) + 1
      rowNum = $tr.prevAll('tr').length + 1
      rowNum += 1 if $tr.parent().is('tbody')
      $table = @createTable(rowNum, colNum, true)

      $closestBlock = @editor.selection.blockNodes().last()
      if @editor.util.isEmptyNode $closestBlock
        $closestBlock.replaceWith $table
      else
        $closestBlock.after $table

      @decorate $table
      @editor.selection.setRangeAtStartOf $table.find('th:first')
      @editor.trigger 'valuechanged'
      false

  createTable: (row, col, phBr) ->
    $table = $('<table/>')
    $thead = $('<thead/>').appendTo $table
    $tbody = $('<tbody/>').appendTo $table
    for r in [0...row]
      $tr = $('<tr/>')
      $tr.appendTo(if r == 0 then $thead else $tbody)
      for c in [0...col]
        $td = $(if r == 0 then '<th/>' else '<td/>').appendTo $tr
        $td.append(@editor.util.phBr) if phBr
    $table

  refreshTableWidth: ($table)->
    # 解决无法在第一时间获取粘贴 table 宽度的问题
    setTimeout =>
      tableWidth = $table.width()
      cols = $table.find('col')
      $table.find('thead tr th').each (i, td) ->
        $col = cols.eq(i)
        $col.attr 'width', ($(td).outerWidth() / tableWidth * 100) + '%'
    , 0

  setActive: (active) ->
    super active

    if active
      @createMenu.hide()
      @editMenu.show()
    else
      @createMenu.show()
      @editMenu.hide()

  _changeCellTag: ($tr, tagName) ->
    $tr.find('td, th').each (i, cell) ->
      $cell = $(cell)
      $cell.replaceWith("<#{tagName}>#{$cell.html()}</#{tagName}>")

  deleteRow: ($td) ->
    $tr = $td.parent 'tr'
    if $tr.closest('table').find('tr').length < 1
      @deleteTable $td
    else
      $newTr = @_nextRow $tr
      $newTr = @_prevRow($tr) unless $newTr.length > 0
      index = $tr.find('td, th').index($td)

      if $tr.parent().is('thead')
        $newTr.appendTo $tr.parent()
        @_changeCellTag $newTr, 'th'
      $tr.remove()

      @editor.selection.setRangeAtEndOf $newTr.find('td, th').eq(index)

  insertRow: ($td, direction = 'after') ->
    $tr = $td.parent 'tr'
    $table = $tr.closest 'table'

    colNum = 0
    $table.find('tr').each (i, tr) ->
      colNum = Math.max colNum, $(tr).find('td').length

    index = $tr.find('td, th').index($td)
    $newTr = $('<tr/>')
    cellTag = 'td'

    if direction == 'after' and $tr.parent().is('thead')
      $tr.parent().next('tbody').prepend($newTr)
    else if direction == 'before' and $tr.parent().is('thead')
      $tr.before $newTr
      $tr.parent().next('tbody').prepend($tr)
      @_changeCellTag $tr, 'td'
      cellTag = 'th'
    else
      $tr[direction] $newTr

    for i in [1..colNum]
      $("<#{cellTag}/>").append(@editor.util.phBr).appendTo($newTr)

    @editor.selection.setRangeAtStartOf $newTr.find('td, th').eq(index)

  deleteCol: ($td) ->
    $tr = $td.parent 'tr'
    noOtherRow = $tr.closest('table').find('tr').length < 2
    noOtherCol = $td.siblings('td, th').length < 1
    if noOtherRow and noOtherCol
      @deleteTable $td
    else
      index = $tr.find('td, th').index($td)
      $newTd = $td.next 'td, th'
      $newTd = $tr.prev 'td, th' unless $newTd.length > 0
      $table = $tr.closest 'table'

      $table.find('col').eq(index).remove()
      $table.find('tr').each (i, tr) ->
        $(tr).find('td, th').eq(index).remove()
      @refreshTableWidth $table

      @editor.selection.setRangeAtEndOf $newTd

  insertCol: ($td, direction = 'after') ->
    $tr = $td.parent 'tr'
    index = $tr.find('td, th').index($td)
    $table = $td.closest 'table'
    $col = $table.find('col').eq(index)

    $table.find('tr').each (i, tr) =>
      cellTag = if $(tr).parent().is('thead') then 'th' else 'td'
      $newTd = $("<#{cellTag}/>").append(@editor.util.phBr)
      $(tr).find('td, th').eq(index)[direction] $newTd

    $newCol = $('<col/>')
    $col[direction] $newCol

    tableWidth = $table.width()
    width = Math.max parseFloat($col.attr('width')) / 2, 50 / tableWidth * 100
    $col.attr 'width', width + '%'
    $newCol.attr 'width', width + '%'
    @refreshTableWidth $table

    $newTd = if direction == 'after'
      $td.next('td, th')
    else
      $td.prev('td, th')
    @editor.selection.setRangeAtStartOf $newTd

  deleteTable: ($td) ->
    $table = $td.closest '.simditor-table'
    $block = $table.next('p')
    $table.remove()
    @editor.selection.setRangeAtStartOf($block) if $block.length > 0

  command: (param) ->
    $td = @editor.selection.containerNode().closest('td, th')
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
