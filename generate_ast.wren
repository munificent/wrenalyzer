import "io" for File

// Generates the boilerplate-y "ast.wren" file from a short description of the
// data stored in each AST node. This makes it much easier to add or change AST
// classes.

// TODO: Eventually want to store references to every relevant token in the AST
// nodes. Right now they have some, but not all.
var EXPRS = {
  "Assignment": ["target", "equal", "value"],
  "Bool": ["value"],
  "Call": ["receiver", "name", "arguments"],
  "Conditional": ["condition", "question", "thenBranch", "colon", "elseBranch"],
  "Field": ["name"],
  "Grouping": ["leftParen", "expression", "rightParen"],
  "Infix": ["left", "operator", "right"],
  "List": ["leftBracket", "elements", "rightBracket"],
  "Map": ["leftBrace", "entries", "rightBrace"],
  "Null": ["value"],
  "Num": ["value"],
  "Prefix": ["operator", "right"],
  "StaticField": ["name"],
  "Subscript": ["receiver", "leftBracket", "arguments", "rightBracket"],
  "This": ["keyword"]
}

var STMTS = {
  "Break": ["keyword"],
  "Class": ["foreignKeyword", "name", "superclass", "methods"],
  "For": ["variable", "iterator", "body"],
  "If": ["condition", "thenBranch", "elseBranch"],
  "Import": ["path", "variables"],
  "Return": ["keyword", "value"],
  "While": ["condition", "body"],
  "Var": ["name", "initializer"],
}

class AstBuilder {
  construct new() {}

  build() {
    _file = File.create("ast.wren")

    writeLine("class Node {}")
    writeLine()
    writeLine("class Expr is Node {}")
    writeLine()
    writeLine("class Stmt is Node {}")
    writeLine()
    writeLine("class Module is Node {")
    writeLine("  construct new(statements) {")
    writeLine("    _statements = statements")
    writeLine("  }")
    writeLine()
    writeLine("  statements { _statements }")
    writeLine()
    writeLine("  toString { \"Module(\%(_statements))\" }")
    writeLine("}")
    writeLine()
    writeLine("class MapEntry {")
    writeLine("  construct new(key, value) {")
    writeLine("    _key = key")
    writeLine("    _value = value")
    writeLine("  }")
    writeLine()
    writeLine("  key { _key }")
    writeLine("  value { _value }")
    writeLine()
    writeLine("  toString { \"\%(_key): \%(_value)\" }")
    writeLine("}")

    writeClasses(EXPRS, "Expr")
    writeClasses(STMTS, "Stmt")

    _file.close()
  }

  writeClasses(classes, superclass) {
    for (name in classes.keys) {
      var fields = classes[name]
      var params = fields.join(", ")
      writeLine()
      writeLine("class %(name)%(superclass) is %(superclass) {")
      writeLine("  construct new(%(params)) {")

      for (field in fields) {
        writeLine("    _%(field) = %(field)")
      }

      writeLine("  }")
      writeLine()

      for (field in fields) {
        writeLine("  %(field) { _%(field) }")
      }

      // TODO: Visitor interface.

      writeLine()
      writeLine("  toString {")
      var interpolation = fields.map {|field| "\%(_%(field))"}.join(" ")
      writeLine("    return \"%(name)(%(interpolation))\"")
      writeLine("  }")

      writeLine("}")
    }
  }

  writeLine() {
    _file.writeBytes("\n")
  }

  writeLine(line) {
    _file.writeBytes(line + "\n")
  }
}

AstBuilder.new().build()
