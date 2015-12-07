class Node {

}

class Expr is Node {

}

class BoolExpr is Expr {
  construct new(value) {
    _value = value
  }

  toString { "BoolExpr(%(_value))"}
}

class NumberExpr is Expr {
  construct new(value) {
    _value = value
  }
}
