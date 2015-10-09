
$ ->
  $page = $('#page-download')

  $page.on 'mousedown', '.version .title', (e) ->
    $versionEl = $(@).closest('.version')
    expanded = $versionEl.hasClass 'expand'
    $versionEl.toggleClass 'expand', !expanded
    $versionEl.find('.icon')
      .toggleClass('simditor-icon-caret-down', !expanded)
      .toggleClass('simditor-icon-caret-right', expanded)

  $page.on 'mousedown', '.btn-download', (e) ->
    e.stopPropagation()

