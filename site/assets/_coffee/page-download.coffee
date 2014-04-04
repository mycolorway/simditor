
$ ->
  $page = $('#page-download')

  $page.on 'mousedown', '.version .title', (e) ->
    $versionEl = $(@).closest('.version')
    expanded = $versionEl.hasClass 'expand'
    $versionEl.toggleClass 'expand', !expanded
    $versionEl.find('.icon')
      .toggleClass('fa-caret-down', !expanded)
      .toggleClass('fa-caret-right', expanded)

