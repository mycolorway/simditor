(function() {
  $(function() {
    var $page;
    $page = $('.page-doc');
    return $page.on('mousedown', 'dt', function(e) {
      var $dd, $dt, expanded;
      $dt = $(e.currentTarget);
      $dd = $dt.next();
      expanded = $dd.hasClass('expand');
      $dd.toggleClass('expand', !expanded);
      return $dt.find('.icon').toggleClass('fa-caret-down', !expanded).toggleClass('fa-caret-right', expanded);
    });
  });

}).call(this);
