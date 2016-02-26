import "chars" for Chars
import "token" for Token

var KEYWORDS = {
  "break": Token.breakKeyword,
  "class": Token.classKeyword,
  "construct": Token.constructKeyword,
  "else": Token.elseKeyword,
  "false": Token.falseKeyword,
  "for": Token.forKeyword,
  "foreign": Token.foreignKeyword,
  "if": Token.ifKeyword,
  "import": Token.importKeyword,
  "in": Token.inKeyword,
  "is": Token.isKeyword,
  "null": Token.nullKeyword,
  "return": Token.returnKeyword,
  "static": Token.staticKeyword,
  "super": Token.superKeyword,
  "this": Token.thisKeyword,
  "true": Token.trueKeyword,
  "var": Token.varKeyword,
  "while": Token.whileKeyword
}

// Data table for tokens that are tokenized using maximal munch.
//
// The key is the character that starts the token or tokens. After that is a
// list of token types and characters. As long as the next character is matched,
// the type will update to the type after that character.
var PUNCTUATORS = {
  Chars.leftParen: [Token.leftParen],
  Chars.rightParen: [Token.rightParen],
  Chars.leftBracket: [Token.leftBracket],
  Chars.rightBracket: [Token.rightBracket],
  Chars.leftBrace: [Token.leftBrace],
  Chars.rightBrace: [Token.rightBrace],
  Chars.colon: [Token.colon],
  Chars.comma: [Token.comma],
  Chars.star: [Token.star],
  Chars.slash: [Token.slash],
  Chars.percent: [Token.percent],
  Chars.plus: [Token.plus],
  Chars.minus: [Token.minus],
  Chars.tilde: [Token.tilde],
  Chars.caret: [Token.caret],
  Chars.question: [Token.question],
  Chars.lineFeed: [Token.line],

  Chars.pipe: [Token.pipe, Chars.pipe, Token.pipePipe],
  Chars.amp: [Token.amp, Chars.amp, Token.ampAmp],
  Chars.bang: [Token.bang, Chars.equal, Token.bangEqual],
  Chars.equal: [Token.equal, Chars.equal, Token.equalEqual],

  Chars.dot: [Token.dot, Chars.dot, Token.dotDot, Chars.dot, Token.dotDotDot]
}

class Lexer {
  construct new(source) {
    _source = source
    _start = 0
    _current = 0

    // The stack of ongoing interpolated strings. Each element in the list is
    // a single level of interpolation nesting. The value of the element is the
    // number of unbalanced "(" still remaining to be closed.
    _interpolations = []
  }

  readToken() {
    if (_current >= _source.count) return makeToken(Token.eof)

    skipWhitespace()

    // TODO: Skip comments.

    _start = _current
    var c = _source[_current]
    advance()

    if (!_interpolations.isEmpty) {
      if (c == Chars.leftParen) {
        _interpolations[-1] = _interpolations[-1] + 1
      } else if (c == Chars.rightParen) {
        _interpolations[-1] = _interpolations[-1] - 1

        // The last ")" in an interpolated expression ends the expression and
        // resumes the string.
        if (_interpolations[-1] == 0) {
          // This is the final ")", so the interpolation expression has ended.
          // This ")" now begins the next section of the template string.
          _interpolations.removeAt(-1)
          return readString()
        }
      }
    }

    if (PUNCTUATORS.containsKey(c)) {
      var punctuator = PUNCTUATORS[c]
      var type = punctuator[0]
      var i = 1
      while (i < punctuator.count) {
        if (!match(punctuator[i])) break
        type = punctuator[i + 1]
        i = i + 2
      }

      return makeToken(type)
    }

    // Handle "<", "<<", and "<=".
    if (c == Chars.less) {
      if (match(Chars.less)) return makeToken(Token.lessLess)
      if (match(Chars.equal)) return makeToken(Token.lessEqual)
      return makeToken(Token.less)
    }

    // Handle ">", ">>", and ">=".
    if (c == Chars.greater) {
      if (match(Chars.greater)) return makeToken(Token.greaterGreater)
      if (match(Chars.equal)) return makeToken(Token.greaterEqual)
      return makeToken(Token.greater)
    }

    if (c == Chars.underscore) return readField()
    if (c == Chars.quote) return readString()

    if (c == Chars.zero && peek() == Chars.lowerX) return readHexNumber()
    if (Chars.isDigit(c)) return readNumber()
    if (Chars.isAlpha(c)) return readName()

    return makeToken(Token.error)
  }

  // Skips over whitespace and comments.
  skipWhitespace() {
    while (true) {
      var c = peek()
      if (c == Chars.tab || c == Chars.carriageReturn || c == Chars.space) {
        // Whitespace is ignored.
        advance()
      } else if (c == Chars.slash && peek(1) == Chars.slash) {
        // A line comment stops at the newline since newlines are significant.
        while (peek() != Chars.lineFeed && !isAtEnd) {
          advance()
        }
      } else if (c == Chars.slash && peek(1) == Chars.star) {
        advance()
        advance()

        // Block comments can nest.
        var nesting = 1
        while (nesting > 0) {
          // TODO: Report error.
          if (isAtEnd) return

          if (peek() == Chars.slash && peek(1) == Chars.star) {
            advance()
            advance()
            nesting = nesting + 1
          } else if (peek() == Chars.star && peek(1) == Chars.slash) {
            advance()
            advance()
            nesting = nesting - 1
            if (nesting == 0) break
          } else {
            advance()
          }
        }
      } else {
        break
      }
    }
  }

  // Reads a static or instance field.
  readField() {
    var type = Token.field
    if (match(Chars.underscore)) type = Token.staticField

    // Read the rest of the name.
    while (match {|c| Chars.isAlphaNumeric(c) }) {}

    return makeToken(type)
  }

  // Reads a string literal.
  readString() {
    var type = Token.string

    while (_current < _source.count - 1) {
      var c = _source[_current]
      advance()

      if (c == Chars.backslash) {
        // TODO: Process specific escapes and validate them.
        advance()
      } else if (c == Chars.percent) {
        // Consume the '('.
        advance()
        // TODO: Handle missing '('.
        _interpolations.add(1)
        type = Token.interpolation
        break
      } else if (c == Chars.quote) {
        break
      }
    }

    // TODO: Handle unterminated string.

    return makeToken(type)
  }

  // Reads a number literal.
  readHexNumber() {
    // Skip past the `x`.
    advance()

    // Read the rest of the number.
    while (match {|c| Chars.isHexDigit(c) }) {}
    return makeToken(Token.number)
  }

  // Reads a number literal.
  readNumber() {
    // Read the rest of the number.
    while (match {|c| Chars.isDigit(c) }) {}

    // TODO: Floating point, scientific.
    return makeToken(Token.number)
  }

  // Reads an identifier or keyword token.
  readName() {
    // Read the rest of the name.
    while (match {|c| Chars.isAlphaNumeric(c) }) {}

    var text = _source.substring(_start, _current - _start)
    var type = Token.name
    if (KEYWORDS.containsKey(text)) {
      type = KEYWORDS[text]
    }

    return Token.new(_source, type, _start, _current - _start)
  }

  // Returns `true` if we have scanned all characters.
  isAtEnd { _current >= _source.count }

  // Advances past the current character.
  advance() {
    _current = _current + 1
  }

  // Returns the byte value of the current character.
  peek() { peek(0) }

  // Returns the byte value of the character [n] bytes past the current
  // character.
  peek(n) {
    if (_current + n >= _source.count) return -1
    return _source[_current + n]
  }

  // Consumes the current character if it matches [condition], which can be a
  // numeric code point value or a function that takes a code point and returns
  // `true` if the code point matches.
  match(condition) {
    if (isAtEnd) return false

    var c = _source[_current]
    if (condition is Fn) {
      if (!condition.call(c)) return false
    } else if (c != condition) {
      return false
    }

    advance()
    return true
  }

  // Creates a token of [type] from the current character range.
  makeToken(type) { Token.new(_source, type, _start, _current - _start) }
}
