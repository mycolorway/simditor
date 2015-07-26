(function() {
  window.spec = {
    generateSimditor: function(opts) {
      var $textarea;
      if (opts == null) {
        opts = {};
      }
      opts.content || (opts.content = '');
      opts.toolbar || (opts.toolbar = false);
      $textarea = $('<textarea id="editor"></textarea>').val(opts.content).appendTo('body');
      return new Simditor({
        textarea: $textarea,
        toolbar: opts.toolbar
      });
    },
    destroySimditor: function() {
      var $textarea, editor;
      $textarea = $('#editor');
      editor = $textarea.data('simditor');
      if (editor != null) {
        editor.destroy();
      }
      return $textarea.remove();
    }
  };

}).call(this);
