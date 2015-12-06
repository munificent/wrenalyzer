class Token {
  // Punctuators.
  static leftParen { "leftParen" }
  static rightParen { "rightParen" }
  static leftBracket { "leftBracket" }
  static rightBracket { "rightBracket" }
  static leftBrace { "leftBrace" }
  static rightBrace { "rightBrace" }
  static colon { "colon" }
  static dot { "dot" }
  static dotDot { "dotDot" }
  static dotDotDot { "dotDotDot" }
  static comma { "comma" }
  static star { "star" }
  static slash { "slash" }
  static percent { "percent" }
  static plus { "plus" }
  static minus { "minus" }
  static pipe { "pipe" }
  static pipePipe { "pipePipe" }
  static amp { "amp" }
  static ampAmp { "ampAmp" }
  static bang { "bang" }
  static tilde { "tilde" }
  static equal { "equal" }
  static less { "less" }
  static greater { "greater" }
  static lessEqual { "lessEqual" }
  static greaterEqual { "greaterEqual" }
  static equalEqual { "equalEqual" }
  static bangEqual { "bangEqual" }

  // Keywords.
  static breakKeyword { "break" }
  static classKeyword { "class" }
  static elseKeyword { "else" }
  static falseKeyword { "false" }
  static forKeyword { "for" }
  static ifKeyword { "if" }
  static importKeyword { "import" }
  static inKeyword { "in" }
  static isKeyword { "is" }
  static nullKeyword { "null" }
  static returnKeyword { "return" }
  static staticKeyword { "static" }
  static superKeyword { "super" }
  static thisKeyword { "this" }
  static trueKeyword { "true" }
  static varKeyword { "var" }
  static whileKeyword { "while" }

  static field { "field" }
  static staticField { "staticField" }
  static name { "name" }
  static number { "number" }
  static string { "string" }
  static line { "line" }
  static error { "error" }
  static eof { "eof" }

  construct new(type, text) {
    _type = type
    _text = text
  }

  type { _type }
  text { _text }

  toString { "%(_type) '%(_text)'" }
}
