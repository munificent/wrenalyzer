import "lexer" for Lexer
import "parser" for Parser
import "token" for Token

var lexer = Lexer.new("{false: true, ((null)): [_field, __static], {}: this")
var parser = Parser.new(lexer)
var ast = parser.parse()
System.print(ast)
