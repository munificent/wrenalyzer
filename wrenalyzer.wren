import "io" for Directory, File
import "process" for Process

import "lexer" for Lexer
import "parser" for Parser
import "reporter" for Reporter
import "resolver" for Resolver
import "source_file" for SourceFile
import "token" for Token

class Wrenalyzer {
  construct new () {}

  parseFile(path) {
//    System.print("Parsing %(path)")
    var code = File.read(path)
    var source = SourceFile.new(path, code)
    var lexer = Lexer.new(source)

//    while (true) {
//      var token = lexer.readToken()
//      System.print("%(token.type) '%(token.text)'")
//      if (token.type == Token.eof) break
//    }

    var reporter = Reporter.new()
    var parser = Parser.new(lexer, reporter)
    var ast = parser.parseModule()

    var resolver = Resolver.new(reporter)
    resolver.resolve(ast)

    //System.print(ast)
  }

  processDirectory(path) {
    for (entry in Directory.list(path)) {
      if (entry.endsWith(".wren") && File.exists(entry)) {
        parseFile(entry)
      }
    }
  }

  run(path) {
    if (Directory.exists(path)) {
      processDirectory(path)
    } else {
      parseFile(path)
    }
  }
}

if (Process.arguments.count != 1) {
  System.print("Usage: wrenalyzer <source file>")
} else {
  Wrenalyzer.new().run(Process.arguments[0])
}
