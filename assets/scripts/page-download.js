(function() {
  $(function() {
    var $page;
    $page = $('#page-download');
    $page.on('mousedown', '.version .title', function(e) {
      var $versionEl, expanded;
      $versionEl = $(this).closest('.version');
      expanded = $versionEl.hasClass('expand');
      $versionEl.toggleClass('expand', !expanded);
      return $versionEl.find('.icon').toggleClass('simditor-icon-caret-down', !expanded).toggleClass('simditor-icon-caret-right', expanded);
    });
    return $page.on('mousedown', '.btn-download', function(e) {
      return e.stopPropagation();
    });
  });

}).call(this);
