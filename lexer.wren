import "token" for Token

var KEYWORDS = {
  "break": Token.breakKeyword,
  "class": Token.classKeyword,
  "else": Token.elseKeyword,
  "false": Token.falseKeyword,
  "for": Token.forKeyword,
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

var ONE_CHAR_TOKENS = {
  "(": Token.leftParen,
  ")": Token.rightParen,
  "[": Token.leftBracket,
  "]": Token.rightBracket,
  "{": Token.leftBrace,
  "}": Token.rightBrace,
  ":": Token.colon,
  ",": Token.comma,
  "*": Token.star,
  "/": Token.slash,
  "\%": Token.percent,
  "+": Token.plus,
  "-": Token.minus,
  "~": Token.tilde,
}

// Utilities for working with characters.
class Chars {
  static lowerCaseA { 0x61 }
  static lowerCaseZ { 0x7a }
  static upperCaseA { 0x41 }
  static upperCaseZ { 0x5a }
  static underscore { 0x5f }
  static zero { 0x30 }
  static nine { 0x39 }

  static isAlpha(c) {
    return c >= lowerCaseA && c <= lowerCaseZ ||
           c >= upperCaseA && c <= upperCaseZ ||
           c == underscore
  }

  static isAlphaNumeric(c) { c >= zero && c <= nine || isAlpha(c) }
}

class Lexer {
  construct new(source) {
    _source = source

    // TODO: Make this explicitly work on bytes or code points.
    _start = 0
    _current = 0
  }

  tokenize() {
    return Fiber.new {
      while (_current < _source.count) {
        skipSpace()

        _start = _current

        var c = peek
        if (ONE_CHAR_TOKENS.containsKey(c)) {
          advance()
          makeToken(ONE_CHAR_TOKENS[c])
        } else if (match(".")) {
          if (match(".")) {
            if (match(".")) {
              makeToken(Token.dotDotDot)
            } else {
              makeToken(Token.dotDot)
            }
          } else {
            makeToken(Token.dot)
          }
        } else if (match("|")) {
          if (match("|")) {
            makeToken(Token.pipePipe)
          } else {
            makeToken(Token.pipe)
          }
        } else if (match("&")) {
          if (match("&")) {
            makeToken(Token.ampAmp)
          } else {
            makeToken(Token.amp)
          }
        } else if (match("!")) {
          if (match("=")) {
            makeToken(Token.bangEqual)
          } else {
            makeToken(Token.bang)
          }
        } else if (match("=")) {
          if (match("=")) {
            makeToken(Token.equalEqual)
          } else {
            makeToken(Token.equal)
          }
        } else if (match("<")) {
          if (match("=")) {
            makeToken(Token.lessEqual)
          } else {
            makeToken(Token.less)
          }
        } else if (match(">")) {
          if (match("=")) {
            makeToken(Token.greaterEqual)
          } else {
            makeToken(Token.greater)
          }
        } else if (match {|c| Chars.isAlpha(c) }) {
          readName()
        } else {
          // TODO: Do something better here.
          advance()
          makeToken(Token.error)
        }
      }

      _start = _current
      makeToken(Token.eof)
    }
  }

  // Advances past the current character.
  advance() {
    _current = _current + 1
  }

  // Gets the current character.
  peek { _source[_current] }

  // Consumes the current character if it is [c].
  match(c) {
    if (_current >= _source.count) return false

    if (c is String) {
      if (_source[_current] != c) return false
    } else if (c is Fn) {
      if (!c.call(_source.codePoints[_current])) return false
    }

    advance()
    return true
  }

  // Creates a token of [type] from the current character range.
  makeToken(type) {
    System.print("%(_source.count) %(_start) %(_current)")
    Fiber.yield(Token.new(type, _source[_start..._current]))
  }

  // Skips over whitespace characters.
  skipSpace() {
    while (match(" ") || match("\t")) {
      // Already advanced.
    }
  }

  // Reads an identifier or keyword token.
  readName() {
    // Read the rest of the name.
    while (match {|c| Chars.isAlphaNumeric(c) }) {}

    var text = _source[_start..._current]

    var type = Token.name
    if (KEYWORDS.containsKey(text)) {
      type = KEYWORDS[text]
    }

    Fiber.yield(Token.new(type, text))
  }
}
