import "lexer" for Lexer
import "parser" for Parser
import "token" for Token

var source = "1 ? 2 : 3 = 4 = 5 ? 6 : 7"
var lexer = Lexer.new(source)
var parser = Parser.new(lexer)
var ast = parser.parse()
System.print(ast)
