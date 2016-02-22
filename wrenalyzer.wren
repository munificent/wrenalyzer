import "io" for File
import "process" for Process

import "lexer" for Lexer
import "parser" for Parser
import "token" for Token

if (Process.arguments.count != 1) {
  System.print("Usage: wrenalyzer <source file>")
} else {
  var source = File.read(Process.arguments[0])
  var lexer = Lexer.new(source)
  var parser = Parser.new(lexer)
  var ast = parser.parseModule()
  System.print(ast)
}
