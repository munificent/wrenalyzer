import "ast" for
    AssignmentExpr,
    BlockStmt,
    BoolExpr,
    BreakStmt,
    CallExpr,
    ClassStmt,
    ConditionalExpr,
    FieldExpr,
    ForStmt,
    GroupingExpr,
    IfStmt,
    ImportStmt,
    InfixExpr,
    InterpolationExpr,
    ListExpr,
    MapEntry,
    MapExpr,
    Method,
    Module,
    NullExpr,
    NumExpr,
    PrefixExpr,
    ReturnStmt,
    StaticFieldExpr,
    StringExpr,
    SubscriptExpr,
    ThisExpr,
    VarStmt,
    WhileStmt
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

  parseModule() {
    ignoreLine()

    var statements = []
    while (peek() != Token.eof) {
      statements.add(definition())
      if (!matchLine()) break
    }

    consume(Token.eof, "Expect end of input.")
    return Module.new(statements)
  }

  definition() {
    if (match(Token.classKeyword)) {
      return finishClass(null)
    }

    if (match(Token.foreignKeyword)) {
      var foreignKeyword = _previous
      consume(Token.classKeyword, "Expect 'class' after 'foreign'.")
      return finishClass(foreignKeyword)
    }

    if (match(Token.importKeyword)) {
      var path = consume(Token.string, "Expect import path.")
      var variables

      // Parse the variable list, if there is one.
      if (match(Token.forKeyword)) {
        ignoreLine()

        variables = []
        while (true) {
          var name = consume(Token.name, "Expect variable name.")
          variables.add(name)
          if (!match(Token.comma)) break
          ignoreLine()
        }
      }

      return ImportStmt.new(path, variables)
    }

    if (match(Token.varKeyword)) {
      var name = consume(Token.name, "Expect variable name.")
      var initializer
      if (match(Token.equal)) {
        initializer = expression()
      }

      return VarStmt.new(name, initializer)
    }

    return statement()
  }

  // Parses the rest of a class definition after the "class" token.
  finishClass(foreignKeyword) {
    var name = consume(Token.name, "Expect class name.")

    var superclass
    if (match(Token.isKeyword)) {
      // TODO: This is different from the VM (which is wrong). Need to make
      // sure we don't parse the class body as a block argument.
      superclass = consume(Token.name, "Expect name of superclass.")
    }

    var methods = []
    consume(Token.leftBrace, "Expect '{' after class name.")
    ignoreLine()

    while (!match(Token.rightBrace) && peek() != Token.eof) {
      methods.add(method())

      // Don't require a newline after the last definition.
      if (match(Token.rightBrace)) break

      consumeLine("Expect newline after definition in class.")
    }

    return ClassStmt.new(foreignKeyword, name, superclass, methods)
  }

  method() {
    // TODO: Foreign methods.
    // Note: This parses more permissively than the grammar actually is. For
    // example, it will allow "static construct *()". We'll report errors on
    // invalid forms later.
    var staticKeyword
    if (match(Token.staticKeyword)) {
      staticKeyword = _previous
    }

    var constructKeyword
    if (match(Token.constructKeyword)) {
      constructKeyword = _previous
    }

    // TODO: Error if both "static" and "construct" are present.

    var name
    var parameters

    // TODO: Other operators.
    if (match(Token.leftBracket)) {
      // Subscript operator.
      parameters = parameterList()
      consume(Token.rightBracket, "Expect ']' after parameters.")
      // TODO: Subscript setter.
    } else {
      name = consume(Token.name, "Expect method name.")

      if (match(Token.leftParen)) {
        ignoreLine()
        if (!match(Token.rightParen)) {
          parameters = parameterList()
          ignoreLine()
          consume(Token.rightParen, "Expect ')' after parameters.")
        }
      }
    }

    // TODO: Setters.

    consume(Token.leftBrace, "Expect '{' before method body.")
    var body = finishBlock()
    return Method.new(staticKeyword, constructKeyword, name, parameters, body)
  }

  statement() {
    if (match(Token.breakKeyword)) {
      return BreakStmt.new(_previous)
    }

    if (match(Token.ifKeyword)) {
      consume(Token.leftParen, "Expect '(' after 'if'.")
      ignoreLine()
      var condition = expression()
      consume(Token.rightParen, "Expect ')' after if condition.")
      var thenBranch = block()
      var elseBranch
      if (match(Token.elseKeyword)) {
        elseBranch = block()
      }
      return IfStmt.new(condition, thenBranch, elseBranch)
    }

    if (match(Token.forKeyword)) {
      consume(Token.leftParen, "Expect '(' after 'for'.")
      var variable = consume(Token.name, "Expect for loop variable name.")
      consume(Token.inKeyword, "Expect 'in' after loop variable.")
      ignoreLine()
      var iterator = expression()
      consume(Token.rightParen, "Expect ')' after loop expression.")
      var body = block()
      return ForStmt.new(variable, iterator, body)
    }

    if (match(Token.returnKeyword)) {
      var keyword = _previous
      var value
      if (peek() != Token.line) {
        value = expression()
      }

      return ReturnStmt.new(keyword, value)
    }

    if (match(Token.whileKeyword)) {
      consume(Token.leftParen, "Expect '(' after 'while'.")
      ignoreLine()
      var condition = expression()
      consume(Token.rightParen, "Expect ')' after while condition.")
      var body = block()
      return WhileStmt.new(condition, body)
    }

    // TODO: for, if, while.
    return expression()
  }

  // Parses a curly block or an expression statement. Used in places like the
  // arms of an if statement where either a single expression or a curly body
  // is allowed.
  block() {
    // Curly block.
    if (match(Token.leftBrace)) return finishBlock()

    // Single statement body.
    return statement()
  }

  // Parses the rest of a curly-braced block after the "{" has been consumed.
  finishBlock() {
    // An empty block.
    if (match(Token.rightBrace)) return BlockStmt.new([])

    // If there's no line after the "{", it's a single-expression body.
    if (!matchLine()) {
      var expr = expression()
      ignoreLine()
      consume(Token.rightBrace, "Expect '}' at end of block.")
      return expr
    }

    // Empty blocks (with just a newline inside) do nothing.
    if (match(Token.rightBrace)) return BlockStmt.new([])

    var statements = []
    while (peek() != Token.eof) {
      statements.add(definition())
      consumeLine("Expect newline after statement.")

      if (match(Token.rightBrace)) break
    }

    return BlockStmt.new(statements)
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

    var blockParameters
    var blockBody
    if (match(Token.leftBrace)) {
      if (match(Token.pipe)) {
        blockParameters = parameterList()
        consume(Token.pipe, "Expect '|' after block parameters.")
      }

      blockBody = finishBlock()
    }

    // TODO: Block argument.
    return CallExpr.new(receiver, name, arguments, blockParameters, blockBody)
  }

  // argumentList: expression ( "," expression )*
  argumentList() {
    var arguments = []

    ignoreLine()
    while (true) {
      arguments.add(expression())
      if (!match(Token.comma)) break
      ignoreLine()
    }

    return arguments
  }

  // parameterList: name ( "," name )*
  parameterList() {
    var parameters = []

    while (true) {
      parameters.add(consume(Token.name, "Expect parameter name."))
      if (!match(Token.comma)) break
      ignoreLine()
    }

    return parameters
  }

  // primary:
  //   | grouping
  //   | listLiteral
  //   | mapLiteral
  //   | "true" | "false" | "null" | "this"
  //   | Field | StaticField | Number
  primary() {
    if (match(Token.leftParen))         return grouping()
    if (match(Token.leftBracket))       return listLiteral()
    if (match(Token.leftBrace))         return mapLiteral()

    if (match(Token.falseKeyword))      return BoolExpr.new(_previous)
    if (match(Token.trueKeyword))       return BoolExpr.new(_previous)
    if (match(Token.nullKeyword))       return NullExpr.new(_previous)
    if (match(Token.thisKeyword))       return ThisExpr.new(_previous)

    if (match(Token.field))             return FieldExpr.new(_previous)
    if (match(Token.staticField))       return StaticFieldExpr.new(_previous)

    if (match(Token.number))            return NumExpr.new(_previous)
    if (match(Token.string))            return StringExpr.new(_previous)

    if (peek() == Token.interpolation)  return stringInterpolation()

    // TODO: This parses all bare names as "getter calls". Is that what we want?
    if (peek() == Token.name)           return methodCall(null)
    // TODO: Token.super.

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

    ignoreLine()

    while (peek() != Token.rightBracket) {
      elements.add(expression())

      ignoreLine()
      if (!match(Token.comma)) break
      ignoreLine()
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

    ignoreLine()

    while (peek() != Token.rightBrace) {
      var key = expression()
      consume(Token.colon, "Expect ':' after map key.")

      var value = expression()
      entries.add(MapEntry.new(key, value))

      ignoreLine()
      if (!match(Token.comma)) break
      ignoreLine()
    }

    var rightBrace = consume(Token.rightBrace, "Expect '}' after map entries.")
    return MapExpr.new(leftBrace, entries, rightBrace)
  }

  // stringInterpolation: (interpolation expression )? string
  stringInterpolation() {
    var strings = []
    var expressions = []

    while (match(Token.interpolation)) {
      strings.add(_previous)
      expressions.add(expression())
    }

    // This error should never be reported. It's the lexer's job to ensure we
    // generate the right token sequence.
    strings.add(consume(Token.string, "Expect end of string interpolation."))

    return InterpolationExpr.new(strings, expressions)
  }

  // Utility methods.

  // Parses a left-associative series of infix operator expressions using any
  // of [tokenTypes] as operators and calling [parseOperand] to parse the left
  // and right operands.
  parseInfix(tokenTypes, parseOperand) {
    var expr = parseOperand.call()
    while (matchAny(tokenTypes)) {
      var operator = _previous
      ignoreLine()
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

  // Consumes zero or more newlines. Returns `true` if at least one was matched.
  matchLine() {
    if (!match(Token.line)) return false
    while (match(Token.line)) {
      // Do nothing.
    }

    return true
  }

  // Same as [matchLine()], but makes it clear that the intent is to discard
  // newlines appearing where this is called.
  ignoreLine() { matchLine() }

  // Consumes one or more newlines.
  consumeLine(error) {
    consume(Token.line, error)
    ignoreLine()
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
    if (_current == null) _current = _lexer.readToken()
    return _current.type
  }

  error(message) {
    var token = _current != null ? _current : _previous

    var red = "\x1b[31m"
    var cyan = "\x1b[36m"
    var gray = "\x1b[30;1m"
    var normal = "\x1b[0m"

    // TODO: Move this functionality somewhere better so we can use it for
    // other errors.
    var source = token.source
    System.print("[%(source.path) %(token.lineStart):%(token.columnStart)] " +
        "%(red)Error:%(normal) %(message) (%(token.type))")

    var line = source.getLine(token.lineStart)
    if (token.type == Token.line) {
      // The newline is the error, so make it visible.
      System.print("%(line)%(gray)\\n%(normal)")
      System.print("%(repeat_(" ", line.count))%(red)^^%(normal)")
    } else {
      System.print(line)

      var space = repeat_(" ", token.columnStart - 1)
      var highlight = "^"
      var length = token.columnEnd - token.columnStart
      if (length > 1) {
        highlight = "^" + repeat_("-", length - 2) + "^"
      }
      System.print("%(space)%(red)%(highlight)%(normal)")
    }
  }

  // TODO: Make this a "*" method on String.
  repeat_(string, count) {
    if (count == 0) return ""
    return (1..count).map { string }.join()
  }
}
