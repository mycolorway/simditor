(function() {
  var BlockquoteButton, BoldButton, Button, CodeButton, Formatter, InputManager, ItalicButton, LinkButton, ListButton, OrderListButton, Plugin, Selection, Simditor, Toolbar, UnderlineButton, UndoManager, UnorderListButton, Util, Widget, _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  Widget = (function() {
    Widget.extend = function(obj) {
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

    Widget.include = function(obj) {
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
        instance._init();
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

  window.Widget = Widget;

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

  Plugin = (function() {
    Plugin.prototype.opts = {};

    function Plugin(editor) {
      this.editor = editor;
      $.extend(this.opts, this.editor.opts);
    }

    Plugin.prototype._init = function() {};

    return Plugin;

  })();

  Selection = (function(_super) {
    __extends(Selection, _super);

    function Selection(editor) {
      this.editor = editor;
      Selection.__super__.constructor.call(this, this.editor);
      this.sel = document.getSelection();
    }

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
      var endNode, result,
        _this = this;
      if (range == null) {
        range = this.getRange();
      }
      if (!((range != null) && range.collapsed)) {
        return;
      }
      node = $(node)[0];
      endNode = range.endContainer;
      if (range.endOffset !== this.editor.util.getNodeLength(endNode)) {
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
      var $node, contents, lastChild, nodeLength;
      if (range == null) {
        range = this.getRange();
      }
      $node = $(node);
      node = $node.get(0);
      if ($node.is('pre')) {
        contents = $node.contents();
        if (contents.length > 0) {
          lastChild = contents.last();
          range.setEnd(lastChild[0], this.editor.util.getNodeLength(lastChild[0]) - 1);
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
      _ref = Formatter.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Formatter.prototype._init = function() {
      var _this = this;
      return this.editor.body.on('click', 'a', function(e) {
        return false;
      });
    };

    Formatter.prototype._allowedTags = ['p', 'ul', 'ol', 'li', 'blockquote', 'hr', 'pre', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'table'];

    Formatter.prototype.decorate = function($el) {
      if ($el == null) {
        $el = this.editor.body;
      }
      return this.editor.trigger('decorate', [$el]);
    };

    Formatter.prototype.undecorate = function($el) {
      var emptyP, lastP;
      if ($el == null) {
        $el = this.editor.body.clone();
      }
      this.editor.trigger('undecorate', [$el]);
      this.autolink($el);
      lastP = $el.children().last('p');
      while (lastP.is('p' && !lastP.text() && !lastP.find('img').length)) {
        emptyP = lastP;
        lastP = lastP.prev('p');
        emptyP.remove();
      }
      return $.trim($el.html());
    };

    Formatter.prototype.autolink = function($el) {
      var $node, findLinkNode, linkNodes, re, text, _i, _len;
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
    };

    Formatter.prototype.format = function($el) {
      var blockNode, node, _i, _len, _ref1, _results;
      if ($el == null) {
        $el = this.editor.body;
      }
      if ($el.is(':empty')) {
        $el.append('<p>' + this.editor.util.phBr + '</p>');
        return $el;
      }
      _ref1 = $el.contents();
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        node = _ref1[_i];
        if (this.editor.util.isBlockNode(node)) {
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
    };

    Formatter.prototype.cleanNode = function(node, recursive) {
      var $node, attr, contents, n, _i, _j, _len, _len1, _ref1, _ref2, _ref3, _results;
      $node = $(node);
      if ($node[0].nodeType === 3) {
        return;
      }
      contents = $node.contents();
      if ($node.is(this._allowedTags.join(','))) {
        _ref1 = $.makeArray($node[0].attributes);
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          attr = _ref1[_i];
          if (!($node.is('img' && ((_ref2 = attr.name) === 'src' || _ref2 === 'alt'))) && !($node.is('a' && ((_ref3 = attr.name) === 'href' || _ref3 === 'target')))) {
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

    function InputManager() {
      _ref1 = InputManager.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    InputManager.prototype.opts = {
      tabIndent: true
    };

    InputManager.prototype._modifierKeys = [16, 17, 18, 91, 93];

    InputManager.prototype._arrowKeys = [37, 38, 39, 40];

    InputManager.prototype._init = function() {
      var _this = this;
      this._pasteArea = $('<textarea/>').css({
        width: '1px',
        height: '1px',
        overflow: 'hidden',
        resize: 'none',
        position: 'fixed',
        right: '0',
        bottom: '100px'
      }).attr('tabIndex', '-1').addClass('simditor-paste-area').appendTo(this.editor.el);
      this.editor.on('destroy', function() {
        return _this._pasteArea.remove();
      });
      this.editor.on('valuechanged', function() {
        return _this.editor.body.find('pre').each(function(i, pre) {
          var $pre;
          $pre = $(pre);
          if ($pre.next().length === 0) {
            return $('<p/>').append(_this.editor.util.phBr).insertAfter($pre);
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
      return this.editor.trigger('selectionchanged');
    };

    InputManager.prototype._onKeyDown = function(e) {
      var $blockEl, $br, $prevBlockEl, metaKey, result, spaceNode, spaces, _ref2, _ref3,
        _this = this;
      if (this.editor.triggerHandler(e) === false) {
        return false;
      }
      if ((_ref2 = e.which, __indexOf.call(this._modifierKeys, _ref2) >= 0) || (_ref3 = e.which, __indexOf.call(this._arrowKeys, _ref3) >= 0)) {
        return;
      }
      metaKey = this.editor.util.metaKey(e);
      $blockEl = this.editor.util.closestBlockEl();
      if (metaKey && e.which === 86) {
        return;
      }
      if (metaKey && this._shortcuts[e.which]) {
        this._shortcuts[e.which].call(this, e);
        return false;
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
      if (e.which === 9 && (this.opts.tabIndent || $blockEl.is('pre'))) {
        spaces = $blockEl.is('pre') ? '\u00A0\u00A0' : '\u00A0\u00A0\u00A0\u00A0';
        spaceNode = document.createTextNode(spaces);
        this.editor.selection.insertNode(spaceNode);
        this.editor.trigger('valuechanged');
        this.editor.trigger('selectionchanged');
        return false;
      }
      if (e.which in this._inputHandlers) {
        result = null;
        this.editor.util.traverseUp(function(node) {
          var handler, _ref4;
          if (node.nodeType !== 1) {
            return;
          }
          handler = (_ref4 = _this._inputHandlers[e.which]) != null ? _ref4[node.tagName.toLowerCase()] : void 0;
          result = handler != null ? handler.call(_this, e, $(node)) : void 0;
          return !result;
        });
        if (result) {
          this.editor.trigger('valuechanged');
          this.editor.trigger('selectionchanged');
          return false;
        }
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
      var p, _ref2;
      if (this.editor.triggerHandler(e) === false) {
        return false;
      }
      if (_ref2 = e.which, __indexOf.call(this._arrowKeys, _ref2) >= 0) {
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
        var el, els, insertPosition, node, pasteContent, range, re, result;
        pasteContent = _this._pasteArea.val();
        _this._pasteArea.val('');
        if (!codePaste) {
          els = [];
          re = /(.*)(\n*)/g;
          while (result = re.exec(pasteContent)) {
            if (!result[0]) {
              break;
            }
            if (typeof el === "undefined" || el === null) {
              el = $('<p/>');
            }
            el.append(result[1]);
            if (result[2].length > 1) {
              els.push(el[0]);
              el = null;
            } else if (result[2].length === 1) {
              el.append('<br/>');
            }
          }
          if (el != null) {
            els.push(el[0]);
          }
          pasteContent = $(els);
        }
        range = _this.editor.selection.restore();
        if (codePaste && pasteContent) {
          node = document.createTextNode(pasteContent);
          _this.editor.selection.insertNode(node, range);
        } else if (pasteContent.length < 1) {
          return;
        } else if (pasteContent.length === 1) {
          node = document.createTextNode(pasteContent.text());
          _this.editor.selection.insertNode(node, range);
        } else if (pasteContent.length > 1) {
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
      }, 0);
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
      }
    };

    InputManager.prototype._shortcuts = {
      13: function(e) {
        return this.editor.el.closest('form').find('button:submit').click();
      }
    };

    InputManager.prototype.addShortcut = function(keyCode, handler) {
      return this._shortcuts[keyCode] = $.proxy(handler, this);
    };

    return InputManager;

  })(Plugin);

  UndoManager = (function(_super) {
    __extends(UndoManager, _super);

    function UndoManager() {
      _ref2 = UndoManager.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    UndoManager.prototype._stack = [];

    UndoManager.prototype._index = -1;

    UndoManager.prototype._capacity = 50;

    UndoManager.prototype._timer = null;

    UndoManager.prototype._init = function() {
      var _this = this;
      this.editor.inputManager.addShortcut(90, function(e) {
        if (e.shiftKey) {
          return _this.redo();
        } else {
          return _this.undo();
        }
      });
      this.editor.on('valuechanged', function(e, src) {
        if (src === 'undo' || !_this.editor.inputManager.focused) {
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
      return this._pushUndoState();
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
      this.editor.sync();
      this.caretPosition(state.caret);
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
      this.editor.sync();
      this.caretPosition(state.caret);
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
      var childNodes, node, offset, _i, _len, _ref3;
      node = this.editor.body[0];
      _ref3 = position.slice(0, position.length - 1);
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        offset = _ref3[_i];
        childNodes = node.childNodes;
        if (offset > childNodes.length - 1) {
          debugger;
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

    function Util(editor) {
      this.editor = editor;
      Util.__super__.constructor.call(this, this.editor);
      if (this.browser.msie) {
        this.phBr = '';
      }
    }

    Util.prototype.phBr = '<br/>';

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

    function Toolbar() {
      _ref3 = Toolbar.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    Toolbar.prototype.opts = {
      toolbar: true,
      toolbarFloat: true
    };

    Toolbar.prototype._tpl = {
      wrapper: '<div class="simditor-toolbar"><ul></ul></div>',
      separator: '<li><span class="separator"></span></li>'
    };

    Toolbar.prototype._init = function() {
      var _this = this;
      if (!this.opts.toolbar) {
        return;
      }
      if (!$.isArray(this.opts.toolbar)) {
        this.opts.toolbar = ['bold', 'italic', 'underline', '|', 'ol', 'ul', 'blockquote', 'code', '|', 'link'];
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
      return this.editor.on('selectionchanged', function() {
        return _this.toolbarStatus();
      });
    };

    Toolbar.prototype._render = function() {
      var name, _i, _len, _ref4, _results;
      this.wrapper = $(this._tpl.wrapper).prependTo(this.editor.wrapper);
      this.list = this.wrapper.find('ul');
      this.editor.wrapper.addClass('toolbar-enabled');
      _ref4 = this.opts.toolbar;
      _results = [];
      for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
        name = _ref4[_i];
        if (name === '|') {
          $(this._tpl.separator).appendTo(this.list);
          continue;
        }
        if (!this.constructor.buttons[name]) {
          throw new Error('simditor: invalid toolbar button "' + name + '"');
          continue;
        }
        _results.push(this._buttons.push(new this.constructor.buttons[name](this)));
      }
      return _results;
    };

    Toolbar.prototype.toolbarStatus = function(name) {
      var button, buttons, success, _i, _len, _results,
        _this = this;
      if (!this.editor.inputManager.focused) {
        return;
      }
      buttons = this._buttons.slice(0);
      success = this.editor.util.traverseUp(function(node) {
        var button, i, removeIndex, _i, _j, _len, _len1;
        removeIndex = [];
        for (i = _i = 0, _len = buttons.length; _i < _len; i = ++_i) {
          button = buttons[i];
          if ((name != null) && button.name !== name) {
            continue;
          }
          if (!button.status || button.status($(node)) === true) {
            removeIndex.push(i);
          }
        }
        for (_j = 0, _len1 = removeIndex.length; _j < _len1; _j++) {
          i = removeIndex[_j];
          buttons.splice(i, 1);
        }
        if (buttons.length === 0) {
          return false;
        }
      });
      if (!success) {
        _results = [];
        for (_i = 0, _len = buttons.length; _i < _len; _i++) {
          button = buttons[_i];
          _results.push(button.setActive(false));
        }
        return _results;
      }
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
      _ref4 = Simditor.__super__.constructor.apply(this, arguments);
      return _ref4;
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
      placeholder: 'Type here...'
    };

    Simditor.prototype._init = function() {
      var editor, form, _ref5,
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
      this.setValue((_ref5 = this.textarea.val()) != null ? _ref5 : '');
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
      return this.body.attr('tabindex', this.textarea.attr('tabindex'));
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
      var val;
      val = this.formatter.undecorate();
      this.textarea.val(val);
      return val;
    };

    Simditor.prototype.destroy = function() {
      this.trigger('destroy');
      this.textarea.closest('form'.off('.simditor .simditor-' + this.id));
      this.selection.clear();
      this.textarea.insertBefore(this.el).hide().val(''.removeData('simditor'));
      this.el.remove();
      $(document).off('.simditor-' + this.id);
      return $(window).off('.simditor-' + this.id);
    };

    return Simditor;

  })(Widget);

  window.Simditor = Simditor;

  window.Simditor.Plugin = Plugin;

  Button = (function() {
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

    Button.prototype.menu = false;

    Button.prototype.active = false;

    Button.prototype.shortcut = null;

    function Button(toolbar) {
      var _this = this;
      this.toolbar = toolbar;
      this.render();
      this.el.on('mousedown', function(e) {
        e.preventDefault();
        if (_this.el.hasClass('disabled')) {
          return;
        }
        if (_this.menu) {
          return _this.toolbar.wrapper.toggleClass('menu-on');
        } else {
          return _this.command();
        }
      });
      this.toolbar.list.on('mousedown', 'a.menu-item', function(e) {
        var btn, param;
        e.preventDefault();
        btn = $(e.currentTarget);
        if (btn.hasClass('disabled')) {
          return;
        }
        _this.toolbar.wrapper.removeClass('menu-on');
        param = btn.data('param');
        return _this.command(param);
      });
      this.toolbar.editor.on('blur', function() {
        return _this.setActive(false);
      });
      if (this.shortcut != null) {
        this.toolbar.editor.inputManager.addShortcut(this.shortcut, function(e) {
          return _this.el.mousedown();
        });
      }
    }

    Button.prototype.render = function() {
      this.wrapper = $(this._tpl.item).appendTo(this.toolbar.list);
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
      var $menuBtntnEl, $menuItemEl, menuItem, _i, _len, _ref5, _results;
      if (!$.isArray(this.menu)) {
        return;
      }
      this.menuEl = $('<ul/>').appendTo(this.menuWrapper);
      _ref5 = this.menu;
      _results = [];
      for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
        menuItem = _ref5[_i];
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

    Button.prototype.status = function($node) {
      if ($node != null) {
        this.setActive($node.is(this.htmlTag));
      }
      return this.active;
    };

    Button.prototype.command = function(param) {
      var editor;
      editor = this.toolbar.editor;
      if (!editor.focused) {
        return editor.body.focus();
      }
    };

    return Button;

  })();

  BoldButton = (function(_super) {
    __extends(BoldButton, _super);

    function BoldButton() {
      _ref5 = BoldButton.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    BoldButton.prototype.name = 'bold';

    BoldButton.prototype.icon = 'bold';

    BoldButton.prototype.title = '加粗文字';

    BoldButton.prototype.htmlTag = 'b, strong';

    BoldButton.prototype.shortcut = 66;

    BoldButton.prototype.status = function() {
      var active;
      active = document.queryCommandState('bold') === true;
      this.setActive(active);
      return active;
    };

    BoldButton.prototype.command = function() {
      BoldButton.__super__.command.call(this);
      document.execCommand('bold');
      this.toolbar.editor.trigger('valuechanged');
      return this.toolbar.editor.trigger('selectionchanged');
    };

    return BoldButton;

  })(Button);

  Simditor.Toolbar.addButton(BoldButton);

  ItalicButton = (function(_super) {
    __extends(ItalicButton, _super);

    function ItalicButton() {
      _ref6 = ItalicButton.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    ItalicButton.prototype.name = 'italic';

    ItalicButton.prototype.icon = 'italic';

    ItalicButton.prototype.title = '斜体文字';

    ItalicButton.prototype.htmlTag = 'i';

    ItalicButton.prototype.shortcut = 73;

    ItalicButton.prototype.status = function() {
      var active;
      active = document.queryCommandState('italic') === true;
      this.setActive(active);
      return active;
    };

    ItalicButton.prototype.command = function() {
      ItalicButton.__super__.command.call(this);
      document.execCommand('italic');
      this.toolbar.editor.trigger('valuechanged');
      return this.toolbar.editor.trigger('selectionchanged');
    };

    return ItalicButton;

  })(Button);

  Simditor.Toolbar.addButton(ItalicButton);

  UnderlineButton = (function(_super) {
    __extends(UnderlineButton, _super);

    function UnderlineButton() {
      _ref7 = UnderlineButton.__super__.constructor.apply(this, arguments);
      return _ref7;
    }

    UnderlineButton.prototype.name = 'underline';

    UnderlineButton.prototype.icon = 'underline';

    UnderlineButton.prototype.title = '下划线文字';

    UnderlineButton.prototype.htmlTag = 'u';

    UnderlineButton.prototype.shortcut = 85;

    UnderlineButton.prototype.status = function() {
      var active;
      active = document.queryCommandState('underline') === true;
      this.setActive(active);
      return active;
    };

    UnderlineButton.prototype.command = function() {
      UnderlineButton.__super__.command.call(this);
      document.execCommand('underline');
      this.toolbar.editor.trigger('valuechanged');
      return this.toolbar.editor.trigger('selectionchanged');
    };

    return UnderlineButton;

  })(Button);

  Simditor.Toolbar.addButton(UnderlineButton);

  ListButton = (function(_super) {
    __extends(ListButton, _super);

    function ListButton() {
      _ref8 = ListButton.__super__.constructor.apply(this, arguments);
      return _ref8;
    }

    ListButton.prototype.type = '';

    ListButton.prototype.command = function(param) {
      var $breakedEl, $contents, $endBlock, $startBlock, editor, endNode, node, range, results, startNode, _i, _len, _ref9,
        _this = this;
      ListButton.__super__.command.call(this);
      editor = this.toolbar.editor;
      range = editor.selection.getRange();
      startNode = range.startContainer;
      endNode = range.endContainer;
      $startBlock = editor.util.closestBlockEl(startNode);
      $endBlock = editor.util.closestBlockEl(endNode);
      editor.selection.save();
      range.setStartBefore($startBlock[0]);
      range.setEndAfter($endBlock[0]);
      if ($startBlock.is('li') && $endBlock.is('li') && $startBlock.parent()[0] === $endBlock.parent()[0]) {
        $breakedEl = $startBlock.parent();
      }
      $contents = $(range.extractContents());
      if ($breakedEl != null) {
        $contents.wrapInner('<' + $breakedEl[0].tagName + '/>');
        if (editor.selection.rangeAtStartOf($breakedEl, range)) {
          range.setEndBefore($breakedEl[0]);
          range.collapse(false);
        } else if (editor.selection.rangeAtEndOf($breakedEl, range)) {
          range.setEndAfter($breakedEl[0]);
          range.collapse(false);
        } else {
          $breakedEl = editor.selection.breakBlockEl($breakedEl, range);
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
      _ref9 = results.reverse();
      for (_i = 0, _len = _ref9.length; _i < _len; _i++) {
        node = _ref9[_i];
        range.insertNode(node[0]);
      }
      editor.selection.restore();
      this.toolbar.editor.trigger('valuechanged');
      return this.toolbar.editor.trigger('selectionchanged');
    };

    ListButton.prototype._convertEl = function(el) {
      var $el, anotherType, block, child, children, editor, results, _i, _len, _ref9,
        _this = this;
      editor = this.toolbar.editor;
      $el = $(el);
      results = [];
      anotherType = this.type === 'ul' ? 'ol' : 'ul';
      if ($el.is(this.type)) {
        $el.find('li').each(function(i, li) {
          var block;
          block = $('<p/>').append($(li).html() || editor.util.phBr);
          return results.push(block);
        });
      } else if ($el.is(anotherType)) {
        block = $('<' + this.type + '/>').append($el.html());
        results.push(block);
      } else if ($el.is('blockquote')) {
        _ref9 = $el.children().get();
        for (_i = 0, _len = _ref9.length; _i < _len; _i++) {
          child = _ref9[_i];
          children = this._convertEl(child);
        }
        $.merge(results, children);
      } else if ($el.is('table')) {

      } else {
        block = $('<' + this.type + '><li></li></' + this.type + '>');
        block.find('li').append($el.html() || editor.util.phBr);
        results.push(block);
      }
      return results;
    };

    return ListButton;

  })(Button);

  OrderListButton = (function(_super) {
    __extends(OrderListButton, _super);

    function OrderListButton() {
      _ref9 = OrderListButton.__super__.constructor.apply(this, arguments);
      return _ref9;
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
      _ref10 = UnorderListButton.__super__.constructor.apply(this, arguments);
      return _ref10;
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
      _ref11 = BlockquoteButton.__super__.constructor.apply(this, arguments);
      return _ref11;
    }

    BlockquoteButton.prototype.name = 'blockquote';

    BlockquoteButton.prototype.icon = 'quote-left';

    BlockquoteButton.prototype.title = '引用';

    BlockquoteButton.prototype.htmlTag = 'blockquote';

    BlockquoteButton.prototype.command = function() {
      var $contents, $endBlock, $startBlock, editor, endNode, node, range, results, startNode, _i, _len, _ref12,
        _this = this;
      BlockquoteButton.__super__.command.call(this);
      editor = this.toolbar.editor;
      range = editor.selection.getRange();
      startNode = range.startContainer;
      endNode = range.endContainer;
      $startBlock = editor.util.furthestBlockEl(startNode);
      $endBlock = editor.util.furthestBlockEl(endNode);
      editor.selection.save();
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
      _ref12 = results.reverse();
      for (_i = 0, _len = _ref12.length; _i < _len; _i++) {
        node = _ref12[_i];
        range.insertNode(node[0]);
      }
      editor.selection.restore();
      this.toolbar.editor.trigger('valuechanged');
      return this.toolbar.editor.trigger('selectionchanged');
    };

    BlockquoteButton.prototype._convertEl = function(el) {
      var $el, block, editor, results,
        _this = this;
      editor = this.toolbar.editor;
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
      _ref12 = CodeButton.__super__.constructor.apply(this, arguments);
      return _ref12;
    }

    CodeButton.prototype.name = 'code';

    CodeButton.prototype.icon = 'code';

    CodeButton.prototype.title = '插入代码';

    CodeButton.prototype.htmlTag = 'pre';

    CodeButton.prototype.command = function() {
      var $contents, $endBlock, $startBlock, editor, endNode, node, range, results, startNode, _i, _len, _ref13,
        _this = this;
      CodeButton.__super__.command.call(this);
      editor = this.toolbar.editor;
      range = editor.selection.getRange();
      startNode = range.startContainer;
      endNode = range.endContainer;
      $startBlock = editor.util.closestBlockEl(startNode);
      $endBlock = editor.util.closestBlockEl(endNode);
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
      _ref13 = results.reverse();
      for (_i = 0, _len = _ref13.length; _i < _len; _i++) {
        node = _ref13[_i];
        range.insertNode(node[0]);
      }
      editor.selection.setRangeAtEndOf(results[0]);
      this.toolbar.editor.trigger('valuechanged');
      return this.toolbar.editor.trigger('selectionchanged');
    };

    CodeButton.prototype._convertEl = function(el) {
      var $el, block, codeStr, editor, results;
      editor = this.toolbar.editor;
      $el = $(el);
      results = [];
      if ($el.is(this.htmlTag)) {
        block = $('<p/>').append($el.html().replace('\n', '<br/>'));
        results.push(block);
      } else {
        codeStr = editor.formatter.clearHtml($el);
        block = $('<' + this.htmlTag + '/>').append(codeStr);
        results.push(block);
      }
      return results;
    };

    return CodeButton;

  })(Button);

  Simditor.Toolbar.addButton(CodeButton);

  LinkButton = (function(_super) {
    __extends(LinkButton, _super);

    function LinkButton() {
      _ref13 = LinkButton.__super__.constructor.apply(this, arguments);
      return _ref13;
    }

    LinkButton.prototype.name = 'link';

    LinkButton.prototype.icon = 'link';

    LinkButton.prototype.title = '插入链接';

    LinkButton.prototype.htmlTag = 'a';

    LinkButton.prototype.command = function() {
      var $contents, $endBlock, $link, $newBlock, $startBlock, editor, endNode, range, startNode;
      LinkButton.__super__.command.call(this);
      editor = this.toolbar.editor;
      range = editor.selection.getRange();
      startNode = range.startContainer;
      endNode = range.endContainer;
      $startBlock = editor.util.closestBlockEl(startNode);
      $endBlock = editor.util.closestBlockEl(endNode);
      $contents = $(range.extractContents());
      $link = $('<a/>', {
        href: 'http://www.example.com',
        target: '_blank',
        text: editor.formatter.clearHtml($contents.contents(), false) || '链接文字'
      });
      if ($startBlock[0] === $endBlock[0]) {
        range.insertNode($link[0]);
      } else {
        $newBlock = $('<p/>').append($link);
        range.insertNode($newBlock);
      }
      range.selectNodeContents($link[0]);
      editor.selection.selectRange(range);
      this.toolbar.editor.trigger('valuechanged');
      return this.toolbar.editor.trigger('selectionchanged');
    };

    return LinkButton;

  })(Button);

  Simditor.Toolbar.addButton(LinkButton);

}).call(this);
