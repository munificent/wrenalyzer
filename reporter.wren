import "token" for Token

// ANSI color escapes.
var RED = "\x1b[31m"
var CYAN = "\x1b[36m"
var GRAY = "\x1b[30;1m"
var NORMAL = "\x1b[0m"

/// Reports analysis results in an easily machine-parseable form.
class JsonReporter {
  construct new() {}

  /// Reports an error with [message] stemming from the given list of [tokens].
  /// The last token, if there is more than one, is consideRED the primary
  /// token that led to the error. The others are informative and related to it.
  error(message, tokens) {
    var source = tokens[-1].source

    var tokensJson = tokens.map {|token|
      return {
        "start": token.start,
        "length": token.length,
        "lineStart": token.lineStart,
        "lineEnd": token.lineEnd,
        "columnStart": token.columnStart,
        "columnEnd": token.columnEnd
      }
    }.toList

    var json = {
      // TODO: Other severities.
      "severity": "error",
      "path": source.path,
      "message": message,
      "tokens": tokensJson
    }

    var parts = []
    jsonToBuffer(json, parts)
    System.print(parts.join())
  }

  jsonToBuffer(json, parts) {
    if (json is List) {
      parts.add("[")
      var first = true
      for (element in json) {
        if (!first) parts.add(",")
        first = false
        jsonToBuffer(element, parts)
      }
      parts.add("]")
    } else if (json is Map) {
      parts.add("{")
      var first = true
      for (key in json.keys) {
        if (!first) parts.add(",")
        first = false
        jsonToBuffer(key, parts)
        parts.add(":")
        jsonToBuffer(json[key], parts)
      }
      parts.add("}")
    } else if (json is String) {
      // TODO: Escape quotes and other special characters.
      parts.add("\"%(json)\"")
    } else {
      // Num, Bool, Null.
      parts.add(json)
    }
  }
}

/// Outputs errors and other analysis results in a human-friendly form.
class PrettyReporter {
  construct new() {}

  /// Reports an error with [message] stemming from the given list of [tokens].
  /// The last token, if there is more than one, is consideRED the primary
  /// token that led to the error. The others are informative and related to it.
  error(message, tokens) {
    // The main erroneous token is always the last.
    var mainToken = tokens[-1]

    var source = mainToken.source
    System.print(
        "[%(source.path) %(mainToken.lineStart):%(mainToken.columnStart)] " +
        "%(RED)Error:%(NORMAL) %(message)")

    var lineWidth = 0
    for (token in tokens) {
      var width = token.lineEnd.toString.count
      if (width > lineWidth) lineWidth = width
    }

    // TODO: Collapse output if multiple tokens are on the same line.
    for (token in tokens) {
      var color = token == mainToken ? RED : CYAN
      var end = token == mainToken ? "^" : "."
      var mid = token == mainToken ? "-" : "."

      var line = source.getLine(token.lineStart)
      var lineNum = "%(GRAY)%(padLeft_(token.lineStart, lineWidth)):%(NORMAL) "
      var indent = padLeft_(" ", lineWidth + 2)

      if (token.type == Token.line) {
        // The newline is the error, so make it visible.
        System.print("%(lineNum)%(line)%(GRAY)\\n%(NORMAL)")
        System.print("%(indent)%(" " * line.count)" +
            "%(color)%(end)%(end)%(NORMAL)")
      } else {
        System.print("%(lineNum)%(line)")

        var space = " " * (token.columnStart - 1)
        var highlight = end
        var length = token.columnEnd - token.columnStart
        if (length > 1) {
          highlight = end + mid * (length - 2) + end
        }
        System.print("%(indent)%(space)%(color)%(highlight)%(NORMAL)")
      }
    }
  }

  // TODO: Add padBefore() and padAfter() to String?
  padLeft_(value, width) {
    var result = value.toString
    while (result.count < width) result = " " + result
    return result
  }
}
