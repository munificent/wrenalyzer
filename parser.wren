import "ast" for
    BoolExpr,
    FieldExpr,
    GroupingExpr,
    ListExpr,
    MapEntry,
    MapExpr,
    NullExpr,
    NumberExpr,
    StaticFieldExpr,
    ThisExpr
import "lexer" for Lexer
import "token" for Token

class Parser {
  construct new(lexer) {
    _lexer = lexer
    _lookAhead = []

    _prefixParsers = {}
    prefix(Token.leftParen)     {|token| grouping(token) }
    prefix(Token.leftBracket)   {|token| listLiteral(token) }
    prefix(Token.leftBrace)     {|token| mapLiteral(token) }
    //      /* TOKEN_MINUS         */ OPERATOR("-"),
    //      /* TOKEN_BANG          */ PREFIX_OPERATOR("!"),
    //      /* TOKEN_TILDE         */ PREFIX_OPERATOR("~"),
    prefix(Token.falseKeyword)  {|token| BoolExpr.new(token) }
    prefix(Token.nullKeyword)   {|token| NullExpr.new(token) }
    //      /* TOKEN_SUPER         */ PREFIX(super_),
    prefix(Token.thisKeyword)   {|token| ThisExpr.new(token) }
    prefix(Token.trueKeyword)   {|token| BoolExpr.new(token) }
    prefix(Token.field)         {|token| FieldExpr.new(token) }
    prefix(Token.staticField)   {|token| StaticFieldExpr.new(token) }
    //      /* TOKEN_NAME          */ { name, NULL, namedSignature, PREC_NONE, NULL },
    //      /* TOKEN_NUMBER        */ PREFIX(literal),
    //      /* TOKEN_STRING        */ PREFIX(literal),
    //      /* TOKEN_INTERPOLATION */ PREFIX(stringInterpolation),
  }

  parse() {
    // TODO: Statements, definitions.
    return expression()
  }

  expression() {
    // TODO: Make precedence table.
    return parsePrecedence(0)
  }

  // Prefix expressions.

  // Finishes parsing a parenthesized expression.
  grouping(leftParen) {
    var expr = expression()
    var rightParen = consume(Token.rightParen, "Expect ')' after expression.")
    return GroupingExpr.new(leftParen, expr, rightParen)
  }

  // Finishes parsing a list literal.
  listLiteral(leftBracket) {
    var elements = []

    if (peek() != Token.rightBracket) {
      while (true) {
        elements.add(expression())
        if (!match(Token.comma)) break
      }
    }

    var rightBracket = consume(Token.rightBracket,
        "Expect ']' after list elements.")
    return ListExpr.new(leftBracket, elements, rightBracket)
  }

  // Finishes parsing a map literal.
  mapLiteral(leftBrace) {
    var entries = []

    if (peek() != Token.rightBrace) {
      while (true) {
        var key = parsePrecedence(0) // TODO: PREC_PRIMARY.
        consume(Token.colon, "Expect ':' after map key.")

        var value = expression()
        entries.add(MapEntry.new(key, value))
        if (!match(Token.comma)) break
      }
    }

    var rightBrace = consume(Token.rightBrace, "Expect '}' after map entries.")
    return MapExpr.new(leftBrace, entries, rightBrace)
  }

  // Utility methods.

  parsePrecedence(precedence) {
    var token = consume()

    var prefixParser = _prefixParsers[token.type]
    if (prefixParser == null) {
      error("Could not parse %(token).")
      // TODO: What do we do now?
    }

    var expr = prefixParser.call(token)

    // TODO: Parse infix.
    /*
    while (precedence < getPrecedence()) {
      token = consume();

      InfixParselet infix = mInfixParselets.get(token.getType());
      left = infix.parse(this, left, token);
    }
    */

    return expr
  }

  // If the next token has [type], consumes and returns it. Otherwise, returns
  // `null`.
  match(type) {
    if (peek() != type) return null

    return consume()
  }

  // Reads and consumes the next token.
  consume() {
    peek()
    return _lookAhead.removeAt(0)
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
    if (_lookAhead.isEmpty) {
      _lookAhead.add(_lexer.nextToken())
    }

    return _lookAhead[-1].type
  }

  error(message) {
    // TODO: Handle this better.
    System.print(message)
  }

  prefix(tokenType, fn) {
    _prefixParsers[tokenType] = fn
  }
}

