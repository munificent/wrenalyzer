import "scope" for Scope
import "visitor" for RecursiveVisitor

/// Walks a parsed AST and resolves identifiers.
class Resolver is RecursiveVisitor {
  construct new(reporter) {
    _reporter = reporter
    _scope = Scope.new(reporter)
  }

  resolve(node) {
    node.accept(this)
  }

  visitModule(node) {
    // TODO: Implicitly import core.
    super(node)
    _scope.checkForwardReferences()
  }

//  visitMethod(node) { super(node) }

  visitBody(node) {
    _scope.begin()
    declareVariables(node.parameters)
    super(node)
    _scope.end()
  }

  // Expressions.

  // TODO: Make sure LHS is valid.
//  visitAssignmentExpr(node) { super(node) }
//  visitBoolExpr(node) { super(node) }

  visitCallExpr(node) {
    // TODO: Resolve name if there is no receiver.
    if (node.receiver != null) {
      node.receiver.accept(this)
    } else {
      _scope.resolve(node.name)
    }

    if (_scope.resolve(node.name) != null && node.arguments != null) {
      _reporter.error("Cannot call '%(node.name.text)' as method.", [node.name])
    }

    if (node.arguments != null) {
      for (argument in node.arguments) {
        argument.accept(this)
      }
    }

    if (node.blockArgument != null) node.blockArgument.accept(this)
  }

//  visitConditionalExpr(node) { super(node) }

  // TODO: Make sure we're inside instance method.
//  visitFieldExpr(node) { super(node) }
//  visitGroupingExpr(node) { super(node) }

//  visitInfixExpr(node) { super(node) }
//  visitInterpolationExpr(node) { super(node) }
//  visitListExpr(node) { super(node) }
//  visitMapExpr(node) { super(node) }
//  visitNullExpr(node) { super(node) }
//  visitNumExpr(node) { super(node) }
//  visitPrefixExpr(node) { super(node) }
  // TODO: Make sure we're inside class.
//  visitStaticFieldExpr(node) { super(node) }
//  visitStringExpr(node) { super(node) }
//  visitSubscriptExpr(node) { super(node) }
//  visitThisExpr(node) { super(node) }

  // Statements.

  visitBlockStmt(node) {
    _scope.begin()
    super(node)
    _scope.end()
  }

  // TODO: Warn on dead code.
//  visitBreakStmt(node) { super(node) }

  visitClassStmt(node) {
    _scope.declare(node.name)
    _scope.beginClass()
    super(node)
    _scope.endClass()
  }

  visitForStmt(node) {
    _scope.begin()
    _scope.declare(node.variable)

    super(node)

    _scope.end()
  }

//  visitIfStmt(node) { super(node) }

  visitImportStmt(node) {
    declareVariables(node.variables)
    super(node)
  }

  // TODO: Warn on dead code.
//  visitReturnStmt(node) { super(node) }

  visitVarStmt(node) {
    _scope.declare(node.name)
    super(node)
  }

//  visitWhileStmt(node) { super(node) }

  /// Declare [variables] in the current scope from the given list of name
  /// tokens.
  declareVariables(variables) {
    if (variables == null) return
    for (variable in variables) {
      _scope.declare(variable)
    }
  }
}