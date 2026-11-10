/// Parses a CSV-formatted [row] into a list of [String] fields.
///
/// A single [separator] character can be specified (defaults to `,`).
/// A single [quoteChar] character can be specified (defaults to `"`).
///
/// Throws a [FormatException] if a quote is not closed at the end of the [row].
List<String> parseCsvRow(
  String row, {
  String separator = ',',
  String quoteChar = '"',
}) {
  // NOTE: I don't want to support multiple character variants, nor I want to hardcode the characters.
  assert(separator.length == 1, 'separator must be a single character');
  assert(quoteChar.length == 1, 'quoteChar must be a single character');

  if (row.isEmpty) return [];

  final fields = <String>[];
  final buffer = StringBuffer();
  var inQuote = false;

  for (var i = 0; i < row.length; i++) {
    final char = row[i];

    if (char == quoteChar) {
      final isEscapedQuote =
          inQuote && i + 1 < row.length && row[i + 1] == quoteChar;
      if (isEscapedQuote) {
        buffer.write(quoteChar);
        i++; // Skip the second quote
      } else {
        inQuote = !inQuote;
      }
    } else if (char == separator && !inQuote) {
      fields.add(buffer.toString());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }

  if (inQuote) {
    throw FormatException('Unclosed quote in CSV line', row);
  }

  fields.add(buffer.toString());

  return fields;
}
