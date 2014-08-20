class Token {
  new(type, text) {
    _type = type
    _text = text
  }

  type { _type }
  text { _text }

  toString { _text + " " + _type.toString }
}

class TokenType {
  // TODO: Super gross. Better support for static properties or enum-like
  // objects.
  // Punctuators.
  static leftParen    { __leftParen }
  static rightParen   { __rightParen }
  static leftBracket  { __leftBracket }
  static rightBracket { __rightBracket }
  static leftBrace    { __leftBrace }
  static rightBrace   { __rightBrace }
  static colon        { __colon }
  static dot          { __dot }
  static dotDot       { __dotDot }
  static dotDotDot    { __dotDotDot }
  static comma        { __comma }
  static star         { __star }
  static slash        { __slash }
  static percent      { __percent }
  static plus         { __plus }
  static minus        { __minus }
  static pipe         { __pipe }
  static pipePipe     { __pipePipe }
  static amp          { __amp }
  static ampAmp       { __ampAmp }
  static bang         { __bang }
  static tilde        { __tilde }
  static equal        { __equal }
  static less         { __less }
  static greater      { __greater }
  static lessEqual    { __lessEqual }
  static greaterEqual { __greaterEqual }
  static equalEqual   { __equalEqual }
  static bangEqual    { __bangEqual }

  // Keywords.
  static break_       { __break }
  static class_       { __class }
  static else_        { __else }
  static false_       { __false }
  static for_         { __for }
  static if_          { __if }
  static in_          { __in }
  static is_          { __is }
  static new_         { __new }
  static null_        { __null }
  static return_      { __return }
  static static_      { __static }
  static super_       { __super }
  static this_        { __this }
  static true_        { __true }
  static var_         { __var }
  static while_       { __while }

  static name         { __name }
  static string       { __string }

  static error        { __error }

/*
  TOKEN_FIELD,
  TOKEN_STATIC_FIELD,
  TOKEN_NAME,
  TOKEN_NUMBER,
  TOKEN_STRING,

  TOKEN_LINE,

  TOKEN_ERROR,
  TOKEN_EOF*/

  static init {
    __leftParen = new TokenType("leftParen")
    __rightParen = new TokenType("rightParen")
    __leftBracket = new TokenType("leftBracket")
    __rightBracket = new TokenType("rightBracket")
    __leftBrace = new TokenType("leftBrace")
    __rightBrace = new TokenType("rightBrace")
    __colon = new TokenType("colon")
    __dot = new TokenType("dot")
    __dotDot = new TokenType("dotDot")
    __dotDotDot = new TokenType("dotDotDot")
    __comma = new TokenType("comma")
    __star = new TokenType("star")
    __slash = new TokenType("slash")
    __percent = new TokenType("percent")
    __plus = new TokenType("plus")
    __minus = new TokenType("minus")
    __pipe = new TokenType("pipe")
    __pipePipe = new TokenType("pipePipe")
    __amp = new TokenType("amp")
    __ampAmp = new TokenType("ampAmp")
    __bang = new TokenType("bang")
    __tilde = new TokenType("tilde")
    __equal = new TokenType("equal")
    __less = new TokenType("less")
    __greater = new TokenType("greater")
    __lessEqual = new TokenType("lessEqual")
    __greaterEqual = new TokenType("greaterEqual")
    __equalEqual = new TokenType("equalEqual")
    __bangEqual = new TokenType("bangEqual")

    __break = new TokenType("break")
    __class = new TokenType("class")
    __else = new TokenType("else")
    __false = new TokenType("false")
    __for = new TokenType("for")
    __if = new TokenType("if")
    __in = new TokenType("in")
    __is = new TokenType("is")
    __new = new TokenType("new")
    __null = new TokenType("null")
    __return = new TokenType("return")
    __static = new TokenType("static")
    __super = new TokenType("super")
    __this = new TokenType("this")
    __true = new TokenType("true")
    __var = new TokenType("var")
    __while = new TokenType("while")

    __name = new TokenType("name")
    __string = new TokenType("string")
    __error = new TokenType("error")
  }

  new(name) {
    _name = name
  }

  name { _name }
  toString { _name }
}

TokenType.init

class Lexer {
  new(source) {
    _source = source
    _start = 0
    _current = 0
  }

  tokenize {
    return new Fiber {
      while (_current < _source.count) {
        skipSpace

        _start = _current

        // TODO: A map or switch would be nice.
        if (match("(")) {
          makeToken(TokenType.leftParen)
        } else if (match(")")) {
          makeToken(TokenType.rightParen)
        } else if (match("[")) {
          makeToken(TokenType.leftBracket)
        } else if (match("]")) {
          makeToken(TokenType.rightBracket)
        } else if (match("{")) {
          makeToken(TokenType.leftBrace)
        } else if (match("}")) {
          makeToken(TokenType.rightBrace)
        } else if (match(":")) {
          makeToken(TokenType.colon)
        } else if (match(".")) {
          if (match(".")) {
            if (match(".")) {
              makeToken(TokenType.dotDotDot)
            } else {
              makeToken(TokenType.dotDot)
            }
          } else {
            makeToken(TokenType.dot)
          }
        } else if (match(",")) {
          makeToken(TokenType.comma)
        } else if (match("*")) {
          makeToken(TokenType.star)
        } else if (match("/")) {
          makeToken(TokenType.slash)
        } else if (match("%")) {
          makeToken(TokenType.percent)
        } else if (match("+")) {
          makeToken(TokenType.plus)
        } else if (match("-")) {
          makeToken(TokenType.minus)
        } else if (match("|")) {
          if (match("|")) {
            makeToken(TokenType.pipePipe)
          } else {
            makeToken(TokenType.pipe)
          }
        } else if (match("&")) {
          if (match("&")) {
            makeToken(TokenType.ampAmp)
          } else {
            makeToken(TokenType.amp)
          }
        } else if (match("!")) {
          if (match("=")) {
            makeToken(TokenType.bangEqual)
          } else {
            makeToken(TokenType.bang)
          }
        } else if (match("~")) {
          makeToken(TokenType.tilde)
        } else if (match("=")) {
          if (match("=")) {
            makeToken(TokenType.equalEqual)
          } else {
            makeToken(TokenType.equal)
          }
        } else if (match("<")) {
          if (match("=")) {
            makeToken(TokenType.lessEqual)
          } else {
            makeToken(TokenType.less)
          }
        } else if (match(">")) {
          if (match("=")) {
            makeToken(TokenType.greaterEqual)
          } else {
            makeToken(TokenType.greater)
          }
        } else if ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(peek)) {
          // TODO: Better way to compare characters!
          readName
        } else {
          // TODO: Do something better here.
          advance
          makeToken(TokenType.error)
        }
      }
    }
  }

  // Advances past the current character.
  advance {
    _current = _current + 1
  }

  // Gets the current character.
  peek { _source[_current] }

  // Consumes the current character if it is [c].
  match(c) {
    if (_current < _source.count && _source[_current] == c) {
      _current = _current + 1
      return true
    }

    return false
  }

  // Creates a token of [type] from the current character range.
  makeToken(type) {
    // TODO: Substring method.
    var text = ""
    for (i in _start..._current) {
      text = text + _source[i]
    }

    Fiber.yield(new Token(type, text))
  }

  // Skips over whitespace characters.
  skipSpace {
    while (match(" ") || match("\t")) {
      // Already advanced.
    }
  }

  // Reads an identifier or keyword token.
  readName {
    advance
    while (_current < _source.count && "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_0123456789".contains(peek)) {
      advance
    }

    var type = TokenType.name

    // TODO: Unify with makeToken.
    var text = ""
    for (i in _start..._current) {
      text = text + _source[i]
    }

    if (text == "break") {
      type = TokenType.break_
    } else if (text == "class") {
      type = TokenType.class_
    } else if (text == "else") {
      type = TokenType.else_
    } else if (text == "false") {
      type = TokenType.false_
    } else if (text == "for") {
      type = TokenType.for_
    } else if (text == "if") {
      type = TokenType.if_
    } else if (text == "in") {
      type = TokenType.in_
    } else if (text == "is") {
      type = TokenType.is_
    } else if (text == "new") {
      type = TokenType.new_
    } else if (text == "null") {
      type = TokenType.null_
    } else if (text == "return") {
      type = TokenType.return_
    } else if (text == "static") {
      type = TokenType.static_
    } else if (text == "super") {
      type = TokenType.super_
    } else if (text == "this") {
      type = TokenType.this_
    } else if (text == "true") {
      type = TokenType.true_
    } else if (text == "var") {
      type = TokenType.var_
    } else if (text == "while") {
      type = TokenType.while_
    }

    Fiber.yield(new Token(type, text))
  }
}

var s = "()(([ .foo_BAR123:..,... ]%|||&&& {    \t}!~)+-*/=!===<><=>=\n" +
        "break class else false for if in is new null return static super this true var while"

var lexer = new Lexer(s)
var tokens = lexer.tokenize
while (true) {
  var token = tokens.call
  if (tokens.isDone) break
  IO.print(token)
}
