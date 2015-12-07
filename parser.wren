import "ast" for BoolExpr, NumberExpr
import "lexer" for Lexer
import "token" for Token

class Parser {
  construct new(lexer) {
    _lexer = lexer

    _prefixParsers = {}
    prefix(Token.falseKeyword) { BoolExpr.new(false) }
    prefix(Token.trueKeyword) { BoolExpr.new(true) }
  }

  parse() {
    // TODO: Statements, definitions.
    return expression()
  }

  expression() {
    // TODO: Make precedence table.
    return parsePrecedence(0)
  }

  parsePrecedence(precedence) {
    var token = consume()

    var prefixParser = _prefixParsers[token.type]
    if (prefixParser == null) {
      // TODO: Better error reporting.
      System.print("could not parse %(token)")
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

  // Reads and consumes the next token.
  consume() { _lexer.nextToken() }

  prefix(tokenType, fn) {
    _prefixParsers[tokenType] = fn
  }
}
