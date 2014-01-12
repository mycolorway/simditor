(function() {
  var Simditor, Widget, _ref,
    __slice = [].slice,
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

    Widget.prototype.opts = {};

    function Widget(opts) {
      var init, load, _i, _j, _len, _len1, _ref, _ref1;
      $.extend(this.opts, opts);
      this.load(this.opts);
      _ref = this._loadCallbacks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        load = _ref[_i];
        load.call(this);
      }
      this.init(this.opts);
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

    return Widget;

  })();

  Simditor = (function(_super) {
    __extends(Simditor, _super);

    function Simditor() {
      _ref = Simditor.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Simditor.prototype._init = function() {};

    return Simditor;

  })(Widget);

}).call(this);

/*
//# sourceMappingURL=../scripts/simditor.js.map
*/