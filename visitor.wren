/// Base visitor class that walks the entire AST.
class RecursiveVisitor {
  visitModule(node) {
    for (statement in node.statements) {
      statement.accept(this)
    }
  }

  visitMethod(node) {
    // Foreign methods do not have a body.
    if (node.body != null) node.body.accept(this)
  }

  visitBody(node) {
    if (node.expression != null) node.expression.accept(this)
    if (node.statements != null) {
      for (statement in node.statements) {
        statement.accept(this)
      }
    }
  }

  // Expressions.

  visitAssignmentExpr(node) {
    node.target.accept(this)
    node.value.accept(this)
  }

  visitBoolExpr(node) {}

  visitCallExpr(node) {
    if (node.receiver != null) node.receiver.accept(this)
    if (node.arguments != null) {
      for (argument in node.arguments) {
        argument.accept(this)
      }
    }

    if (node.blockArgument != null) node.blockArgument.accept(this)
  }

  visitConditionalExpr(node) {
    node.condition.accept(this)
    node.thenBranch.accept(this)
    node.elseBranch.accept(this)
  }

  visitFieldExpr(node) {}

  visitGroupingExpr(node) {
    node.expression.accept(this)
  }

  visitInfixExpr(node) {
    node.left.accept(this)
    node.right.accept(this)
  }

  visitInterpolationExpr(node) {
    for (expression in node.expressions) {
      expression.accept(this)
    }
  }

  visitListExpr(node) {
    for (element in node.elements) {
      element.accept(this)
    }
  }

  visitMapExpr(node) {
    for (entry in node.entries) {
      entry.key.accept(this)
      entry.value.accept(this)
    }
  }

  visitNullExpr(node) {}

  visitNumExpr(node) {}

  visitPrefixExpr(node) {
    node.right.accept(this)
  }

  visitStaticFieldExpr(node) {}

  visitStringExpr(node) {}

  visitSubscriptExpr(node) {
    node.receiver.accept(this)
    for (argument in node.arguments) {
      argument.accept(this)
    }
  }

  visitSuperExpr(node) {
    if (node.arguments != null) {
      for (argument in node.arguments) {
        argument.accept(this)
      }
    }

    if (node.blockArgument != null) node.blockArgument.accept(this)
  }

  visitThisExpr(node) {}

  // Statements.

  visitBlockStmt(node) {
    for (statement in node.statements) {
      statement.accept(this)
    }
  }

  visitBreakStmt(node) {}

  visitContinueStmt(node) {}

  visitClassStmt(node) {
    for (method in node.methods) {
      method.accept(this)
    }
  }

  visitForStmt(node) {
    node.iterator.accept(this)
    node.body.accept(this)
  }

  visitIfStmt(node) {
    node.condition.accept(this)
    node.thenBranch.accept(this)
    if (node.elseBranch != null) node.elseBranch.accept(this)
  }

  visitImportStmt(node) {}

  visitReturnStmt(node) {
    if (node.value != null) node.value.accept(this)
  }

  visitVarStmt(node) {
    if (node.initializer != null) node.initializer.accept(this)
  }

  visitWhileStmt(node) {
    node.condition.accept(this)
    node.body.accept(this)
  }
}
