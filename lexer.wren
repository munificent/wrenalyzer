import "token" for Token

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
    // TODO: Should probably standardize on using code points everywhere.
    if (c is String) c = c.codePoints[0]
    return c >= lowerCaseA && c <= lowerCaseZ ||
           c >= upperCaseA && c <= upperCaseZ ||
           c == underscore
  }

  static isAlphaNumeric(c) { c >= zero && c <= nine || isAlpha(c) }
}

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

// Data table for tokens that are tokenized using maximal munch.
//
// The key is the character that starts the token or tokens. After that is a
// list of token types and characters. As long as the next character is matched,
// the type will update to the type after that character.
var PUNCTUATORS = {
  "(": [Token.leftParen],
  ")": [Token.rightParen],
  "[": [Token.leftBracket],
  "]": [Token.rightBracket],
  "{": [Token.leftBrace],
  "}": [Token.rightBrace],
  ":": [Token.colon],
  ",": [Token.comma],
  "*": [Token.star],
  "/": [Token.slash],
  "\%": [Token.percent],
  "+": [Token.plus],
  "-": [Token.minus],
  "~": [Token.tilde],

  "|": [Token.pipe, "|", Token.pipePipe],
  "&": [Token.amp, "&", Token.ampAmp],
  "!": [Token.bang, "=", Token.bangEqual],
  "=": [Token.equal, "=", Token.equalEqual],
  "<": [Token.less, "=", Token.lessEqual],
  ">": [Token.greater, "=", Token.greaterEqual],

  ".": [Token.dot, ".", Token.dotDot, ".", Token.dotDotDot]
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
        skipWhitespace()

        _start = _current

        advance()
        var c = _source[_current]
        if (PUNCTUATORS.containsKey(c)) {
          var punctuator = PUNCTUATORS[c]
          var type = punctuator[0]
          var i = 1
          while (i < punctuator.count) {
            if (!match(punctuator[i])) break
            type = punctuator[i + 1]
            i = i + 2
          }

          makeToken(type)
        } else if (Chars.isAlpha(c.codePoints[0])) {
          readName()
        } else {
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
    Fiber.yield(Token.new(type, _source[_start..._current]))
  }

  // Skips over whitespace characters.
  skipWhitespace() {
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
