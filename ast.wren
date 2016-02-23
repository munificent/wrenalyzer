class Node {}

class Expr is Node {}

class Stmt is Node {}

class Module is Node {
  construct new(statements) {
    _statements = statements
  }

  statements { _statements }

  toString { "Module(%(_statements))" }
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

class Method {
  construct new(staticKeyword, constructKeyword, name, parameters, body) {
    _staticKeyword = staticKeyword
    _constructKeyword = constructKeyword
    _name = name
    _parameters = parameters
    _body = body
  }

  staticKeyword { _staticKeyword }
  constructKeyword { _constructKeyword }
  name { _name }
  parameters { _parameters }
  body { _body }

  toString {
    return "Method(%(_staticKeyword) %(_constructKeyword) %(_name) %(_parameters) %(_body))"
  }
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

  toString {
    return "List(%(_leftBracket) %(_elements) %(_rightBracket))"
  }
}

class ThisExpr is Expr {
  construct new(keyword) {
    _keyword = keyword
  }

  keyword { _keyword }

  toString {
    return "This(%(_keyword))"
  }
}

class NullExpr is Expr {
  construct new(value) {
    _value = value
  }

  value { _value }

  toString {
    return "Null(%(_value))"
  }
}

class StaticFieldExpr is Expr {
  construct new(name) {
    _name = name
  }

  name { _name }

  toString {
    return "StaticField(%(_name))"
  }
}

class FieldExpr is Expr {
  construct new(name) {
    _name = name
  }

  name { _name }

  toString {
    return "Field(%(_name))"
  }
}

class CallExpr is Expr {
  construct new(receiver, name, arguments, blockParameters, blockBody) {
    _receiver = receiver
    _name = name
    _arguments = arguments
    _blockParameters = blockParameters
    _blockBody = blockBody
  }

  receiver { _receiver }
  name { _name }
  arguments { _arguments }
  blockParameters { _blockParameters }
  blockBody { _blockBody }

  toString {
    return "Call(%(_receiver) %(_name) %(_arguments) %(_blockParameters) %(_blockBody))"
  }
}

class PrefixExpr is Expr {
  construct new(operator, right) {
    _operator = operator
    _right = right
  }

  operator { _operator }
  right { _right }

  toString {
    return "Prefix(%(_operator) %(_right))"
  }
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

  toString {
    return "Grouping(%(_leftParen) %(_expression) %(_rightParen))"
  }
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

  toString {
    return "Assignment(%(_target) %(_equal) %(_value))"
  }
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

  toString {
    return "Infix(%(_left) %(_operator) %(_right))"
  }
}

class MapExpr is Expr {
  construct new(leftBrace, entries, rightBrace) {
    _leftBrace = leftBrace
    _entries = entries
    _rightBrace = rightBrace
  }

  leftBrace { _leftBrace }
  entries { _entries }
  rightBrace { _rightBrace }

  toString {
    return "Map(%(_leftBrace) %(_entries) %(_rightBrace))"
  }
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
    return "Conditional(%(_condition) %(_question) %(_thenBranch) %(_colon) %(_elseBranch))"
  }
}

class NumExpr is Expr {
  construct new(value) {
    _value = value
  }

  value { _value }

  toString {
    return "Num(%(_value))"
  }
}

class StringExpr is Expr {
  construct new(value) {
    _value = value
  }

  value { _value }

  toString {
    return "String(%(_value))"
  }
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
    return "Subscript(%(_receiver) %(_leftBracket) %(_arguments) %(_rightBracket))"
  }
}

class BoolExpr is Expr {
  construct new(value) {
    _value = value
  }

  value { _value }

  toString {
    return "Bool(%(_value))"
  }
}

class InterpolationExpr is Expr {
  construct new(strings, expressions) {
    _strings = strings
    _expressions = expressions
  }

  strings { _strings }
  expressions { _expressions }

  toString {
    return "Interpolation(%(_strings) %(_expressions))"
  }
}

class ForStmt is Stmt {
  construct new(variable, iterator, body) {
    _variable = variable
    _iterator = iterator
    _body = body
  }

  variable { _variable }
  iterator { _iterator }
  body { _body }

  toString {
    return "For(%(_variable) %(_iterator) %(_body))"
  }
}

class ReturnStmt is Stmt {
  construct new(keyword, value) {
    _keyword = keyword
    _value = value
  }

  keyword { _keyword }
  value { _value }

  toString {
    return "Return(%(_keyword) %(_value))"
  }
}

class BlockStmt is Stmt {
  construct new(statements) {
    _statements = statements
  }

  statements { _statements }

  toString {
    return "Block(%(_statements))"
  }
}

class VarStmt is Stmt {
  construct new(name, initializer) {
    _name = name
    _initializer = initializer
  }

  name { _name }
  initializer { _initializer }

  toString {
    return "Var(%(_name) %(_initializer))"
  }
}

class ImportStmt is Stmt {
  construct new(path, variables) {
    _path = path
    _variables = variables
  }

  path { _path }
  variables { _variables }

  toString {
    return "Import(%(_path) %(_variables))"
  }
}

class IfStmt is Stmt {
  construct new(condition, thenBranch, elseBranch) {
    _condition = condition
    _thenBranch = thenBranch
    _elseBranch = elseBranch
  }

  condition { _condition }
  thenBranch { _thenBranch }
  elseBranch { _elseBranch }

  toString {
    return "If(%(_condition) %(_thenBranch) %(_elseBranch))"
  }
}

class BreakStmt is Stmt {
  construct new(keyword) {
    _keyword = keyword
  }

  keyword { _keyword }

  toString {
    return "Break(%(_keyword))"
  }
}

class WhileStmt is Stmt {
  construct new(condition, body) {
    _condition = condition
    _body = body
  }

  condition { _condition }
  body { _body }

  toString {
    return "While(%(_condition) %(_body))"
  }
}

class ClassStmt is Stmt {
  construct new(foreignKeyword, name, superclass, methods) {
    _foreignKeyword = foreignKeyword
    _name = name
    _superclass = superclass
    _methods = methods
  }

  foreignKeyword { _foreignKeyword }
  name { _name }
  superclass { _superclass }
  methods { _methods }

  toString {
    return "Class(%(_foreignKeyword) %(_name) %(_superclass) %(_methods))"
  }
}
