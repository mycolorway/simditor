(function() {
  $(function() {
    var $page;
    $page = $('#page-download');
    $page.on('mousedown', '.version .title', function(e) {
      var $versionEl, expanded;
      $versionEl = $(this).closest('.version');
      expanded = $versionEl.hasClass('expand');
      $versionEl.toggleClass('expand', !expanded);
      return $versionEl.find('.icon').toggleClass('fa-caret-down', !expanded).toggleClass('fa-caret-right', expanded);
    });
    return $page.on('mousedown', '.btn-download', function(e) {
      return e.stopPropagation();
    });
  });

}).call(this);
