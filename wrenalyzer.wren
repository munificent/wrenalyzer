import "io" for Directory, File
import "process" for Process

import "lexer" for Lexer
import "parser" for Parser
import "reporter" for JsonReporter, PrettyReporter
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

    var parser = Parser.new(lexer, _reporter)
    var ast = parser.parseModule()

    var resolver = Resolver.new(_reporter)
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

  run(arguments) {
    if (arguments.count > 0 && arguments[0] == "--json") {
      _reporter = JsonReporter.new()
      arguments.removeAt(0)
    } else {
      _reporter = PrettyReporter.new()
    }

    if (arguments.count != 1) {
      System.print("Usage: wrenalyzer [--json] <source file>")
      return
    }

    var path = arguments[0]
    if (Directory.exists(path)) {
      processDirectory(path)
    } else {
      parseFile(path)
    }
  }
}

Wrenalyzer.new().run(Process.arguments)
