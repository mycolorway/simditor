(function() {
  var Format, Input, Selection, Simditor, Util, Widget, _ref,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Widget = (function() {
    Widget.extend = function(opts) {
      var key, val, _results;
      _results = [];
      for (key in opts) {
        val = opts[key];
        if (key === '_load') {
          _results.push(this.prototype._loadCallbacks.push(val));
        } else if (key === '_init') {
          _results.push(this.prototype._initCallbacks.push(val));
        } else if (key === 'opts') {
          _results.push($.extend(this.prototype._extendOpts, val));
        } else if (key !== '_loadCallbacks' && key !== '_initCallbacks' && key !== 'opts') {
          _results.push(this.prototype[key] = val);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Widget.prototype._loadCallbacks = [];

    Widget.prototype._initCallbacks = [];

    Widget.prototype._extendOpts = {};

    Widget.prototype._load = function() {};

    Widget.prototype._init = function() {};

    Widget.prototype.opts = {};

    function Widget(opts) {
      var init, load, _i, _j, _len, _len1, _ref, _ref1;
      $.extend(this.opts, this._extendOpts, opts);
      this._load(this.opts);
      _ref = this._loadCallbacks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        load = _ref[_i];
        load.call(this);
      }
      this._init(this.opts);
      _ref1 = this._initCallbacks;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        init = _ref1[_j];
        init.call(this);
      }
    }

    Widget.prototype.on = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = $(this)).on.apply(_ref, args);
    };

    Widget.prototype.trigger = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = $(this)).trigger.apply(_ref, args);
    };

    Widget.prototype.triggerHandler = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = $(this)).triggerHandler.apply(_ref, args);
    };

    Widget.prototype.destroy = function() {};

    return Widget;

  })();

  Format = {
    _allowedTags: ['p', 'ul', 'ol', 'li', 'blockquote', 'hr', 'pre', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'table'],
    _load: function() {},
    _init: function() {
      var _this = this;
      return this.body.on('click', 'a', function(e) {
        return false;
      });
    },
    _decorate: function($el) {
      if ($el == null) {
        $el = this.body;
      }
      return this.trigger('decorate', [$el]);
    },
    _undecorate: function($el) {
      var emptyP, lastP;
      if ($el == null) {
        $el = this.body.clone();
      }
      this.trigger('undecorate', [$el]);
      this.autolink($el);
      lastP = $el.children().last('p');
      while (lastP.is('p' && !lastP.text() && !lastP.find('img').length)) {
        emptyP = lastP;
        lastP = lastP.prev('p');
        emptyP.remove();
      }
      return $.trim($el.html());
    },
    autolink: function($el) {
      var $node, findLinkNode, linkNodes, re, text, _i, _len;
      if ($el == null) {
        $el = this.body;
      }
      linkNodes = [];
      findLinkNode = function($parentNode) {
        return $parentNode.contents().each(function(i, node) {
          var $node, text;
          $node = $(node);
          if ($node.is('a') || el.closest('a', $el).length) {
            return;
          }
          if ($node.contents().length) {
            return findLinkNode($node);
          } else if (text = $node.text() && /https?:\/\/|www\./ig.test(text)) {
            return linkNodes.push($node);
          }
        });
      };
      findLinkNode($el);
      re = /(https?:\/\/|www\.)[\w\-\.\?&=\/]+/ig;
      for (_i = 0, _len = linkNodes.length; _i < _len; _i++) {
        $node = linkNodes[_i];
        text = $node.text().replace(re, function(link) {
          var uri;
          if (/^(http(s)?:\/\/|\/)/.test(link)) {
            uri = link;
          } else {
            uri = 'http://' + link;
          }
          return '<a href="' + uri + '" rel="nofollow">' + link + '</a>';
        });
        if ($node[0].nodeType === 3) {
          $node.replaceWith(text);
        } else {
          $node.html(text);
        }
      }
      return $el;
    },
    format: function($el) {
      var blockNode, node, _i, _len, _ref, _results;
      if ($el == null) {
        $el = this.body;
      }
      if ($el.is(':empty')) {
        $el.append('<p>' + this._placeholderBr + '</p>');
        return $el;
      }
      _ref = $el.contents();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        node = _ref[_i];
        if (this.isBlockNode(node)) {
          if (typeof blockNode !== "undefined" && blockNode !== null) {
            this.cleanNode(blockNode);
          }
          this.cleanNode(node);
          _results.push(blockNode = null);
        } else {
          if (blockNode == null) {
            blockNode = $('<p/>').insertBefore(node);
          }
          _results.push(blockNode.append(node));
        }
      }
      return _results;
    },
    cleanNode: function(node, recursive) {
      var $node, attr, contents, n, _i, _j, _len, _len1, _ref, _ref1, _ref2, _results;
      $node = $(node);
      if ($node[0].nodeType === 3) {
        return;
      }
      contents = $node.contents();
      if ($node.is(this._allowedTags.join(','))) {
        _ref = $.makeArray($node[0].attributes);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          attr = _ref[_i];
          if (!($node.is('img' && ((_ref1 = attr.name) === 'src' || _ref1 === 'alt'))) && !($node.is('a' && ((_ref2 = attr.name) === 'href' || _ref2 === 'target')))) {
            $node.removeAttr(attr.name);
          }
        }
      } else if ($node[0].nodeType === 1 && !$node.is(':empty')) {
        $('<p/>').append(contents).insertBefore($node);
        $node.remove();
      } else {
        $node.remove();
        contents = null;
      }
      if (recursive && (contents != null)) {
        _results = [];
        for (_j = 0, _len1 = contents.length; _j < _len1; _j++) {
          n = contents[_j];
          _results.push(cleanNode(n));
        }
        return _results;
      }
    }
  };

  Input = {
    opts: {
      tabIndent: true
    },
    _modifierKeys: [16, 17, 18, 91, 93],
    _arrowKeys: [37, 38, 39, 40],
    _load: function() {},
    _init: function() {
      var _this = this;
      this.body.on('keydown', $.proxy(this._onKeyDown, this)).on('mouseUp', $.proxy(this._onMouseUp, this)).on('focus', $.proxy(this._onFocus, this)).on('blur', $.proxy(this._onBlur, this)).on('paste', $.proxy(this._onPaste, this));
      if (this.textarea.attr('autofocus')) {
        return setTimeout(function() {
          return _this.body.focus();
        }, 0);
      }
    },
    _onFocus: function(e) {
      this.el.addClass('focus').removeClass('error');
      this.focused = true;
      return this.format();
    },
    _onBlur: function(e) {
      this.el.removeClass('focus');
      return this.focused = false;
    },
    _onMouseUp: function(e) {
      return this.trigger('selectionchanged');
    },
    _onKeyDown: function(e) {
      var $blockEl, $br, $prevBlockEl, metaKey, spaceNode, spaces, _ref, _ref1,
        _this = this;
      if (this.triggerHandler(e) === false) {
        return false;
      }
      if ((_ref = e.which, __indexOf.call(this._modifierKeys, _ref) >= 0) || (_ref1 = e.which, __indexOf.call(this._arrowKeys, _ref1) >= 0)) {
        return;
      }
      metaKey = this.metaKey(e);
      $blockEl = this.closestBlockEl();
      if (e.which === 13 && metaKey) {
        e.preventDefault();
        this.el.closest('form').find('button:submit').click();
        return;
      }
      if (this.browser.safari && e.which === 13 && e.shiftKey) {
        $br = $('<br/>');
        if (this.rangeAtEndOf($blockEl)) {
          this.insertNode($br);
          this.insertNode($('<br/>'));
          this.setRangeBefore($br);
        } else {
          this.insertNode($br);
        }
        this.trigger('valuechanged');
        return false;
      }
      if (e.which === 8) {
        $prevBlockEl = $blockEl.prev();
        if ($prevBlockEl.is('hr' && this.rangeAtStartOf($blockEl))) {
          $prevBlockEl.remove();
          this.trigger('valuechanged');
          return false;
        }
      }
      if (e.which === 9 && (this.opts.tabIndent || $blockEl.is('pre'))) {
        spaces = $blockEl.is('pre') ? '\u00A0\u00A0' : '\u00A0\u00A0\u00A0\u00A0';
        spaceNode = document.createTextNode(spaces);
        this.insertNode(spaceNode);
        this.trigger('valuechanged');
        return false;
      }
      if (e.which in this._inputHandlers) {
        this.traverseUp(function(node) {
          var handler, _ref2;
          if (node.nodeType !== 1) {
            return;
          }
          handler = (_ref2 = _this._inputHandlers[e.which]) != null ? _ref2[node.tagName.toLowerCase()] : void 0;
          return handler != null ? handler.call(_this, $(node)) : void 0;
        });
      }
      if (this._typing) {
        clearTimeout(this._typing);
      }
      return this._typing = setTimeout(function() {
        _this.trigger('valuechanged');
        _this.trigger('selectionchanged');
        return _this._typing = false;
      });
    },
    _onKeyUp: function(e) {
      var _ref;
      if (this.triggerHandler(e) === false) {
        return false;
      }
      if (_ref = e.which, __indexOf.call(this._arrowKeys, _ref) >= 0) {
        this.trigger('selectionchanged');
        return;
      }
      if (e.which === 8 && this.body.is(':empty')) {
        $('<p/>').append(this._placeholderBr.appendTo(this.body));
      }
    },
    _onPaste: function(e) {},
    _inputHandlers: {
      13: {
        li: function($node) {},
        pre: function($node) {},
        blockquote: function($node) {}
      }
    }
  };

  Selection = {
    _load: function() {
      return this.sel = document.getSelection();
    },
    _init: function() {},
    getRange: function() {
      if (!this.focused || !this.sel.rangeCount) {
        return null;
      }
      return this.sel.getRangeAt(0);
    },
    rangeAtEndOf: function(node, range) {
      var endNode, result,
        _this = this;
      if (range == null) {
        range = this.getRange();
      }
      if (range == null) {
        return;
      }
      node = $(node)[0];
      endNode = range.endContainer;
      if (range.endOffset !== this.getNodeLength(endNode)) {
        return false;
      }
      if (node === endNode) {
        return true;
      } else if (!$.contains(node, endNode)) {
        return false;
      }
      result = true;
      $(endNode).parentsUntil(node).addBack().each(function(i, n) {
        var nodes;
        nodes = $(n).parent().contents().filter(function() {
          return !(this.nodeType === 3 && !this.nodeValue);
        });
        if (nodes.last().get(0) !== n) {
          return result = false;
        }
      });
      return result;
    },
    rangeAtStartOf: function(node, range) {
      var result, startNode,
        _this = this;
      if (range == null) {
        range = this.getRange();
      }
      if (range == null) {
        return;
      }
      node = $(node)[0];
      startNode = range.startContainer;
      if (range.startOffset !== 0) {
        return false;
      }
      if (node === startNode) {
        return true;
      } else if (!$.contains(node, startNode)) {
        return false;
      }
      result = true;
      $(startNode).parentsUntil(node).addBack().each(function(i, n) {
        var nodes;
        nodes = $(n).parent().contents().filter(function() {
          return !(this.nodeType === 3 && !this.nodeValue);
        });
        if (nodes.first().get(0) !== n) {
          return result = false;
        }
      });
      return result;
    },
    insertNode: function(node, range) {
      if (range == null) {
        range = this.getRange();
      }
      if (range == null) {
        return;
      }
      node = $(node)[0];
      range.insertNode(node);
      return this.setRangeAfter(node);
    },
    setRangeAfter: function(node, range) {
      if (range == null) {
        range = this.getRange();
      }
      if (range == null) {
        return;
      }
      node = $(node)[0];
      range.setEndAfter(node);
      range.collapse();
      this.sel.removeAllRanges();
      return this.sel.addRange(range);
    },
    setRangeBefore: function(node, range) {
      if (range == null) {
        range = this.getRange();
      }
      if (range == null) {
        return;
      }
      node = $(node)[0];
      range.setEndBefore(node);
      range.collapse();
      this.sel.removeAllRanges();
      return this.sel.addRange(range);
    }
  };

  Util = {
    _load: function() {
      if (this.browser.msie) {
        return this._placeholderBr = '';
      }
    },
    _placeholderBr: '<br/>',
    browser: (function() {
      var chrome, firefox, ie, safari, ua;
      ua = navigator.userAgent;
      ie = /(msie|trident)/i.test(ua);
      chrome = /chrome|crios/i.test(ua);
      safari = /safari/i.test(ua) && !chrome;
      firefox = /firefox/i.test(ua);
      if (ie) {
        return {
          msie: true,
          version: ua.match(/(msie |rv:)(\d+(\.\d+)?)/i)[2]
        };
      } else if (chrome) {
        return {
          webkit: true,
          chrome: true,
          version: ua.match(/(?:chrome|crios)\/(\d+(\.\d+)?)/i)[1]
        };
      } else if (safari) {
        return {
          webkit: true,
          safari: true,
          version: ua.match(/version\/(\d+(\.\d+)?)/i)[1]
        };
      } else if (firefox) {
        return {
          mozilla: true,
          firefox: true,
          version: ua.match(/firefox\/(\d+(\.\d+)?)/i)[1]
        };
      } else {
        return {};
      }
    })(),
    metaKey: function(e) {
      var isMac;
      isMac = /Mac/.test(navigator.userAgent);
      if (isMac) {
        return e.metaKey;
      } else {
        return e.ctrlKey;
      }
    },
    isBlockNode: function(node) {
      node = $(node)[0];
      if (!node || node.nodeType === 3) {
        return false;
      }
      return /^(div|p|ul|ol|li|blockquote|hr|pre|h1|h2|h3|h4|h5|h6|table)$/.test(node.nodeName.toLowerCase());
    },
    closestBlockEl: function(node) {
      var $node, blockEl, range,
        _this = this;
      if (node == null) {
        range = this.getRange();
        node = range != null ? range.commonAncestorContainer : void 0;
      }
      $node = $(node);
      if (!$node.length) {
        return null;
      }
      blockEl = $node.parentsUntil(this.body).addBack();
      blockEl = blockEl.filter(function(i) {
        return _this.isBlockNode(blockEl.eq(i));
      });
      if (blockEl.length) {
        return blockEl;
      } else {
        return null;
      }
    },
    getNodeLength: function(node) {
      switch (node.nodeType) {
        case 7:
        case 10:
          return 0;
        case 3:
        case 8:
          return node.length;
        default:
          return node.childNodes.length;
      }
    },
    traverseUp: function(callback, node) {
      var range,
        _this = this;
      if (node == null) {
        range = this.getRange();
        node = range != null ? range.commonAncestorContainer : void 0;
      }
      if ((node == null) || !$.contains(this.body[0], node)) {
        return;
      }
      return $(node).parentsUntil(this.body).addBack().each(function(i, n) {
        return callback(n);
      });
    }
  };

  Simditor = (function(_super) {
    __extends(Simditor, _super);

    function Simditor() {
      _ref = Simditor.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Simditor.extend(Util);

    Simditor.extend(Input);

    Simditor.extend(Format);

    Simditor.extend(Selection);

    Simditor.count = 0;

    Simditor.prototype.opts = {
      textarea: null
    };

    Simditor.prototype._init = function() {
      var editor, form, val,
        _this = this;
      this.textarea = $(this.opts.textarea);
      if (!this.textarea.length) {
        throw new Error('simditor: param textarea is required.');
        return;
      }
      editor = this.textarea.data('simditor');
      if (editor != null) {
        editor.destroy();
      }
      this.id = ++Simditor.count;
      this._render();
      form = this.textarea.closest('form');
      if (form.length) {
        form.on('submit.simditor-' + this.id, function() {
          return _this.sync();
        });
        form.on('reset.simditor-' + this.id, function() {
          return _this.setValue('');
        });
      }
      if (val = this.textarea.val()) {
        this.setValue(val != null ? val : '');
        setTimeout(function() {
          return _this.trigger('valuechanged');
        }, 0);
      }
      if (this.browser.mozilla) {
        document.execCommand("enableObjectResizing", false, "false");
        return document.execCommand("enableInlineTableEditing", false, "false");
      }
    };

    Simditor.prototype._tpl = "<div class=\"simditor\">\n  <div class=\"simditor-wrapper\">\n    <div class=\"simditor-body\" contenteditable=\"true\">\n    </div>\n  </div>\n</div>";

    Simditor.prototype._render = function() {
      this.el = $(this._tpl).insertBefore(this.textarea);
      this.wrapper = this.el.find('.simditor-wrapper');
      this.body = this.wrapper.find('.simditor-body');
      this.el.append(this.textarea).data('simditor', this);
      this.textarea.data('simditor', this).hide().blur();
      return this.body.attr('tabindex', this.textarea.attr('tabindex'));
    };

    Simditor.prototype.setValue = function(val) {
      this.textarea.val(val);
      this.body.html(val);
      this.format();
      return this._decorate();
    };

    Simditor.prototype.getValue = function() {
      return this.sync();
    };

    Simditor.prototype.sync = function() {
      var val;
      val = this._undecorate();
      this.textarea.val(val);
      return val;
    };

    Simditor.prototype.destroy = function() {
      this.trigger('destroy');
      this.textarea.closest('form'.off('.simditor simditor-' + this.id));
      this.sel.removeAllRanges();
      this.textarea.insertBefore(this.el).hide().val(''.removeData('simditor'));
      return this.el.remove();
    };

    return Simditor;

  })(Widget);

  window.simditor = function(opts) {
    return new Simditor(opts);
  };

}).call(this);
