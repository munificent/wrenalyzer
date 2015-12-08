class Node {

}

class Expr is Node {

}

class BoolExpr is Expr {
  construct new(token) {
    _token = token
  }

  toString { "BoolExpr(%(_token))"}
}

class FieldExpr is Expr {
  construct new(token) {
    _token = token
  }

  toString { "FieldExpr(%(_token))"}
}

class GroupingExpr is Expr {
  construct new(leftParen, expression, rightParen) {
    _leftParen = leftParen
    _expression = expression
    _rightParen = rightParen
  }

  leftParen { _leftParen }
  expression { _expression }
  rightParen { _rightParen }

  toString { "GroupingExpr(%(_leftParen), %(_expression), %(_rightParen))" }
}

class ListExpr is Expr {
  construct new(leftBracket, elements, rightBracket) {
    _leftBracket = leftBracket
    _elements = elements
    _rightBracket = rightBracket
  }

  leftBracket { _leftBracket }
  elements { _elements }
  rightBracket { _rightBracket }

  toString { "ListExpr(%(_leftBracket), %(_elements), %(_rightBracket))" }
}

class MapEntry {
  construct new(key, value) {
    _key = key
    _value = value
  }

  key { _key }
  value { _value }

  toString { "%(_key): %(_value)" }
}

class MapExpr is Expr {
  construct new(leftBrace, entries, rightBrace) {
    _leftBrace = leftBrace
    _entries = entries
    _rightBrace = rightBrace
  }

  leftBrace { _leftBrace }
  entries { _entries }
  rightBracket { _rightBrace }

  toString { "MapExpr(%(_leftBrace), %(_entries), %(_rightBrace))" }
}

class NullExpr is Expr {
  construct new(token) {
    _token = token
  }

  toString { "NullExpr(%(_token))"}
}

class NumberExpr is Expr {
  construct new(value) {
    _value = value
  }
}

class StaticFieldExpr is Expr {
  construct new(token) {
    _token = token
  }

  toString { "StaticFieldExpr(%(_token))"}
}

class ThisExpr is Expr {
  construct new(token) {
    _token = token
  }

  toString { "ThisExpr(%(_token))"}
}
