import "lexer" for Lexer

var s = "()(([ .foo_BAR123:..,... ]\%|||&&& {    \t}!~)+-*/=!===<><=>=\n" +
        "break class else false for if import in is null return static super this true var while"

var lexer = Lexer.new(s)
var tokens = lexer.tokenize()
while (true) {
  var token = tokens.call()
  if (tokens.isDone) break
  System.print(token)
}
