(function() {
  var BlockquoteButton, BoldButton, Button, CodeButton, CodePopover, Formatter, ImageButton, ImagePopover, InputManager, ItalicButton, LinkButton, LinkPopover, ListButton, Module, OrderListButton, Plugin, Popover, Selection, Simditor, Toolbar, UnderlineButton, UndoManager, UnorderListButton, Util, Widget, _ref, _ref1, _ref10, _ref11, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Module = (function() {
    function Module() {}

    Module.extend = function(obj) {
      var key, val, _ref;
      if (!((obj != null) && typeof obj === 'object')) {
        return;
      }
      for (key in obj) {
        val = obj[key];
        if (key !== 'included' && key !== 'extended') {
          this[key] = val;
        }
      }
      return (_ref = obj.extended) != null ? _ref.call(this) : void 0;
    };

    Module.include = function(obj) {
      var key, val, _ref;
      if (!((obj != null) && typeof obj === 'object')) {
        return;
      }
      for (key in obj) {
        val = obj[key];
        if (key !== 'included' && key !== 'extended') {
          this.prototype[key] = val;
        }
      }
      return (_ref = obj.included) != null ? _ref.call(this) : void 0;
    };

    Module.prototype.on = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = $(this)).on.apply(_ref, args);
    };

    Module.prototype.one = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = $(this)).one.apply(_ref, args);
    };

    Module.prototype.off = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = $(this)).off.apply(_ref, args);
    };

    Module.prototype.trigger = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = $(this)).trigger.apply(_ref, args);
    };

    Module.prototype.triggerHandler = function() {
      var args, _ref;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return (_ref = $(this)).triggerHandler.apply(_ref, args);
    };

    return Module;

  })();

  Widget = (function(_super) {
    __extends(Widget, _super);

    Widget.connect = function(cls) {
      if (typeof cls !== 'function') {
        return;
      }
      this.prototype._connectedClasses.push(cls);
      if (cls.name) {
        return this[cls.name] = cls;
      }
    };

    Widget.prototype._connectedClasses = [];

    Widget.prototype._init = function() {};

    Widget.prototype.opts = {};

    function Widget(opts) {
      var cls, instance, instances, name, _i, _len;
      $.extend(this.opts, opts);
      instances = (function() {
        var _i, _len, _ref, _results;
        _ref = this._connectedClasses;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          cls = _ref[_i];
          name = cls.name.charAt(0).toLowerCase() + cls.name.slice(1);
          _results.push(this[name] = new cls(this));
        }
        return _results;
      }).call(this);
      this._init();
      for (_i = 0, _len = instances.length; _i < _len; _i++) {
        instance = instances[_i];
        if (typeof instance._init === "function") {
          instance._init();
        }
      }
    }

    Widget.prototype.destroy = function() {};

    return Widget;

  })(Module);

  Plugin = (function(_super) {
    __extends(Plugin, _super);

    Plugin.prototype.opts = {};

    function Plugin(widget) {
      this.widget = widget;
      $.extend(this.opts, this.widget.opts);
    }

    Plugin.prototype._init = function() {};

    return Plugin;

  })(Module);

  if (Function.prototype.name === void 0 && Object.defineProperty !== void 0) {
    Object.defineProperty(Function.prototype, 'name', {
      get: function() {
        var funcNameRegex, results;
        funcNameRegex = /function\s([^(]{1,})\(/;
        results = funcNameRegex.exec(this.toString());
        if (results && results.length > 1) {
          return results[1].trim();
        } else {
          return "";
        }
      },
      set: function(value) {}
    });
  }

  Selection = (function(_super) {
    __extends(Selection, _super);

    function Selection() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      Selection.__super__.constructor.apply(this, args);
      this.sel = document.getSelection();
      this.editor = this.widget;
    }

    Selection.prototype._init = function() {};

    Selection.prototype.clear = function() {
      return this.sel.removeAllRanges();
    };

    Selection.prototype.getRange = function() {
      if (!this.editor.inputManager.focused || !this.sel.rangeCount) {
        return null;
      }
      return this.sel.getRangeAt(0);
    };

    Selection.prototype.selectRange = function(range) {
      this.sel.removeAllRanges();
      return this.sel.addRange(range);
    };

    Selection.prototype.rangeAtEndOf = function(node, range) {
      var endNode, endNodeLength, result,
        _this = this;
      if (range == null) {
        range = this.getRange();
      }
      if (!((range != null) && range.collapsed)) {
        return;
      }
      node = $(node)[0];
      endNode = range.endContainer;
      endNodeLength = this.editor.util.getNodeLength(endNode);
      if (!(range.endOffset === endNodeLength - 1 && $(endNode).contents().last().is('br')) && range.endOffset !== endNodeLength) {
        return false;
      }
      if (node === endNode) {
        return true;
      } else if (!$.contains(node, endNode)) {
        return false;
      }
      result = true;
      $(endNode).parentsUntil(node).addBack().each(function(i, n) {
        var $lastChild, nodes;
        nodes = $(n).parent().contents().filter(function() {
          return !(this.nodeType === 3 && !this.nodeValue);
        });
        $lastChild = nodes.last();
        if (!($lastChild.get(0) === n || ($lastChild.is('br') && $lastChild.prev().get(0) === n))) {
          result = false;
          return false;
        }
      });
      return result;
    };

    Selection.prototype.rangeAtStartOf = function(node, range) {
      var result, startNode,
        _this = this;
      if (range == null) {
        range = this.getRange();
      }
      if (!((range != null) && range.collapsed)) {
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
    };

    Selection.prototype.insertNode = function(node, range) {
      if (range == null) {
        range = this.getRange();
      }
      if (range == null) {
        return;
      }
      node = $(node)[0];
      range.insertNode(node);
      return this.setRangeAfter(node);
    };

    Selection.prototype.setRangeAfter = function(node, range) {
      if (range == null) {
        range = this.getRange();
      }
      if (range == null) {
        return;
      }
      node = $(node)[0];
      range.setEndAfter(node);
      range.collapse(false);
      return this.selectRange(range);
    };

    Selection.prototype.setRangeBefore = function(node, range) {
      if (range == null) {
        range = this.getRange();
      }
      if (range == null) {
        return;
      }
      node = $(node)[0];
      range.setEndBefore(node);
      range.collapse(false);
      return this.selectRange(range);
    };

    Selection.prototype.setRangeAtStartOf = function(node, range) {
      if (range == null) {
        range = this.getRange();
      }
      node = $(node).get(0);
      range.setEnd(node, 0);
      range.collapse(false);
      return this.selectRange(range);
    };

    Selection.prototype.setRangeAtEndOf = function(node, range) {
      var $node, contents, lastChild, lastText, nodeLength;
      if (range == null) {
        range = this.getRange();
      }
      $node = $(node);
      node = $node.get(0);
      if ($node.is('pre')) {
        contents = $node.contents();
        if (contents.length > 0) {
          lastChild = contents.last();
          lastText = lastChild.text();
          if (lastText.charAt(lastText.length - 1) === '\n') {
            range.setEnd(lastChild[0], this.editor.util.getNodeLength(lastChild[0]) - 1);
          } else {
            range.setEnd(lastChild[0], this.editor.util.getNodeLength(lastChild[0]));
          }
        } else {
          range.setEnd(node, 0);
        }
      } else {
        nodeLength = this.editor.util.getNodeLength(node);
        if (node.nodeType !== 3 && nodeLength > 0 && $(node).contents().last().is('br')) {
          nodeLength -= 1;
        }
        range.setEnd(node, nodeLength);
      }
      range.collapse(false);
      return this.selectRange(range);
    };

    Selection.prototype.deleteRangeContents = function(range) {
      if (range == null) {
        range = this.getRange();
      }
      return range.deleteContents();
    };

    Selection.prototype.breakBlockEl = function(el, range) {
      var $el;
      if (range == null) {
        range = this.getRange();
      }
      $el = $(el);
      if (!range.collapsed) {
        return $el;
      }
      range.setStartBefore($el.get(0));
      if (range.collapsed) {
        return $el;
      }
      return $el.before(range.extractContents());
    };

    Selection.prototype.save = function() {
      var endCaret, range, startCaret;
      if (this._selectionSaved) {
        return;
      }
      range = this.getRange();
      startCaret = $('<span/>').addClass('simditor-caret-start');
      endCaret = $('<span/>').addClass('simditor-caret-end');
      range.insertNode(startCaret[0]);
      range.collapse(false);
      range.insertNode(endCaret[0]);
      this.sel.removeAllRanges();
      return this._selectionSaved = true;
    };

    Selection.prototype.restore = function() {
      var endCaret, endContainer, endOffset, range, startCaret, startContainer, startOffset;
      if (!this._selectionSaved) {
        return false;
      }
      startCaret = this.editor.body.find('.simditor-caret-start');
      endCaret = this.editor.body.find('.simditor-caret-end');
      if (startCaret.length && endCaret.length) {
        startContainer = startCaret.parent();
        startOffset = startContainer.contents().index(startCaret);
        endContainer = endCaret.parent();
        endOffset = endContainer.contents().index(endCaret);
        if (startContainer[0] === endContainer[0]) {
          endOffset -= 1;
        }
        range = document.createRange();
        range.setStart(startContainer.get(0), startOffset);
        range.setEnd(endContainer.get(0), endOffset);
        startCaret.remove();
        endCaret.remove();
        this.selectRange(range);
      } else {
        startCaret.remove();
        endCaret.remove();
      }
      this._selectionSaved = false;
      return range;
    };

    return Selection;

  })(Plugin);

  Formatter = (function(_super) {
    __extends(Formatter, _super);

    function Formatter() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      Formatter.__super__.constructor.apply(this, args);
      this.editor = this.widget;
    }

    Formatter.prototype._init = function() {
      var _this = this;
      return this.editor.body.on('click', 'a', function(e) {
        return false;
      });
    };

    Formatter.prototype._allowedTags = ['a', 'img', 'b', 'strong', 'i', 'u', 'p', 'ul', 'ol', 'li', 'blockquote', 'hr', 'pre', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'table'];

    Formatter.prototype._allowedAttributes = {
      img: ['src', 'alt', 'width', 'height'],
      a: ['href', 'target']
    };

    Formatter.prototype.decorate = function($el) {
      if ($el == null) {
        $el = this.editor.body;
      }
      return this.editor.trigger('decorate', [$el]);
    };

    Formatter.prototype.undecorate = function($el) {
      if ($el == null) {
        $el = this.editor.body.clone();
      }
      this.editor.trigger('undecorate', [$el]);
      return $.trim($el.html());
    };

    Formatter.prototype.autolink = function($el) {
      var $node, findLinkNode, lastIndex, linkNodes, match, re, replaceEls, text, uri, _i, _len;
      if ($el == null) {
        $el = this.editor.body;
      }
      linkNodes = [];
      findLinkNode = function($parentNode) {
        return $parentNode.contents().each(function(i, node) {
          var $node, text;
          $node = $(node);
          if ($node.is('a') || $node.closest('a', $el).length) {
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
      re = /(https?:\/\/|www\.)[\w\-\.\?&=\/#%]+/ig;
      for (_i = 0, _len = linkNodes.length; _i < _len; _i++) {
        $node = linkNodes[_i];
        text = $node.text();
        replaceEls = [];
        match = null;
        lastIndex = 0;
        while ((match = re.exec(text)) !== null) {
          replaceEls.push(document.createTextNode(text.substring(lastIndex, match.index)));
          lastIndex = re.lastIndex;
          uri = /^(http(s)?:\/\/|\/)/.test(match[0]) ? match[0] : 'http://' + match[0];
          replaceEls.push($('<a href="' + uri + '" rel="nofollow">' + match[0] + '</a>')[0]);
        }
        replaceEls.push(document.createTextNode(text.substring(lastIndex)));
        $node.replaceWith($(replaceEls));
      }
      return $el;
    };

    Formatter.prototype.format = function($el) {
      var blockNode, n, node, _i, _j, _len, _len1, _ref, _ref1;
      if ($el == null) {
        $el = this.editor.body;
      }
      if ($el.is(':empty')) {
        $el.append('<p>' + this.editor.util.phBr + '</p>');
        return $el;
      }
      _ref = $el.contents();
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        this.cleanNode(n, true);
      }
      _ref1 = $el.contents();
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        node = _ref1[_j];
        if (this.editor.util.isBlockNode(node) || $(node).is('img')) {
          blockNode = null;
        } else {
          if (blockNode == null) {
            blockNode = $('<p/>').insertBefore(node);
          }
          blockNode.append(node);
        }
      }
      return $el;
    };

    Formatter.prototype.cleanNode = function(node, recursive) {
      var $node, allowedAttributes, attr, contents, isDecoration, n, _i, _j, _len, _len1, _ref, _ref1;
      $node = $(node);
      if ($node[0].nodeType === 3) {
        return;
      }
      contents = $node.contents();
      isDecoration = $node.is('[class^="simditor-"]');
      if ($node.is(this._allowedTags.join(',')) || isDecoration) {
        if ($node.is('a') && $node.find('img').length > 0) {
          contents.first().unwrap();
        }
        if (!isDecoration) {
          allowedAttributes = this._allowedAttributes[$node[0].tagName.toLowerCase()];
          _ref = $.makeArray($node[0].attributes);
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            attr = _ref[_i];
            if (!((allowedAttributes != null) && (_ref1 = attr.name, __indexOf.call(allowedAttributes, _ref1) >= 0))) {
              $node.removeAttr(attr.name);
            }
          }
        }
      } else if ($node[0].nodeType === 1 && !$node.is(':empty')) {
        contents.first().unwrap();
      } else {
        $node.remove();
        contents = null;
      }
      if (recursive && (contents != null)) {
        for (_j = 0, _len1 = contents.length; _j < _len1; _j++) {
          n = contents[_j];
          this.cleanNode(n, true);
        }
      }
      return null;
    };

    Formatter.prototype.clearHtml = function(html, lineBreak) {
      var container, result,
        _this = this;
      if (lineBreak == null) {
        lineBreak = true;
      }
      container = $('<div/>').append(html);
      result = '';
      container.contents().each(function(i, node) {
        var $node, contents;
        if (node.nodeType === 3) {
          return result += node.nodeValue;
        } else if (node.nodeType === 1) {
          $node = $(node);
          contents = $node.contents();
          if (contents.length > 0) {
            result += _this.clearHtml(contents);
          }
          if (lineBreak && $node.is('p, div, li, tr, pre, address, artticle, aside, dd, figcaption, footer, h1, h2, h3, h4, h5, h6, header')) {
            return result += '\n';
          }
        }
      });
      return result;
    };

    return Formatter;

  })(Plugin);

  InputManager = (function(_super) {
    __extends(InputManager, _super);

    InputManager.prototype.opts = {
      tabIndent: true
    };

    function InputManager() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      InputManager.__super__.constructor.apply(this, args);
      this.editor = this.widget;
    }

    InputManager.prototype._modifierKeys = [16, 17, 18, 91, 93];

    InputManager.prototype._arrowKeys = [37, 38, 39, 40];

    InputManager.prototype._init = function() {
      var _this = this;
      this._pasteArea = $('<div/>').css({
        width: '1px',
        height: '1px',
        overflow: 'hidden',
        position: 'fixed',
        right: '0',
        bottom: '100px'
      }).attr({
        tabIndex: '-1',
        contentEditable: true
      }).addClass('simditor-paste-area').appendTo(this.editor.el);
      this.editor.on('valuechanged', function() {
        return _this.editor.body.find('pre, .simditor-image').each(function(i, el) {
          var $el;
          $el = $(el);
          if (($el.parent().is('blockquote') || $el.parent()[0] === _this.editor.body[0]) && $el.next().length === 0) {
            return $('<p/>').append(_this.editor.util.phBr).insertAfter($el);
          }
        });
      });
      this.editor.body.on('keydown', $.proxy(this._onKeyDown, this)).on('keyup', $.proxy(this._onKeyUp, this)).on('mouseup', $.proxy(this._onMouseUp, this)).on('focus', $.proxy(this._onFocus, this)).on('blur', $.proxy(this._onBlur, this)).on('paste', $.proxy(this._onPaste, this));
      if (this.editor.textarea.attr('autofocus')) {
        return setTimeout(function() {
          return _this.editor.body.focus();
        }, 0);
      }
    };

    InputManager.prototype._onFocus = function(e) {
      var _this = this;
      this.editor.el.addClass('focus').removeClass('error');
      this.focused = true;
      this.editor.body.find('.selected').removeClass('selected');
      return setTimeout(function() {
        _this.editor.trigger('focus');
        return _this.editor.trigger('selectionchanged');
      }, 0);
    };

    InputManager.prototype._onBlur = function(e) {
      this.editor.el.removeClass('focus');
      this.focused = false;
      return this.editor.trigger('blur');
    };

    InputManager.prototype._onMouseUp = function(e) {
      if ($(e.target).is('img, .simditor-image')) {
        return;
      }
      return this.editor.trigger('selectionchanged');
    };

    InputManager.prototype._onKeyDown = function(e) {
      var $blockEl, $br, $prevBlockEl, metaKey, result, shortcutName, spaceNode, spaces, _ref, _ref1,
        _this = this;
      if (this.editor.triggerHandler(e) === false) {
        return false;
      }
      if ((_ref = e.which, __indexOf.call(this._modifierKeys, _ref) >= 0) || (_ref1 = e.which, __indexOf.call(this._arrowKeys, _ref1) >= 0)) {
        return;
      }
      metaKey = this.editor.util.metaKey(e);
      $blockEl = this.editor.util.closestBlockEl();
      if (metaKey && e.which === 86) {
        return;
      }
      shortcutName = [];
      if (e.shiftKey) {
        shortcutName.push('shift');
      }
      if (e.ctrlKey) {
        shortcutName.push('ctrl');
      }
      if (e.altKey) {
        shortcutName.push('alt');
      }
      if (e.metaKey) {
        shortcutName.push('cmd');
      }
      shortcutName.push(e.which);
      shortcutName = shortcutName.join('+');
      if (this._shortcuts[shortcutName]) {
        this._shortcuts[shortcutName].call(this, e);
        return false;
      }
      if (e.which in this._inputHandlers) {
        result = null;
        this.editor.util.traverseUp(function(node) {
          var handler, _ref2;
          if (node.nodeType !== 1) {
            return;
          }
          handler = (_ref2 = _this._inputHandlers[e.which]) != null ? _ref2[node.tagName.toLowerCase()] : void 0;
          result = handler != null ? handler.call(_this, e, $(node)) : void 0;
          return !result;
        });
        if (result) {
          this.editor.trigger('valuechanged');
          this.editor.trigger('selectionchanged');
          return false;
        }
      }
      if (this.editor.util.browser.safari && e.which === 13 && e.shiftKey) {
        $br = $('<br/>');
        if (this.editor.selection.rangeAtEndOf($blockEl)) {
          this.editor.selection.insertNode($br);
          this.editor.selection.insertNode($('<br/>'));
          this.editor.selection.setRangeBefore($br);
        } else {
          this.editor.selection.insertNode($br);
        }
        this.editor.trigger('valuechanged');
        this.editor.trigger('selectionchanged');
        return false;
      }
      if (e.which === 8) {
        $prevBlockEl = $blockEl.prev();
        if ($prevBlockEl.is('hr' && this.editor.selection.rangeAtStartOf($blockEl))) {
          $prevBlockEl.remove();
          this.editor.trigger('valuechanged');
          this.editor.trigger('selectionchanged');
          return false;
        }
      }
      if (e.which === 9 && (this.opts.tabIndent || $blockEl.is('pre')) && !$blockEl.is('li')) {
        spaces = $blockEl.is('pre') ? '\u00A0\u00A0' : '\u00A0\u00A0\u00A0\u00A0';
        spaceNode = document.createTextNode(spaces);
        this.editor.selection.insertNode(spaceNode);
        this.editor.trigger('valuechanged');
        this.editor.trigger('selectionchanged');
        return false;
      }
      if (this._typing) {
        clearTimeout(this._typing);
      }
      return this._typing = setTimeout(function() {
        _this.editor.trigger('valuechanged');
        _this.editor.trigger('selectionchanged');
        return _this._typing = false;
      });
    };

    InputManager.prototype._onKeyUp = function(e) {
      var p, _ref;
      if (this.editor.triggerHandler(e) === false) {
        return false;
      }
      if (_ref = e.which, __indexOf.call(this._arrowKeys, _ref) >= 0) {
        this.editor.trigger('selectionchanged');
        return;
      }
      if (e.which === 8 && this.editor.body.is(':empty')) {
        p = $('<p/>').append(this.editor.util.phBr).appendTo(this.editor.body);
        this.editor.selection.setRangeAtStartOf(p);
      }
    };

    InputManager.prototype._onPaste = function(e) {
      var $blockEl, codePaste,
        _this = this;
      if (this.editor.triggerHandler(e) === false) {
        return false;
      }
      $blockEl = this.editor.util.closestBlockEl();
      codePaste = $blockEl.is('pre');
      this.editor.selection.deleteRangeContents();
      this.editor.selection.save();
      this._pasteArea.focus();
      return setTimeout(function() {
        var children, insertPosition, node, pasteContent, range, _i, _len;
        if (_this._pasteArea.is(':empty')) {
          pasteContent = null;
        } else if (codePaste) {
          pasteContent = _this.editor.formatter.clearHtml(_this._pasteArea.html());
        } else {
          pasteContent = $('<div/>').append(_this._pasteArea.contents());
          _this.editor.formatter.format(pasteContent);
          _this.editor.formatter.decorate(pasteContent);
          pasteContent = pasteContent.contents();
        }
        _this._pasteArea.empty();
        range = _this.editor.selection.restore();
        if (!pasteContent) {
          return;
        } else if (codePaste) {
          node = document.createTextNode(pasteContent);
          _this.editor.selection.insertNode(node, range);
        } else if (pasteContent.length < 1) {
          return;
        } else if (pasteContent.length === 1 && pasteContent.is('p')) {
          children = pasteContent.contents();
          for (_i = 0, _len = children.length; _i < _len; _i++) {
            node = children[_i];
            range.insertNode(node);
          }
          _this.editor.selection.setRangeAfter(children.last());
        } else {
          if ($blockEl.is('li')) {
            $blockEl = $blockEl.parent();
          }
          if (_this.editor.selection.rangeAtStartOf($blockEl, range)) {
            insertPosition = 'before';
          } else if (_this.editor.selection.rangeAtEndOf($blockEl, range)) {
            insertPosition = 'after';
          } else {
            _this.editor.selection.breakBlockEl($blockEl, range);
            insertPosition = 'before';
          }
          $blockEl[insertPosition](pasteContent);
          _this.editor.selection.setRangeAtEndOf(pasteContent.last(), range);
        }
        _this.editor.trigger('valuechanged');
        return _this.editor.trigger('selectionchanged');
      }, 10);
    };

    InputManager.prototype._inputHandlers = {
      13: {
        li: function(e, $node) {
          var listEl, newBlockEl, newLi, range;
          if (!this.editor.util.isEmptyNode($node)) {
            return;
          }
          e.preventDefault();
          range = this.editor.selection.getRange();
          if (!$node.next('li').length) {
            listEl = $node.parent();
            newBlockEl = $('<p/>').append(this.editor.util.phBr).insertAfter(listEl);
            if ($node.siblings('li').length) {
              $node.remove();
            } else {
              listEl.remove();
            }
            range.setEnd(newBlockEl[0], 0);
          } else {
            newLi = $('<li/>').append(this.editor.util.phBr).insertAfter($node);
            range.setEnd(newLi[0], 0);
          }
          range.collapse(false);
          this.editor.selection.selectRange(range);
          return true;
        },
        pre: function(e, $node) {
          var breakNode, range;
          e.preventDefault();
          range = this.editor.selection.getRange();
          breakNode = null;
          range.deleteContents();
          if (!this.editor.util.browser.msie && this.editor.selection.rangeAtEndOf($node)) {
            breakNode = document.createTextNode('\n\n');
            range.insertNode(breakNode);
            range.setEnd(breakNode, 1);
          } else {
            breakNode = document.createTextNode('\n');
            range.insertNode(breakNode);
            range.setStartAfter(breakNode);
          }
          range.collapse(false);
          this.editor.selection.selectRange(range);
          return true;
        },
        blockquote: function(e, $node) {
          var $closestBlock;
          $closestBlock = this.editor.util.closestBlockEl();
          if (!($closestBlock.is('p') && !$closestBlock.next().length && this.editor.util.isEmptyNode($closestBlock))) {
            return;
          }
          $node.after($closestBlock);
          this.editor.selection.setRangeAtStartOf($closestBlock);
          return true;
        }
      },
      8: {
        pre: function(e, $node) {
          var $newNode, codeStr;
          if (!this.editor.selection.rangeAtStartOf($node)) {
            return;
          }
          codeStr = $node.html().replace('\n', '<br/>');
          $newNode = $('<p/>').append(codeStr || this.editor.util.phBr).insertAfter($node);
          $node.remove();
          this.editor.selection.setRangeAtStartOf($newNode);
          return true;
        },
        blockquote: function(e, $node) {
          var $firstChild;
          if (!this.editor.selection.rangeAtStartOf($node)) {
            return;
          }
          $firstChild = $node.children().first().unwrap();
          this.editor.selection.setRangeAtStartOf($firstChild);
          return true;
        }
      },
      9: {
        li: function(e, $node) {
          var $childList, $parent, $parentLi, tagName;
          if (e.shiftKey) {
            $parent = $node.parent();
            $parentLi = $parent.parent('li');
            if ($parentLi.length < 0) {
              return true;
            }
            this.editor.selection.save();
            if ($node.next('li').length > 0) {
              $('<' + $parent[0].tagName + '/>').append($node.nextAll('li')).appendTo($node);
            }
            $node.insertAfter($parentLi);
            if ($parent.children('li').length < 1) {
              $parent.remove();
            }
            this.editor.selection.restore();
          } else {
            $parentLi = $node.prev('li');
            if ($parentLi.length < 1) {
              return true;
            }
            this.editor.selection.save();
            tagName = $node.parent()[0].tagName;
            $childList = $parentLi.children('ul, ol');
            if ($childList.length > 0) {
              $childList.append($node);
            } else {
              $('<' + tagName + '/>').append($node).appendTo($parentLi);
            }
            this.editor.selection.restore();
          }
          return true;
        }
      }
    };

    InputManager.prototype._shortcuts = {
      'cmd+13': function(e) {
        return this.editor.el.closest('form').find('button:submit').click();
      }
    };

    InputManager.prototype.addShortcut = function(keys, handler) {
      return this._shortcuts[keys] = $.proxy(handler, this);
    };

    return InputManager;

  })(Plugin);

  UndoManager = (function(_super) {
    __extends(UndoManager, _super);

    UndoManager.prototype._stack = [];

    UndoManager.prototype._index = -1;

    UndoManager.prototype._capacity = 50;

    UndoManager.prototype._timer = null;

    function UndoManager() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      UndoManager.__super__.constructor.apply(this, args);
      this.editor = this.widget;
    }

    UndoManager.prototype._init = function() {
      var _this = this;
      this.editor.inputManager.addShortcut('cmd+90', function(e) {
        return _this.undo();
      });
      this.editor.inputManager.addShortcut('shift+cmd+90', function(e) {
        return _this.redo();
      });
      return this.editor.on('valuechanged', function(e, src) {
        if (src === 'undo') {
          return;
        }
        if (_this._timer) {
          clearTimeout(_this._timer);
          _this._timer = null;
        }
        return _this._timer = setTimeout(function() {
          return _this._pushUndoState();
        }, 300);
      });
    };

    UndoManager.prototype._pushUndoState = function() {
      var currentState, html;
      if (this._stack.length && this._index > -1) {
        currentState = this._stack[this._index];
      }
      html = this.editor.body.html();
      if (currentState && currentState.html === html) {
        return;
      }
      this._index += 1;
      this._stack.length = this._index;
      this._stack.push({
        html: html,
        caret: this.caretPosition()
      });
      if (this._stack.length > this._capacity) {
        this._stack.shift();
        return this._index -= 1;
      }
    };

    UndoManager.prototype.undo = function() {
      var state;
      if (this._index < 1 || this._stack.length < 2) {
        return;
      }
      this._index -= 1;
      state = this._stack[this._index];
      this.editor.body.html(state.html);
      this.caretPosition(state.caret);
      this.editor.sync();
      this.editor.trigger('valuechanged', ['undo']);
      return this.editor.trigger('selectionchanged', ['undo']);
    };

    UndoManager.prototype.redo = function() {
      var state;
      if (this._index < 0 || this._stack.length < this._index + 2) {
        return;
      }
      this._index += 1;
      state = this._stack[this._index];
      this.editor.body.html(state.html);
      this.caretPosition(state.caret);
      this.editor.sync();
      this.editor.trigger('valuechanged', ['undo']);
      return this.editor.trigger('selectionchanged', ['undo']);
    };

    UndoManager.prototype._getNodeOffset = function(node, index) {
      var $parent, merging, offset,
        _this = this;
      if (index) {
        $parent = $(node);
      } else {
        $parent = $(node).parent();
      }
      offset = 0;
      merging = false;
      $parent.contents().each(function(i, child) {
        if (index === i || node === child) {
          return false;
        }
        if (child.nodeType === 3) {
          if (!merging) {
            offset += 1;
            merging = true;
          }
        } else {
          offset += 1;
          merging = false;
        }
        return null;
      });
      return offset;
    };

    UndoManager.prototype._getNodePosition = function(node, offset) {
      var position, prevNode,
        _this = this;
      if (node.nodeType === 3) {
        prevNode = node.previousSibling;
        while (prevNode && prevNode.nodeType === 3) {
          node = prevNode;
          offset += this.editor.util.getNodeLength(prevNode);
          prevNode = prevNode.previousSibling;
        }
      } else {
        offset = this._getNodeOffset(node, offset);
      }
      position = [];
      position.unshift(offset);
      this.editor.util.traverseUp(function(n) {
        return position.unshift(_this._getNodeOffset(n));
      }, node);
      return position;
    };

    UndoManager.prototype._getNodeByPosition = function(position) {
      var childNodes, node, offset, _i, _len, _ref;
      node = this.editor.body[0];
      _ref = position.slice(0, position.length - 1);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        offset = _ref[_i];
        childNodes = node.childNodes;
        if (offset > childNodes.length - 1) {
          node = null;
          break;
        }
        node = childNodes[offset];
      }
      return node;
    };

    UndoManager.prototype.caretPosition = function(caret) {
      var endContainer, endOffset, range, startContainer, startOffset;
      if (!caret) {
        if (!this.editor.inputManager.focused) {
          return {};
        }
        range = this.editor.selection.getRange();
        caret = {
          start: [],
          end: null,
          collapsed: true
        };
        caret.start = this._getNodePosition(range.startContainer, range.startOffset);
        if (!range.collapsed) {
          caret.end = this._getNodePosition(range.endContainer, range.endOffset);
          caret.collapsed = false;
        }
        return caret;
      } else {
        if (!this.editor.inputManager.focused) {
          this.editor.body.focus();
        }
        if (!caret.start) {
          this.editor.body.blur();
          return;
        }
        startContainer = this._getNodeByPosition(caret.start);
        startOffset = caret.start[caret.start.length - 1];
        if (caret.collapsed) {
          endContainer = startContainer;
          endOffset = startOffset;
        } else {
          endContainer = this._getNodeByPosition(caret.end);
          endOffset = caret.start[caret.start.length - 1];
        }
        if (!startContainer || !endContainer) {
          throw new Error('simditor: invalid caret state');
          return;
        }
        range = document.createRange();
        range.setStart(startContainer, startOffset);
        range.setEnd(endContainer, endOffset);
        return this.editor.selection.selectRange(range);
      }
    };

    return UndoManager;

  })(Plugin);

  Util = (function(_super) {
    __extends(Util, _super);

    function Util() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      Util.__super__.constructor.apply(this, args);
      if (this.browser.msie) {
        this.phBr = '';
      }
      this.editor = this.widget;
    }

    Util.prototype._init = function() {};

    Util.prototype.phBr = '<br/>';

    Util.prototype.os = (function() {
      if (/Mac/.test(navigator.appVersion)) {
        return {
          mac: true
        };
      } else if (/Linux/.test(navigator.appVersion)) {
        return {
          linux: true
        };
      } else if (/Win/.test(navigator.appVersion)) {
        return {
          win: true
        };
      } else if (/X11/.test(navigator.appVersion)) {
        return {
          unix: true
        };
      } else {
        return {};
      }
    })();

    Util.prototype.browser = (function() {
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
    })();

    Util.prototype.metaKey = function(e) {
      var isMac;
      isMac = /Mac/.test(navigator.userAgent);
      if (isMac) {
        return e.metaKey;
      } else {
        return e.ctrlKey;
      }
    };

    Util.prototype.isEmptyNode = function(node) {
      var $node;
      $node = $(node);
      return !$node.text() && !$node.find(':not(br)').length;
    };

    Util.prototype.isBlockNode = function(node) {
      node = $(node)[0];
      if (!node || node.nodeType === 3) {
        return false;
      }
      return /^(div|p|ul|ol|li|blockquote|hr|pre|h1|h2|h3|h4|h5|h6|table)$/.test(node.nodeName.toLowerCase());
    };

    Util.prototype.closestBlockEl = function(node) {
      var $node, blockEl, range,
        _this = this;
      if (node == null) {
        range = this.editor.selection.getRange();
        node = range != null ? range.commonAncestorContainer : void 0;
      }
      $node = $(node);
      if (!$node.length) {
        return null;
      }
      blockEl = $node.parentsUntil(this.editor.body).addBack();
      blockEl = blockEl.filter(function(i) {
        return _this.isBlockNode(blockEl.eq(i));
      });
      if (blockEl.length) {
        return blockEl.last();
      } else {
        return null;
      }
    };

    Util.prototype.furthestBlockEl = function(node) {
      var $node, blockEl, range,
        _this = this;
      if (node == null) {
        range = this.editor.selection.getRange();
        node = range != null ? range.commonAncestorContainer : void 0;
      }
      $node = $(node);
      if (!$node.length) {
        return null;
      }
      blockEl = $node.parentsUntil(this.editor.body).addBack();
      blockEl = blockEl.filter(function(i) {
        return _this.isBlockNode(blockEl.eq(i));
      });
      if (blockEl.length) {
        return blockEl.first();
      } else {
        return null;
      }
    };

    Util.prototype.getNodeLength = function(node) {
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
    };

    Util.prototype.traverseUp = function(callback, node) {
      var n, nodes, range, result, _i, _len, _results;
      if (node == null) {
        range = this.editor.selection.getRange();
        node = range != null ? range.commonAncestorContainer : void 0;
      }
      if ((node == null) || !$.contains(this.editor.body[0], node)) {
        return false;
      }
      nodes = $(node).parentsUntil(this.editor.body).get();
      nodes.unshift(node);
      _results = [];
      for (_i = 0, _len = nodes.length; _i < _len; _i++) {
        n = nodes[_i];
        result = callback(n);
        if (result === false) {
          break;
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return Util;

  })(Plugin);

  Toolbar = (function(_super) {
    __extends(Toolbar, _super);

    Toolbar.prototype.opts = {
      toolbar: true,
      toolbarFloat: true
    };

    Toolbar.prototype._tpl = {
      wrapper: '<div class="simditor-toolbar"><ul></ul></div>',
      separator: '<li><span class="separator"></span></li>'
    };

    function Toolbar() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      Toolbar.__super__.constructor.apply(this, args);
      this.editor = this.widget;
    }

    Toolbar.prototype._init = function() {
      var _this = this;
      if (!this.opts.toolbar) {
        return;
      }
      if (!$.isArray(this.opts.toolbar)) {
        this.opts.toolbar = ['bold', 'italic', 'underline', '|', 'ol', 'ul', 'blockquote', 'code', '|', 'link', 'image'];
      }
      this._render();
      this.list.on('click', function(e) {
        return false;
      });
      this.wrapper.on('mousedown', function(e) {
        return _this.list.find('.menu-on').removeClass('.menu-on');
      });
      $(document).on('mousedown.simditor', function(e) {
        return _this.list.find('.menu-on').removeClass('.menu-on');
      });
      if (this.opts.toolbarFloat) {
        $(window).on('scroll.simditor-' + this.editor.id, function(e) {
          var bottomEdge, scrollTop, top, topEdge;
          topEdge = _this.editor.wrapper.offset().top;
          bottomEdge = topEdge + _this.editor.wrapper.outerHeight() - 100;
          scrollTop = $(document).scrollTop();
          top = 0;
          if (scrollTop <= topEdge) {
            top = 0;
            _this.wrapper.removeClass('floating');
          } else if ((bottomEdge > scrollTop && scrollTop > topEdge)) {
            top = scrollTop - topEdge;
            _this.wrapper.addClass('floating');
          } else {
            top = bottomEdge - topEdge;
            _this.wrapper.addClass('floating');
          }
          return _this.wrapper.css('top', top);
        });
      }
      this.editor.on('selectionchanged', function() {
        return _this.toolbarStatus();
      });
      return this.editor.on('simditordestroy', function() {
        return _this._buttons.length = 0;
      });
    };

    Toolbar.prototype._render = function() {
      var name, _i, _len, _ref, _results;
      this.wrapper = $(this._tpl.wrapper).prependTo(this.editor.wrapper);
      this.list = this.wrapper.find('ul');
      this.editor.wrapper.addClass('toolbar-enabled');
      _ref = this.opts.toolbar;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        if (name === '|') {
          $(this._tpl.separator).appendTo(this.list);
          continue;
        }
        if (!this.constructor.buttons[name]) {
          throw new Error('simditor: invalid toolbar button "' + name + '"');
          continue;
        }
        _results.push(this._buttons.push(new this.constructor.buttons[name](this.editor)));
      }
      return _results;
    };

    Toolbar.prototype.toolbarStatus = function(name) {
      var buttons,
        _this = this;
      if (!this.editor.inputManager.focused) {
        return;
      }
      buttons = this._buttons.slice(0);
      return this.editor.util.traverseUp(function(node) {
        var button, i, removeButtons, _i, _j, _len, _len1;
        removeButtons = [];
        for (i = _i = 0, _len = buttons.length; _i < _len; i = ++_i) {
          button = buttons[i];
          if ((name != null) && button.name !== name) {
            continue;
          }
          if (!button.status || button.status($(node)) === true) {
            removeButtons.push(button);
          }
        }
        for (_j = 0, _len1 = removeButtons.length; _j < _len1; _j++) {
          button = removeButtons[_j];
          i = $.inArray(button, buttons);
          buttons.splice(i, 1);
        }
        if (buttons.length === 0) {
          return false;
        }
      });
    };

    Toolbar.prototype._buttons = [];

    Toolbar.addButton = function(btn) {
      return this.buttons[btn.prototype.name] = btn;
    };

    Toolbar.buttons = {};

    return Toolbar;

  })(Plugin);

  Simditor = (function(_super) {
    __extends(Simditor, _super);

    function Simditor() {
      _ref = Simditor.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Simditor.connect(Util);

    Simditor.connect(UndoManager);

    Simditor.connect(InputManager);

    Simditor.connect(Formatter);

    Simditor.connect(Selection);

    Simditor.connect(Toolbar);

    Simditor.count = 0;

    Simditor.prototype.opts = {
      textarea: null,
      placeholder: 'Type here...',
      defaultImage: 'images/image.png'
    };

    Simditor.prototype._init = function() {
      var editor, form, _ref1,
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
      this.setValue((_ref1 = this.textarea.val()) != null ? _ref1 : '');
      this.on('valuechanged', function() {
        return _this._placeholder();
      });
      return setTimeout(function() {
        return _this.trigger('valuechanged');
      }, 0);
    };

    Simditor.prototype._tpl = "<div class=\"simditor\">\n  <div class=\"simditor-wrapper\">\n    <div class=\"simditor-placeholder\"></div>\n    <div class=\"simditor-body\" contenteditable=\"true\">\n    </div>\n  </div>\n</div>";

    Simditor.prototype._render = function() {
      this.el = $(this._tpl).insertBefore(this.textarea);
      this.wrapper = this.el.find('.simditor-wrapper');
      this.body = this.wrapper.find('.simditor-body');
      this.placeholderEl = this.wrapper.find('.simditor-placeholder').append(this.opts.placeholder);
      this.el.append(this.textarea).data('simditor', this);
      this.textarea.data('simditor', this).hide().blur();
      this.body.attr('tabindex', this.textarea.attr('tabindex'));
      if (this.util.os.mac) {
        return this.el.addClass('simditor-mac');
      } else if (this.util.os.linux) {
        return this.el.addClass('simditor-linux');
      }
    };

    Simditor.prototype._placeholder = function() {
      var children;
      children = this.body.children();
      if (children.length === 0 || (children.length === 1 && this.util.isEmptyNode(children))) {
        return this.placeholderEl.show();
      } else {
        return this.placeholderEl.hide();
      }
    };

    Simditor.prototype.setValue = function(val) {
      this.textarea.val(val);
      this.body.html(val);
      this.formatter.format();
      return this.formatter.decorate();
    };

    Simditor.prototype.getValue = function() {
      return this.sync();
    };

    Simditor.prototype.sync = function() {
      var cloneBody, emptyP, lastP, val;
      cloneBody = this.body.clone();
      this.formatter.autolink(cloneBody);
      lastP = cloneBody.children().last('p');
      while (lastP.is('p' && !lastP.text() && !lastP.find('img').length)) {
        emptyP = lastP;
        lastP = lastP.prev('p');
        emptyP.remove();
      }
      val = this.formatter.undecorate(cloneBody);
      this.textarea.val(val);
      return val;
    };

    Simditor.prototype.destroy = function() {
      this.trigger('simditordestroy');
      this.textarea.closest('form'.off('.simditor .simditor-' + this.id));
      this.selection.clear();
      this.textarea.insertBefore(this.el).hide().val(''.removeData('simditor'));
      this.el.remove();
      $(document).off('.simditor-' + this.id);
      $(window).off('.simditor-' + this.id);
      return this.off();
    };

    return Simditor;

  })(Widget);

  window.Simditor = Simditor;

  window.Simditor.Plugin = Plugin;

  Button = (function(_super) {
    __extends(Button, _super);

    Button.prototype._tpl = {
      item: '<li><a tabindex="-1" unselectable="on" class="toolbar-item" href="javascript:;"><span></span></a></li>',
      menuWrapper: '<div class="toolbar-menu"></div>',
      menuItem: '<li><a tabindex="-1" unselectable="on" class="menu-item" href="javascript:;"><span></span></a></li>',
      separator: '<li><span class="separator"></span></li>'
    };

    Button.prototype.name = '';

    Button.prototype.icon = '';

    Button.prototype.title = '';

    Button.prototype.text = '';

    Button.prototype.htmlTag = '';

    Button.prototype.disableTag = '';

    Button.prototype.menu = false;

    Button.prototype.active = false;

    Button.prototype.disabled = false;

    Button.prototype.needFocus = true;

    Button.prototype.shortcut = null;

    function Button(editor) {
      var _this = this;
      this.editor = editor;
      this.render();
      this.el.on('mousedown', function(e) {
        e.preventDefault();
        if (_this.el.hasClass('disabled') || (_this.needFocus && !_this.editor.inputManager.focused)) {
          return;
        }
        if (_this.menu) {
          return _this.editor.toolbar.wrapper.toggleClass('menu-on');
        } else {
          return _this.command();
        }
      });
      this.editor.toolbar.list.on('mousedown', 'a.menu-item', function(e) {
        var btn, param;
        e.preventDefault();
        btn = $(e.currentTarget);
        if (btn.hasClass('disabled')) {
          return;
        }
        _this.editor.toolbar.wrapper.removeClass('menu-on');
        param = btn.data('param');
        return _this.command(param);
      });
      this.editor.on('blur', function() {
        _this.setActive(false);
        return _this.setDisabled(false);
      });
      if (this.shortcut != null) {
        this.editor.inputManager.addShortcut(this.shortcut, function(e) {
          return _this.el.mousedown();
        });
      }
    }

    Button.prototype.render = function() {
      this.wrapper = $(this._tpl.item).appendTo(this.editor.toolbar.list);
      this.el = this.wrapper.find('a.toolbar-item');
      this.el.attr('title', this.title).addClass('toolbar-item-' + this.name).data('button', this);
      this.el.find('span').addClass(this.icon ? 'fa fa-' + this.icon : '').text(this.text);
      if (!this.menu) {
        return;
      }
      this.menuWrapper = $(this._tpl.menuWrapper).appendTo(this.wrapper);
      return this.renderMenu();
    };

    Button.prototype.renderMenu = function() {
      var $menuBtntnEl, $menuItemEl, menuItem, _i, _len, _ref1, _results;
      if (!$.isArray(this.menu)) {
        return;
      }
      this.menuEl = $('<ul/>').appendTo(this.menuWrapper);
      _ref1 = this.menu;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        menuItem = _ref1[_i];
        if (menuItem === '|') {
          $(this._tpl.separator).appendTo(this.menuEl);
          continue;
        }
        $menuItemEl = $(this._tpl.menuItem).appendTo(this.menuEl);
        _results.push($menuBtntnEl = $menuItemEl.find('a.menu-item').attr({
          'title': menuItem.title
        }).addClass('menu-item-' + menuItem.name).data('param', menuItem.param).find('span').text(menuItem.text));
      }
      return _results;
    };

    Button.prototype.setActive = function(active) {
      this.active = active;
      return this.el.toggleClass('active', this.active);
    };

    Button.prototype.setDisabled = function(disabled) {
      this.disabled = disabled;
      return this.el.toggleClass('disabled', this.disabled);
    };

    Button.prototype.status = function($node) {
      if ($node != null) {
        this.setDisabled($node.is(this.disableTag));
      }
      if (this.disabled) {
        return true;
      }
      if ($node != null) {
        this.setActive($node.is(this.htmlTag));
      }
      return this.active;
    };

    Button.prototype.command = function(param) {};

    return Button;

  })(Module);

  Popover = (function(_super) {
    __extends(Popover, _super);

    Popover.prototype.offset = {
      top: 4,
      left: 0
    };

    Popover.prototype.target = null;

    Popover.prototype.active = false;

    function Popover(editor) {
      var _this = this;
      this.editor = editor;
      this.el = $('<div class="simditor-popover"></div>').appendTo(this.editor.wrapper);
      this.render();
      this.editor.on('blur.linkpopover', function() {
        if (_this.active && (_this.target != null)) {
          return _this.target.addClass('selected');
        }
      });
    }

    Popover.prototype.render = function() {};

    Popover.prototype.show = function($target, position) {
      var _this = this;
      if (position == null) {
        position = 'bottom';
      }
      if ($target == null) {
        return;
      }
      this.target = $target;
      this.active = true;
      this.el.css({
        left: -9999
      }).show();
      return setTimeout(function() {
        _this.refresh(position);
        return _this.trigger('popovershow');
      }, 0);
    };

    Popover.prototype.hide = function() {
      this.target = null;
      this.active = false;
      this.el.hide();
      return this.trigger('popoverhide');
    };

    Popover.prototype.refresh = function(position) {
      var left, targetH, targetOffset, top, wrapperOffset;
      if (position == null) {
        position = 'bottom';
      }
      wrapperOffset = this.editor.wrapper.offset();
      targetOffset = this.target.offset();
      targetH = this.target.outerHeight();
      if (position === 'bottom') {
        top = targetOffset.top - wrapperOffset.top + targetH;
      } else if (position === 'top') {
        top = targetOffset.top - wrapperOffset.top - this.el.height();
      }
      left = Math.min(targetOffset.left - wrapperOffset.left, this.editor.wrapper.width() - this.el.outerWidth() - 10);
      return this.el.css({
        top: top + this.offset.top,
        left: left + this.offset.left
      });
    };

    Popover.prototype.destroy = function() {
      this.target = null;
      this.active = false;
      this.editor.off('.linkpopover');
      return this.el.remove();
    };

    return Popover;

  })(Module);

  BoldButton = (function(_super) {
    __extends(BoldButton, _super);

    function BoldButton() {
      _ref1 = BoldButton.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    BoldButton.prototype.name = 'bold';

    BoldButton.prototype.icon = 'bold';

    BoldButton.prototype.title = '加粗文字';

    BoldButton.prototype.htmlTag = 'b, strong';

    BoldButton.prototype.disableTag = 'pre';

    BoldButton.prototype.shortcut = 'cmd+66';

    BoldButton.prototype.status = function($node) {
      var active;
      if ($node != null) {
        this.setDisabled($node.is(this.disableTag));
      }
      if (this.disabled) {
        return true;
      }
      active = document.queryCommandState('bold') === true;
      this.setActive(active);
      return active;
    };

    BoldButton.prototype.command = function() {
      document.execCommand('bold');
      this.editor.trigger('valuechanged');
      return this.editor.trigger('selectionchanged');
    };

    return BoldButton;

  })(Button);

  Simditor.Toolbar.addButton(BoldButton);

  ItalicButton = (function(_super) {
    __extends(ItalicButton, _super);

    function ItalicButton() {
      _ref2 = ItalicButton.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    ItalicButton.prototype.name = 'italic';

    ItalicButton.prototype.icon = 'italic';

    ItalicButton.prototype.title = '斜体文字';

    ItalicButton.prototype.htmlTag = 'i';

    ItalicButton.prototype.disableTag = 'pre';

    ItalicButton.prototype.shortcut = 'cmd+73';

    ItalicButton.prototype.status = function($node) {
      var active;
      if ($node != null) {
        this.setDisabled($node.is(this.disableTag));
      }
      if (this.disabled) {
        return this.disabled;
      }
      active = document.queryCommandState('italic') === true;
      this.setActive(active);
      return active;
    };

    ItalicButton.prototype.command = function() {
      document.execCommand('italic');
      this.editor.trigger('valuechanged');
      return this.editor.trigger('selectionchanged');
    };

    return ItalicButton;

  })(Button);

  Simditor.Toolbar.addButton(ItalicButton);

  UnderlineButton = (function(_super) {
    __extends(UnderlineButton, _super);

    function UnderlineButton() {
      _ref3 = UnderlineButton.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    UnderlineButton.prototype.name = 'underline';

    UnderlineButton.prototype.icon = 'underline';

    UnderlineButton.prototype.title = '下划线文字';

    UnderlineButton.prototype.htmlTag = 'u';

    UnderlineButton.prototype.disableTag = 'pre';

    UnderlineButton.prototype.shortcut = 'cmd+85';

    UnderlineButton.prototype.status = function($node) {
      var active;
      if ($node != null) {
        this.setDisabled($node.is(this.disableTag));
      }
      if (this.disabled) {
        return this.disabled;
      }
      active = document.queryCommandState('underline') === true;
      this.setActive(active);
      return active;
    };

    UnderlineButton.prototype.command = function() {
      document.execCommand('underline');
      this.editor.trigger('valuechanged');
      return this.editor.trigger('selectionchanged');
    };

    return UnderlineButton;

  })(Button);

  Simditor.Toolbar.addButton(UnderlineButton);

  ListButton = (function(_super) {
    __extends(ListButton, _super);

    function ListButton() {
      _ref4 = ListButton.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    ListButton.prototype.type = '';

    ListButton.prototype.disableTag = 'pre';

    ListButton.prototype.status = function($node) {
      var anotherType;
      if ($node != null) {
        this.setDisabled($node.is(this.disableTag));
      }
      if (this.disabled) {
        return true;
      }
      if ($node == null) {
        return this.active;
      }
      anotherType = this.type === 'ul' ? 'ol' : 'ul';
      if ($node.is(anotherType)) {
        return true;
      } else {
        this.setActive($node.is(this.htmlTag));
        return this.active;
      }
    };

    ListButton.prototype.command = function(param) {
      var $breakedEl, $contents, $endBlock, $startBlock, endNode, node, range, results, startNode, _i, _len, _ref5,
        _this = this;
      range = this.editor.selection.getRange();
      startNode = range.startContainer;
      endNode = range.endContainer;
      $startBlock = this.editor.util.closestBlockEl(startNode);
      $endBlock = this.editor.util.closestBlockEl(endNode);
      this.editor.selection.save();
      range.setStartBefore($startBlock[0]);
      range.setEndAfter($endBlock[0]);
      if ($startBlock.is('li') && $endBlock.is('li') && $startBlock.parent()[0] === $endBlock.parent()[0]) {
        $breakedEl = $startBlock.parent();
      }
      $contents = $(range.extractContents());
      if ($breakedEl != null) {
        $contents.wrapInner('<' + $breakedEl[0].tagName + '/>');
        if (this.editor.selection.rangeAtStartOf($breakedEl, range)) {
          range.setEndBefore($breakedEl[0]);
          range.collapse(false);
          if ($breakedEl.children().length < 1) {
            $breakedEl.remove();
          }
        } else if (this.editor.selection.rangeAtEndOf($breakedEl, range)) {
          range.setEndAfter($breakedEl[0]);
          range.collapse(false);
        } else {
          $breakedEl = this.editor.selection.breakBlockEl($breakedEl, range);
          range.setEndBefore($breakedEl[0]);
          range.collapse(false);
        }
      }
      results = [];
      $contents.children().each(function(i, el) {
        var c, converted, _i, _len, _results;
        converted = _this._convertEl(el);
        _results = [];
        for (_i = 0, _len = converted.length; _i < _len; _i++) {
          c = converted[_i];
          if (results.length && results[results.length - 1].is(_this.type) && c.is(_this.type)) {
            _results.push(results[results.length - 1].append(c.children()));
          } else {
            _results.push(results.push(c));
          }
        }
        return _results;
      });
      _ref5 = results.reverse();
      for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
        node = _ref5[_i];
        range.insertNode(node[0]);
      }
      this.editor.selection.restore();
      this.editor.trigger('valuechanged');
      return this.editor.trigger('selectionchanged');
    };

    ListButton.prototype._convertEl = function(el) {
      var $el, anotherType, block, child, children, results, _i, _len, _ref5,
        _this = this;
      $el = $(el);
      results = [];
      anotherType = this.type === 'ul' ? 'ol' : 'ul';
      if ($el.is(this.type)) {
        $el.find('li').each(function(i, li) {
          var block;
          block = $('<p/>').append($(li).html() || _this.editor.util.phBr);
          return results.push(block);
        });
      } else if ($el.is(anotherType)) {
        block = $('<' + this.type + '/>').append($el.html());
        results.push(block);
      } else if ($el.is('blockquote')) {
        _ref5 = $el.children().get();
        for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
          child = _ref5[_i];
          children = this._convertEl(child);
        }
        $.merge(results, children);
      } else if ($el.is('table')) {

      } else {
        block = $('<' + this.type + '><li></li></' + this.type + '>');
        block.find('li').append($el.html() || this.editor.util.phBr);
        results.push(block);
      }
      return results;
    };

    return ListButton;

  })(Button);

  OrderListButton = (function(_super) {
    __extends(OrderListButton, _super);

    function OrderListButton() {
      _ref5 = OrderListButton.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    OrderListButton.prototype.type = 'ol';

    OrderListButton.prototype.name = 'ol';

    OrderListButton.prototype.title = '有序列表';

    OrderListButton.prototype.icon = 'list-ol';

    OrderListButton.prototype.htmlTag = 'ol';

    return OrderListButton;

  })(ListButton);

  UnorderListButton = (function(_super) {
    __extends(UnorderListButton, _super);

    function UnorderListButton() {
      _ref6 = UnorderListButton.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    UnorderListButton.prototype.type = 'ul';

    UnorderListButton.prototype.name = 'ul';

    UnorderListButton.prototype.title = '无序列表';

    UnorderListButton.prototype.icon = 'list-ul';

    UnorderListButton.prototype.htmlTag = 'ul';

    return UnorderListButton;

  })(ListButton);

  Simditor.Toolbar.addButton(OrderListButton);

  Simditor.Toolbar.addButton(UnorderListButton);

  BlockquoteButton = (function(_super) {
    __extends(BlockquoteButton, _super);

    function BlockquoteButton() {
      _ref7 = BlockquoteButton.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    BlockquoteButton.prototype.name = 'blockquote';

    BlockquoteButton.prototype.icon = 'quote-left';

    BlockquoteButton.prototype.title = '引用';

    BlockquoteButton.prototype.htmlTag = 'blockquote';

    BlockquoteButton.prototype.disableTag = 'pre';

    BlockquoteButton.prototype.command = function() {
      var $contents, $endBlock, $startBlock, endNode, node, range, results, startNode, _i, _len, _ref8,
        _this = this;
      range = this.editor.selection.getRange();
      startNode = range.startContainer;
      endNode = range.endContainer;
      $startBlock = this.editor.util.furthestBlockEl(startNode);
      $endBlock = this.editor.util.furthestBlockEl(endNode);
      this.editor.selection.save();
      range.setStartBefore($startBlock[0]);
      range.setEndAfter($endBlock[0]);
      $contents = $(range.extractContents());
      results = [];
      $contents.children().each(function(i, el) {
        var c, converted, _i, _len, _results;
        converted = _this._convertEl(el);
        _results = [];
        for (_i = 0, _len = converted.length; _i < _len; _i++) {
          c = converted[_i];
          if (results.length && results[results.length - 1].is(_this.htmlTag) && c.is(_this.htmlTag)) {
            _results.push(results[results.length - 1].append(c.children()));
          } else {
            _results.push(results.push(c));
          }
        }
        return _results;
      });
      _ref8 = results.reverse();
      for (_i = 0, _len = _ref8.length; _i < _len; _i++) {
        node = _ref8[_i];
        range.insertNode(node[0]);
      }
      this.editor.selection.restore();
      this.editor.trigger('valuechanged');
      return this.editor.trigger('selectionchanged');
    };

    BlockquoteButton.prototype._convertEl = function(el) {
      var $el, block, results,
        _this = this;
      $el = $(el);
      results = [];
      if ($el.is(this.htmlTag)) {
        $el.children().each(function(i, node) {
          return results.push($(node));
        });
      } else {
        block = $('<' + this.htmlTag + '/>').append($el);
        results.push(block);
      }
      return results;
    };

    return BlockquoteButton;

  })(Button);

  Simditor.Toolbar.addButton(BlockquoteButton);

  CodeButton = (function(_super) {
    __extends(CodeButton, _super);

    function CodeButton() {
      _ref8 = CodeButton.__super__.constructor.apply(this, arguments);
      return _ref8;
    }

    CodeButton.prototype.name = 'code';

    CodeButton.prototype.icon = 'code';

    CodeButton.prototype.title = '插入代码';

    CodeButton.prototype.htmlTag = 'pre';

    CodeButton.prototype.disableTag = 'li';

    CodeButton.prototype.render = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      CodeButton.__super__.render.apply(this, args);
      return this.popover = new CodePopover(this.editor);
    };

    CodeButton.prototype.status = function($node) {
      var result;
      result = CodeButton.__super__.status.call(this, $node);
      if (this.active) {
        this.popover.show($node);
      } else {
        this.popover.hide();
      }
      return result;
    };

    CodeButton.prototype.command = function() {
      var $contents, $endBlock, $startBlock, endNode, node, range, results, startNode, _i, _len, _ref9,
        _this = this;
      range = this.editor.selection.getRange();
      startNode = range.startContainer;
      endNode = range.endContainer;
      $startBlock = this.editor.util.closestBlockEl(startNode);
      $endBlock = this.editor.util.closestBlockEl(endNode);
      range.setStartBefore($startBlock[0]);
      range.setEndAfter($endBlock[0]);
      $contents = $(range.extractContents());
      results = [];
      $contents.children().each(function(i, el) {
        var c, converted, _i, _len, _results;
        converted = _this._convertEl(el);
        _results = [];
        for (_i = 0, _len = converted.length; _i < _len; _i++) {
          c = converted[_i];
          if (results.length && results[results.length - 1].is(_this.htmlTag) && c.is(_this.htmlTag)) {
            _results.push(results[results.length - 1].append(c.contents()));
          } else {
            _results.push(results.push(c));
          }
        }
        return _results;
      });
      _ref9 = results.reverse();
      for (_i = 0, _len = _ref9.length; _i < _len; _i++) {
        node = _ref9[_i];
        range.insertNode(node[0]);
      }
      this.editor.selection.setRangeAtEndOf(results[0]);
      this.editor.trigger('valuechanged');
      return this.editor.trigger('selectionchanged');
    };

    CodeButton.prototype._convertEl = function(el) {
      var $el, block, codeStr, results;
      $el = $(el);
      results = [];
      if ($el.is(this.htmlTag)) {
        block = $('<p/>').append($el.html().replace('\n', '<br/>'));
        results.push(block);
      } else {
        codeStr = this.editor.formatter.clearHtml($el);
        block = $('<' + this.htmlTag + '/>').append(codeStr);
        results.push(block);
      }
      return results;
    };

    return CodeButton;

  })(Button);

  CodePopover = (function(_super) {
    __extends(CodePopover, _super);

    function CodePopover() {
      _ref9 = CodePopover.__super__.constructor.apply(this, arguments);
      return _ref9;
    }

    CodePopover.prototype._tpl = "<div class=\"code-settings\">\n  <div class=\"settings-field\">\n    <select class=\"select-lang\">\n      <option value=\"-1\">选择语言</option>\n      <option value=\"c++\">C++</option>\n      <option value=\"css\">CSS</option>\n      <option value=\"coffeeScript\">CoffeeScript</option>\n      <option value=\"html\">Html,XML</option>\n      <option value=\"json\">JSON</option>\n      <option value=\"java\">Java</option>\n      <option value=\"js\">JavaScript</option>\n      <option value=\"markdown\">Markdown</option>\n      <option value=\"oc\">Objective C</option>\n      <option value=\"php\">PHP</option>\n      <option value=\"perl\">Perl</option>\n      <option value=\"python\">Python</option>\n      <option value=\"ruby\">Ruby</option>\n      <option value=\"sql\">SQL</option>\n    </select>\n  </div>\n</div>";

    CodePopover.prototype.render = function() {
      var _this = this;
      this.el.addClass('code-popover').append(this._tpl);
      this.selectEl = this.el.find('.select-lang');
      return this.selectEl.on('change', function(e) {
        var lang, oldLang;
        lang = _this.selectEl.val();
        oldLang = _this.target.attr('data-lang');
        _this.target.removeClass('lang' + oldLang).removeAttr('data-lang');
        if (_this.lang !== -1) {
          _this.target.addClass('lang-' + lang);
          return _this.target.attr('data-lang', lang);
        }
      });
    };

    CodePopover.prototype.show = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      CodePopover.__super__.show.apply(this, args);
      this.lang = this.target.attr('data-lang');
      if (this.lang != null) {
        return this.selectEl.val(this.lang);
      }
    };

    return CodePopover;

  })(Popover);

  Simditor.Toolbar.addButton(CodeButton);

  LinkButton = (function(_super) {
    __extends(LinkButton, _super);

    function LinkButton() {
      _ref10 = LinkButton.__super__.constructor.apply(this, arguments);
      return _ref10;
    }

    LinkButton.prototype.name = 'link';

    LinkButton.prototype.icon = 'link';

    LinkButton.prototype.title = '插入链接';

    LinkButton.prototype.htmlTag = 'a';

    LinkButton.prototype.disableTag = 'pre';

    LinkButton.prototype.render = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      LinkButton.__super__.render.apply(this, args);
      return this.popover = new LinkPopover(this.editor);
    };

    LinkButton.prototype.status = function($node) {
      var result;
      result = LinkButton.__super__.status.call(this, $node);
      if (this.active) {
        this.popover.show($node);
      } else {
        this.popover.hide();
      }
      return result;
    };

    LinkButton.prototype.command = function() {
      var $contents, $endBlock, $link, $newBlock, $startBlock, endNode, range, startNode, txtNode,
        _this = this;
      range = this.editor.selection.getRange();
      if (this.active) {
        $link = $(range.commonAncestorContainer).closest('a');
        txtNode = document.createTextNode($link.text());
        $link.replaceWith(txtNode);
        range.selectNode(txtNode);
      } else {
        startNode = range.startContainer;
        endNode = range.endContainer;
        $startBlock = this.editor.util.closestBlockEl(startNode);
        $endBlock = this.editor.util.closestBlockEl(endNode);
        $contents = $(range.extractContents());
        $link = $('<a/>', {
          href: 'http://www.example.com',
          target: '_blank',
          text: this.editor.formatter.clearHtml($contents.contents(), false) || '链接文字'
        });
        if ($startBlock[0] === $endBlock[0]) {
          range.insertNode($link[0]);
        } else {
          $newBlock = $('<p/>').append($link);
          range.insertNode($newBlock[0]);
        }
        range.selectNodeContents($link[0]);
      }
      this.editor.selection.selectRange(range);
      this.popover.one('popovershow', function() {
        _this.popover.textEl.focus();
        return _this.popover.textEl[0].select();
      });
      this.editor.trigger('valuechanged');
      return this.editor.trigger('selectionchanged');
    };

    return LinkButton;

  })(Button);

  LinkPopover = (function(_super) {
    __extends(LinkPopover, _super);

    function LinkPopover() {
      _ref11 = LinkPopover.__super__.constructor.apply(this, arguments);
      return _ref11;
    }

    LinkPopover.prototype._tpl = "<div class=\"link-settings\">\n  <div class=\"settings-field\">\n    <label>文本</label>\n    <input class=\"link-text\" type=\"text\"/>\n  </div>\n  <div class=\"settings-field\">\n    <label>链接</label>\n    <input class=\"link-url\" type=\"text\"/>\n  </div>\n</div>";

    LinkPopover.prototype.render = function() {
      var _this = this;
      this.el.addClass('link-popover').append(this._tpl);
      this.textEl = this.el.find('.link-text');
      this.urlEl = this.el.find('.link-url');
      this.textEl.on('keyup', function(e) {
        if (e.which === 13) {
          return;
        }
        return _this.target.text(_this.textEl.val());
      });
      this.urlEl.on('keyup', function(e) {
        if (e.which === 13) {
          return;
        }
        return _this.target.attr('href', _this.urlEl.val());
      });
      return $([this.urlEl[0], this.textEl[0]]).on('keydown', function(e) {
        if (e.which === 13 || e.which === 27 || (e.which === 9 && $(e.target).hasClass('link-url'))) {
          e.preventDefault();
          return setTimeout(function() {
            var range;
            range = document.createRange();
            _this.editor.selection.setRangeAfter(_this.target, range);
            _this.editor.body.focus();
            _this.hide();
            return _this.editor.trigger('valuechanged');
          }, 0);
        }
      });
    };

    LinkPopover.prototype.show = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      LinkPopover.__super__.show.apply(this, args);
      this.textEl.val(this.target.text());
      return this.urlEl.val(this.target.attr('href'));
    };

    return LinkPopover;

  })(Popover);

  Simditor.Toolbar.addButton(LinkButton);

  ImageButton = (function(_super) {
    __extends(ImageButton, _super);

    ImageButton.prototype._wrapperTpl = "<div class=\"simditor-image\" contenteditable=\"false\" tabindex=\"-1\">\n  <div class=\"simditor-image-resize-handle right\"></div>\n  <div class=\"simditor-image-resize-handle bottom\"></div>\n  <div class=\"simditor-image-resize-handle right-bottom\"></div>\n</div>";

    ImageButton.prototype.name = 'image';

    ImageButton.prototype.icon = 'picture-o';

    ImageButton.prototype.title = '插入图片';

    ImageButton.prototype.htmlTag = 'img';

    ImageButton.prototype.disableTag = 'pre, a, b, strong, i, u, table';

    ImageButton.prototype.defaultImage = '';

    ImageButton.prototype.maxWidth = 0;

    function ImageButton() {
      var args,
        _this = this;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      ImageButton.__super__.constructor.apply(this, args);
      this.defaultImage = this.editor.opts.defaultImage;
      this.maxWidth = this.editor.wrapper.width();
      this.editor.on('decorate', function(e, $el) {
        return $el.find('img').each(function(i, img) {
          return _this.decorate($(img));
        });
      });
      this.editor.on('undecorate', function(e, $el) {
        return $el.find('img').each(function(i, img) {
          return _this.undecorate($(img));
        });
      });
      this.editor.body.on('mousedown', '.simditor-image', function(e) {
        var $img, $imgWrapper;
        $imgWrapper = $(e.currentTarget);
        if ($imgWrapper.hasClass('selected')) {
          _this.popover.srcEl.blur();
          _this.popover.titleEl.blur();
          _this.popover.hide();
          $imgWrapper.removeClass('selected');
        } else {
          _this.editor.body.blur();
          _this.editor.body.find('.simditor-image').removeClass('selected');
          $imgWrapper.addClass('selected').focus();
          $img = $imgWrapper.find('img');
          $imgWrapper.width($img.width());
          $imgWrapper.height($img.height());
          _this.popover.show($imgWrapper);
        }
        return false;
      });
      this.editor.on('selectionchanged', function() {
        return _this.popover.hide();
      });
      this.editor.body.on('keydown', '.simditor-image', function(e) {
        if (e.which !== 8) {
          return;
        }
        _this.popover.hide();
        $(e.currentTarget).remove();
        return false;
      });
    }

    ImageButton.prototype.render = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      ImageButton.__super__.render.apply(this, args);
      return this.popover = new ImagePopover(this);
    };

    ImageButton.prototype.status = function($node) {
      if ($node != null) {
        this.setDisabled($node.is(this.disableTag));
      }
      if (this.disabled) {
        return true;
      }
    };

    ImageButton.prototype.decorate = function($img) {
      var $wrapper;
      $wrapper = $img.parent('.simditor-image');
      if ($wrapper.length > 0) {
        return;
      }
      return $wrapper = $(this._wrapperTpl).insertBefore($img).prepend($img);
    };

    ImageButton.prototype.undecorate = function($img) {
      var $wrapper;
      $wrapper = $img.parent('.simditor-image');
      if ($wrapper.length < 1) {
        return;
      }
      $img.insertAfter($wrapper);
      return $wrapper.remove();
    };

    ImageButton.prototype.loadImage = function($img, src, callback) {
      var $wrapper, img,
        _this = this;
      $wrapper = $img.parent('.simditor-image');
      img = new Image();
      img.onload = function() {
        var height, width;
        if (width > _this.maxWidth) {
          width = _this.maxWidth;
          height = _this.maxWidth * img.height / img.width;
        } else {
          width = img.width;
          height = img.height;
        }
        $img.attr({
          src: src,
          width: width,
          height: height
        });
        $wrapper.width(width).height(height);
        return callback(true);
      };
      img.onerror = function() {
        return callback(false);
      };
      return img.src = src;
    };

    ImageButton.prototype.command = function() {
      var $breakedEl, $endBlock, $img, $startBlock, endNode, range, startNode,
        _this = this;
      range = this.editor.selection.getRange();
      startNode = range.startContainer;
      endNode = range.endContainer;
      $startBlock = this.editor.util.closestBlockEl(startNode);
      $endBlock = this.editor.util.closestBlockEl(endNode);
      range.deleteContents();
      if ($startBlock[0] === $endBlock[0] && $startBlock.is('p')) {
        if (this.editor.util.isEmptyNode($startBlock)) {
          range.selectNode($startBlock[0]);
          range.deleteContents();
        } else if (this.editor.selection.rangeAtEndOf($startBlock, range)) {
          range.setEndAfter($startBlock[0]);
          range.collapse(false);
        } else if (this.editor.selection.rangeAtStartOf($startBlock, range)) {
          range.setEndBefore($startBlock[0]);
          range.collapse(false);
        } else {
          $breakedEl = this.editor.selection.breakBlockEl($startBlock, range);
          range.setEndBefore($breakedEl[0]);
          range.collapse(false);
        }
      }
      $img = $('<img/>');
      range.insertNode($img[0]);
      this.decorate($img);
      return this.loadImage($img, this.defaultImage, function() {
        _this.editor.trigger('valuechanged');
        $img.mousedown();
        return _this.popover.one('popovershow', function() {
          _this.popover.srcEl.focus();
          return _this.popover.srcEl[0].select();
        });
      });
    };

    return ImageButton;

  })(Button);

  ImagePopover = (function(_super) {
    __extends(ImagePopover, _super);

    ImagePopover.prototype._tpl = "<div class=\"link-settings\">\n  <div class=\"settings-field\">\n    <label>地址</label>\n    <input class=\"image-src\" type=\"text\"/>\n  </div>\n  <div class=\"settings-field\">\n    <label>标题</label>\n    <input class=\"image-title\" type=\"text\"/>\n  </div>\n</div>";

    ImagePopover.prototype.offset = {
      top: 6,
      left: -4
    };

    function ImagePopover(button) {
      this.button = button;
      ImagePopover.__super__.constructor.call(this, this.button.editor);
    }

    ImagePopover.prototype.render = function() {
      var _this = this;
      this.el.addClass('image-popover').append(this._tpl);
      this.srcEl = this.el.find('.image-src');
      this.titleEl = this.el.find('.image-title');
      this.srcEl.on('keyup', function(e) {
        if (e.which === 13) {
          return;
        }
        if (_this.timer) {
          clearTimeout(_this.timer);
        }
        return _this.timer = setTimeout(function() {
          var $img, src;
          src = _this.srcEl.val();
          $img = _this.target.find('img');
          return _this.button.loadImage($img, src, function(success) {
            if (!success) {
              return;
            }
            _this.refresh();
            return _this.editor.trigger('valuechanged');
          });
        }, 200);
      });
      this.titleEl.on('keyup', function(e) {
        if (e.which === 13) {
          return;
        }
        return _this.target.find('img').attr('title', _this.titleEl.val());
      });
      return $([this.srcEl[0], this.titleEl[0]]).on('keydown', function(e) {
        if (e.which === 13 || e.which === 27 || (e.which === 9 && $(e.target).hasClass('image-title'))) {
          e.preventDefault();
          _this.srcEl.blur();
          _this.titleEl.blur();
          _this.target.removeClass('selected');
          return _this.hide();
        }
      });
    };

    ImagePopover.prototype.show = function() {
      var $img, args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      ImagePopover.__super__.show.apply(this, args);
      $img = this.target.find('img');
      this.srcEl.val($img.attr('src'));
      return this.titleEl.val($img.attr('title'));
    };

    return ImagePopover;

  })(Popover);

  Simditor.Toolbar.addButton(ImageButton);

}).call(this);
