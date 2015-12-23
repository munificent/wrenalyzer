class Node {

}

class Expr is Node {

}

class AssignmentExpr is Expr {
  construct new(target, equal, value) {
    _target = target
    _equal = equal
    _value = value
  }

  target { _target }
  equal { _equal }
  value { _value }

  toString { "Assignment(%(_target) %(_equal) %(_value))" }
}

class BoolExpr is Expr {
  construct new(token) {
    _token = token
  }

  toString { "Bool(%(_token))" }
}

class CallExpr is Expr {
  construct new(receiver, name, arguments) {
    _receiver = receiver
    _name = name
    _arguments = arguments
  }

  // The receiver of the method call.
  //
  // This will be null if the call has an implicit receiver.
  receiver { _receiver }
  name { _name }
  arguments { _arguments }

  toString { "Call(%(_receiver) %(_name) %(_arguments))" }
}

class ConditionalExpr is Expr {
  construct new(condition, question, thenBranch, colon, elseBranch) {
    _condition = condition
    _question = question
    _thenBranch = thenBranch
    _colon = colon
    _elseBranch = elseBranch
  }

  condition { _condition }
  question { _question }
  thenBranch { _thenBranch }
  colon { _colon }
  elseBranch { _elseBranch }

  toString {
    return "Conditional(%(_condition) %(_question) %(_thenBranch) " +
           "%(_colon) %(_elseBranch))"
  }
}

class FieldExpr is Expr {
  construct new(token) {
    _token = token
  }

  toString { "Field(%(_token))" }
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

  toString { "Grouping(%(_leftParen) %(_expression) %(_rightParen))" }
}

class InfixExpr is Expr {
  construct new(left, operator, right) {
    _left = left
    _operator = operator
    _right = right
  }

  left { _left }
  operator { _operator }
  right { _right }

  toString { "Infix(%(_left) %(_operator) %(_right))" }
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

  toString { "List(%(_leftBracket) %(_elements) %(_rightBracket))" }
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

  toString { "Map(%(_leftBrace) %(_entries) %(_rightBrace))" }
}

class NullExpr is Expr {
  construct new(token) {
    _token = token
  }

  toString { "Null(%(_token))" }
}

class NumExpr is Expr {
  construct new(token) {
    _token = token
  }

  toString { "Num(%(_token))" }
}

class PrefixExpr is Expr {
  construct new(operator, right) {
    _operator = operator
    _right = right
  }

  operator { _operator }
  right { _right }

  toString { "Prefix(%(_operator) %(_right))" }
}

class StaticFieldExpr is Expr {
  construct new(token) {
    _token = token
  }

  toString { "StaticField(%(_token))" }
}

class SubscriptExpr is Expr {
  construct new(receiver, leftBracket, arguments, rightBracket) {
    _receiver = receiver
    _leftBracket = leftBracket
    _arguments = arguments
    _rightBracket = rightBracket
  }

  receiver { _receiver }
  leftBracket { _leftBracket }
  arguments { _arguments }
  rightBracket { _rightBracket }

  toString {
    return "Subscript(%(_receiver) %(_leftBracket) %(_arguments) " +
           "%(_rightBracket))"
  }
}

class ThisExpr is Expr {
  construct new(token) {
    _token = token
  }

  toString { "This(%(_token))" }
}
