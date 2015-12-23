import "ast" for
    AssignmentExpr,
    BoolExpr,
    CallExpr,
    ConditionalExpr,
    FieldExpr,
    GroupingExpr,
    InfixExpr,
    ListExpr,
    MapEntry,
    MapExpr,
    NullExpr,
    NumExpr,
    PrefixExpr,
    StaticFieldExpr,
    SubscriptExpr,
    ThisExpr
import "lexer" for Lexer
import "token" for Token

var EQUALITY_OPERATORS = [
  Token.equalEqual,
  Token.bangEqual
]

var COMPARISON_OPERATORS = [
  Token.less,
  Token.lessEqual,
  Token.greater,
  Token.greaterEqual
]

var BITWISE_SHIFT_OPERATORS = [
  Token.lessLess,
  Token.greaterGreater
]

var RANGE_OPERATORS = [
  Token.dotDot,
  Token.dotDotDot
]

var TERM_OPERATORS = [
  Token.plus,
  Token.minus
]

var FACTOR_OPERATORS = [
  Token.star,
  Token.slash,
  Token.percent
]

var PREFIX_OPERATORS = [
  Token.minus,
  Token.bang,
  Token.tilde
]

class Parser {
  construct new(lexer) {
    _lexer = lexer
    _current = _lexer.readToken()
  }

  parse() {
    // TODO: Statements, definitions.
    var expr = expression()
    consume(Token.eof, "Expect end of input.")
    return expr
  }

  expression() { assignment() }

  // assignment: conditional ( "=" assignment )?
  assignment() {
    // TODO: This allows invalid LHS like "1 + 2 = 3". Decide if we want to
    // handle that here or later in the pipeline.
    var expr = conditional()
    if (!match(Token.equal)) return expr

    var equal = _previous
    var value = assignment()
    return AssignmentExpr.new(expr, equal, value)
  }

  // conditional: logicalOr ( "?" conditional ":" assignment )?
  conditional() {
    var expr = logicalOr()
    if (!match(Token.question)) return expr

    var question = _previous
    var thenBranch = conditional()
    var colon = consume(Token.colon,
        "Expect ':' after then branch of conditional operator.")
    var elseBranch = assignment()
    return ConditionalExpr.new(expr, question, thenBranch, colon, elseBranch)
  }

  // logicalOr: logicalAnd ( "||" logicalAnd )*
  logicalOr() { parseInfix([Token.pipePipe]) { logicalAnd() } }

  // logicalAnd: equality ( "&&" equality )*
  logicalAnd() { parseInfix([Token.ampAmp]) { equality() } }

  // equality: typeTest ( equalityOperator typeTest )*
  // equalityOperator: "==" | "!="
  equality() { parseInfix(EQUALITY_OPERATORS) { typeTest() } }

  // typeTest: comparison ( "is" comparison )*
  typeTest() { parseInfix([Token.isKeyword]) { comparison() } }

  // comparison: bitwiseOr ( comparisonOperator bitwiseOr )*
  // comparisonOperator: "<" | ">" | "<=" | ">="
  comparison() { parseInfix(COMPARISON_OPERATORS) { bitwiseOr() } }

  // bitwiseOr: bitwiseXor ( "|" bitwiseXor )*
  bitwiseOr() { parseInfix([Token.pipe]) { bitwiseXor() } }

  // bitwiseXor: bitwiseAnd ( "^" bitwiseAnd )*
  bitwiseXor() { parseInfix([Token.caret]) { bitwiseAnd() } }

  // bitwiseAnd: bitwiseShift ( "&" bitwiseShift )*
  bitwiseAnd() { parseInfix([Token.amp]) { bitwiseShift() } }

  // bitwiseShift: range ( bitwiseShiftOperator range )*
  // bitwiseShiftOperator: "<<" | ">>"
  bitwiseShift() { parseInfix(BITWISE_SHIFT_OPERATORS) { range() } }

  // range: term ( rangeOperator term )*
  // rangeOperator: ".." | ".."
  range() { parseInfix(RANGE_OPERATORS) { term() } }

  // term: factor ( termOperator factor )*
  // termOperator: "+" | "-"
  term() { parseInfix(TERM_OPERATORS) { factor() } }

  // factor: prefix ( factorOperator prefix )*
  // factorOperator: "*" | "/" | "%"
  factor() { parseInfix(FACTOR_OPERATORS) { prefix() } }

  // prefix: ("-" | "!" | "~")* call
  prefix() {
    if (matchAny(PREFIX_OPERATORS)) {
      return PrefixExpr.new(_previous, prefix())
    }

    return call()
  }

  // call: primary ( subscript | "." methodCall )*
  // subscript: "[" argumentList "]"
  call() {
    var expr = primary()

    while (true) {
      if (match(Token.leftBracket)) {
        var leftBracket = _previous
        var arguments = argumentList()
        var rightBracket = consume(Token.rightBracket,
            "Expect ']' after subscript arguments.")
        expr = SubscriptExpr.new(expr, leftBracket, arguments, rightBracket)
      } else if (match(Token.dot)) {
        expr = methodCall(expr)
      } else {
        break
      }
    }

    return expr
  }

  // Parses a named method call, not including a possible leading receiver and
  // "."
  //
  // methodCall: Name ( "(" argumentList? ")" )? blockArgument?
  // blockArgument: "{" ( "|" parameterList "|" )? body "}"
  // parameterList: Name ( "," Name )*
  // body:
  //   | "\n" ( definition "\n" )*
  //   | expression
  methodCall(receiver) {
    var name = consume(Token.name, "Expect method name after '.'.")

    var arguments
    if (match(Token.leftParen)) {
      // Allow an empty argument list. Note that we treat this differently than
      // a getter (no argument list). The former will have a `null` argument
      // list and the latter will have an empty one.
      if (match(Token.rightParen)) {
        arguments = []
      } else {
        arguments = argumentList()
        consume(Token.rightParen, "Expect ')' after arguments.")
      }
    }

    // TODO: Block argument.
    return CallExpr.new(receiver, name, arguments)
  }

  // argumentList: expression ( "," expression )*
  argumentList() {
    var arguments = []

    while (true) {
      arguments.add(expression())
      if (!match(Token.comma)) break
    }

    return arguments
  }

  // primary:
  //   | grouping
  //   | listLiteral
  //   | mapLiteral
  //   | "true" | "false" | "null" | "this"
  //   | Field | StaticField | Number
  primary() {
    if (match(Token.leftParen))     return grouping()
    if (match(Token.leftBracket))   return listLiteral()
    if (match(Token.leftBrace))     return mapLiteral()

    if (match(Token.falseKeyword))  return BoolExpr.new(_previous)
    if (match(Token.trueKeyword))   return BoolExpr.new(_previous)
    if (match(Token.nullKeyword))   return NullExpr.new(_previous)
    if (match(Token.thisKeyword))   return ThisExpr.new(_previous)

    if (match(Token.field))         return FieldExpr.new(_previous)
    if (match(Token.staticField))   return StaticFieldExpr.new(_previous)

    if (match(Token.number))        return NumExpr.new(_previous)

    // TODO: This parses all bare names as "getter calls". Is that what we want?
    if (peek() == Token.name)       return methodCall(null)
    // TODO: Token.super.
    // TODO: Token.string.
    // TODO: Token.stringInterpolation.

    error("Expected expression.")
    // TODO: Return what? Error Node?
  }

  // Finishes parsing a parenthesized expression.
  //
  // grouping: "(" expressions ")"
  grouping() {
    var leftParen = _previous
    var expr = expression()
    var rightParen = consume(Token.rightParen, "Expect ')' after expression.")
    return GroupingExpr.new(leftParen, expr, rightParen)
  }

  // Finishes parsing a list literal.
  //
  // listLiteral: "[" ( expression ("," expression)* ","? )? "]"
  listLiteral() {
    var leftBracket = _previous
    var elements = []

    while (peek() != Token.rightBracket) {
      elements.add(expression())
      if (!match(Token.comma)) break
    }

    var rightBracket = consume(Token.rightBracket,
        "Expect ']' after list elements.")
    return ListExpr.new(leftBracket, elements, rightBracket)
  }

  // Finishes parsing a map literal.
  //
  // mapLiteral: "[" ( mapEntry ("," mapEntry)* ","? )? "}"
  // mapEntry:   expression ":" expression
  mapLiteral() {
    var leftBrace = _previous
    var entries = []

    while (peek() != Token.rightBrace) {
      var key = expression()
      consume(Token.colon, "Expect ':' after map key.")

      var value = expression()
      entries.add(MapEntry.new(key, value))
      if (!match(Token.comma)) break
    }

    var rightBrace = consume(Token.rightBrace, "Expect '}' after map entries.")
    return MapExpr.new(leftBrace, entries, rightBrace)
  }

  // Utility methods.

  // Parses a left-associative series of infix operator expressions using any
  // of [tokenTypes] as operators and calling [parseOperand] to parse the left
  // and right operands.
  parseInfix(tokenTypes, parseOperand) {
    var expr = parseOperand.call()
    while (matchAny(tokenTypes)) {
      var operator = _previous
      var right = parseOperand.call()
      expr = InfixExpr.new(expr, operator, right)
    }

    return expr
  }

  // If the next token has [type], consumes and returns it. Otherwise, returns
  // `null`.
  match(type) {
    if (peek() != type) return null
    return consume()
  }

  // Consumes and returns the next token if its type is contained in the list
  // [types].
  matchAny(types) {
    for (type in types) {
      var result = match(type)
      if (result) return result
    }

    return null
  }

  // Reads and consumes the next token.
  consume() {
    peek()
    _previous = _current
    _current = null
    return _previous
  }

  // Reads the next token if it is of [type]. Otherwise, discards it and
  // reports an error with [message]
  consume(type, message) {
    var token = consume()
    if (token.type != type) error(message)

    return token
  }

  // Returns the type of the next token.
  peek() {
    if (!_current) _current = _lexer.readToken()
    return _current.type
  }

  error(message) {
    // TODO: Handle this better.
    System.print("Error on %(_previous): %(message)")
  }
}

