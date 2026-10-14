import 'package:trad/csv_parsing.dart';

/// The expected number of CSV columns in a [Track] row.
const _trackFieldCount = 5;

/// A music track record parsed from CSV data.
typedef Track = ({
  List<String> artists,
  String trackName,
  String albumName,
  DateTime releaseDate,
  Duration duration,
});

/// Parses a CSV-formatted [row] into a [Track].
///
/// Returns `null` if the [row] has an invalid column count or if
/// primitive types (date, integer duration) cannot be parsed.
Track? tryParseTrackCsvRow(String row) {
  final fields = parseCsvRow(row);

  if (fields.length != _trackFieldCount) return null;

  final releaseDate = DateTime.tryParse(fields[3]);
  final durationMs = int.tryParse(fields[4]);

  if (releaseDate == null || durationMs == null) {
    return null;
  }

  return (
    trackName: fields[0],
    albumName: fields[1],
    artists: fields[2].split(';'),
    releaseDate: releaseDate,
    duration: Duration(milliseconds: durationMs),
  );
}
