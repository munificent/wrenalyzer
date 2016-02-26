import "chars" for Chars

class Scope {
  construct new(reporter) {
    _reporter = reporter

    // TODO: Hard-coding these is a hack (as is using "true" for their value
    // instead of a token). Should load the core library and implicitly import
    // it.
    var moduleScope = {
      "Bool": true,
      "Class": true,
      "Fiber": true,
      "Fn": true,
      "List": true,
      "Map": true,
      "MapKeySequence": true,
      "MapSequence": true,
      "MapValueSequence": true,
      "Null": true,
      "Num": true,
      "Object": true,
      "Range": true,
      "Sequence": true,
      "String": true,
      "StringByteSequence": true,
      "StringCodePointSequence": true,
      "System": true,
      "WhereSequence": true
    }
    _scopes = [moduleScope]

    _forwardReferences = []
  }

  /// Declares a variable with [name] in the current scope.
  declare(name) {
    var scope = _scopes[-1]
    if (scope.containsKey(name.text)) {
      _reporter.error(
            "A variable named '%(name.text)' is already defined in " +
            "this scope, on line %(scope[name.text].lineStart).",
            [scope[name.text], name])
      return
    }

    scope[name.text] = name
  }

  /// Looks for a previously declared variable with [name].
  ///
  /// Reports an error if not found.
  resolve(name) {
    var reachedClass = false
    for (i in (_scopes.count - 1)..0) {
      // Don't walk past a class definition.
      if (_scopes[i] == null) {
        reachedClass = true
        break
      }

      if (_scopes[i].containsKey(name.text)) {
        // Found it in a containing lexical scope.
        return _scopes[i][name.text]
      }
    }

    if (reachedClass) {
      if (Chars.isLowerAlpha(name.text.bytes[0])) {
        // A lowercase name inside a class is treated like a self-send so do
        // nothing.
        return null
      } else {
        // A capitalized name is resolved at the module level.
        if (_scopes[0].containsKey(name.text)) {
          // Found it in a containing lexical scope.
          return _scopes[0][name.text]
        } else {
          // Assume it's a forward reference for now.
          _forwardReferences.add(name)
          return
        }
      }
    }

    // If we got here, it's not defined.
    _reporter.error("Variable '%(name.text)' is not defined.", [name])
  }

  // Begins a new lexical block scope.
  begin() {
    _scopes.add({})
  }

  // Ends the innermost scope.
  end() {
    _scopes.removeAt(-1)
  }

  /// Marks that we are inside a class definition.
  ///
  /// When walking up lexical scopes for a name, we stop at a class definition
  /// so we can detect implicit self sends.
  beginClass() {
    // TODO: Using a null scope as a sentinel is kind of hacky.
    _scopes.add(null)
  }

  /// Ends the current class definition.
  endClass() {
    _scopes.removeAt(-1)
  }

  /// Report errors for any module-level variables that were referenced but
  /// never defined.
  checkForwardReferences() {
    for (use in _forwardReferences) {
      if (!_scopes[0].containsKey(use.text)) {
        _reporter.error("Variable '%(use.text)' is not defined.", [use])
      }
    }
  }
}
