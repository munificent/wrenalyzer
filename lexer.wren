import "token" for Token

// Utilities for working with characters.
class Chars {
  static tab { 0x09 }
  static space { 0x20 }
  static bang { 0x21 }
  static percent { 0x25 }
  static amp { 0x26 }
  static leftParen { 0x28 }
  static rightParen { 0x29 }
  static star { 0x2a }
  static plus { 0x2b }
  static comma { 0x2c }
  static minus { 0x2d }
  static dot { 0x2e }
  static slash { 0x2f }

  static zero { 0x30 }
  static question { 0x3f }
  static nine { 0x39 }

  static colon { 0x3a }
  static less { 0x3c }
  static equal { 0x3d }
  static greater { 0x3e }
  static question { 0x3f }

  static upperA { 0x41 }
  static upperZ { 0x5a }

  static leftBracket { 0x5b }
  static rightBracket { 0x5d }
  static caret { 0x5e }
  static underscore { 0x5f }

  static lowerA { 0x61 }
  static lowerZ { 0x7a }

  static leftBrace { 0x7b }
  static pipe { 0x7c }
  static rightBrace { 0x7d }
  static tilde { 0x7e }

  static isAlpha(c) {
    return c >= lowerA && c <= lowerZ ||
           c >= upperA && c <= upperZ ||
           c == underscore
  }

  static isDigit(c) { c >= zero && c <= nine }

  static isAlphaNumeric(c) { isAlpha(c) || isDigit(c) }
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

  Chars.pipe: [Token.pipe, Chars.pipe, Token.pipePipe],
  Chars.amp: [Token.amp, Chars.amp, Token.ampAmp],
  Chars.bang: [Token.bang, Chars.equal, Token.bangEqual],
  Chars.equal: [Token.equal, Chars.equal, Token.equalEqual],

  Chars.dot: [Token.dot, Chars.dot, Token.dotDot, Chars.dot, Token.dotDotDot]
}

class Lexer {
  construct new(source) {
    // Due to the magic of UTF-8, we can safely treat Wren source as a series
    // of bytes, since the only code points that are meaningful to Wren fit in
    // ASCII. The only place where non-ASCII code points can occur is inside
    // string literals and comments and the lexer will treat those as opaque
    // bytes safely.
    _source = source
    _bytes = source.bytes
    _start = 0
    _current = 0
  }

  nextToken() {
    if (_current >= _bytes.count) return makeToken(Token.eof)

    skipWhitespace()

    // TODO: Skip comments.

    _start = _current
    var c = _bytes[_start]
    advance()

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

    if (Chars.isDigit(c)) return readNumber()
    if (Chars.isAlpha(c)) return readName()

    // TODO: Strings.

    return makeToken(Token.error)
  }

  // Advances past the current character.
  advance() {
    _current = _current + 1
  }

  // Consumes the current character if it matches [condition], which can be a
  // numeric code point value or a function that takes a code point and returns
  // `true` if the code point matches.
  match(condition) {
    if (_current >= _bytes.count) return false

    var c = _bytes[_current]
    if (condition is Fn) {
      if (!condition.call(c)) return false
    } else if (c != condition) {
      return false
    }

    advance()
    return true
  }

  // Creates a token of [type] from the current character range.
  makeToken(type) { Token.new(type, _source[_start..._current]) }

  // Skips over whitespace characters.
  skipWhitespace() {
    while (match(Chars.space) || match(Chars.tab)) {
      // Already advanced.
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

  // Reads a number literal.
  readNumber() {
    // Read the rest of the name.
    while (match {|c| Chars.isDigit(c) }) {}

    // TODO: Hex, floating point, scientific.

    return makeToken(Token.number)
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

    return Token.new(type, text)
  }
}
