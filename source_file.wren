import "./chars" for Chars

/// A single file of Wren source code.
///
/// Handles mapping token offsets to lines and columns.
class SourceFile {
  construct new(path, string) {
    _path = path
    _string = string

    // Due to the magic of UTF-8, we can safely treat Wren source as a series
    // of bytes, since the only code points that are meaningful to Wren fit in
    // ASCII. The only place where non-ASCII code points can occur is inside
    // string literals and comments and the lexer safely treats those as opaque
    // bytes.
    _bytes = string.bytes
  }

  /// Gets the byte at [index] in the source file.
  [index] { _bytes[index] }

  /// The number of bytes in the source file.
  count { _bytes.count }

  /// The file path of the source file.
  path { _path }

  /// Gets the 1-based line that the byte at offset lies on.
  columnAt(offset) {
    var column = 1

    // Walk backwards until we hit a newline.
    for (i in (offset - 1)..0) {
      if (_bytes[i] == Chars.lineFeed) break
      column = column + 1
    }
    return column
  }

  /// Gets the 1-based line that the byte at offset lies on.
  lineAt(offset) {
    // Count all of the newlines before the offset.
    // TODO: Binary search to optimize.
    var line = 0
    findLines_()
    for (i in 0..._lines.count) {
      if (offset < _lines[i]) return i
    }
    return _lines.count
  }

  /// Gets the source text of [line], where 1 is the first line.
  getLine(line) {
    var newlines = findLines_()
    return _string[newlines[line - 1]...(newlines[line] - 1)]
  }

  /// Gets a substring of the source string starting at [start] with [length]
  /// bytes.
  substring(start, length) { _string[start...(start + length)] }

  /// Finds the byte offset of the beginning of every line in the source file.
  /// This lets us quickly map offsets to lines and vice versa.
  findLines_() {
    if (_lines != null) return _lines

    _lines = [0]
    for (i in 0..._bytes.count) {
      if (_bytes[i] == Chars.lineFeed) _lines.add(i + 1)
    }
    return _lines
  }
}
