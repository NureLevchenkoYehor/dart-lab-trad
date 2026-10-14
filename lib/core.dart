import 'package:trad/csv_parsing.dart';
import 'package:trad/processing.dart';

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

/// Formats a detailed discography and duration report for the specified [artist].
///
/// Filters [tracks] by [artist], calculates average playback metrics, and groups
/// the artist's tracks under their respective albums with total album durations.
///
/// Albums and tracks are sorted primarily by album title and secondarily by track name.
/// Set [sortAscending] to `false` to reverse the sort order (defaults to `true`).
String formatArtistReport(
  List<Track> tracks,
  String artist, {
  bool sortAscending = true,
}) {
  final buffer = StringBuffer();

  final artistTracks = filterTracksByArtist(tracks, artist);

  buffer.writeln('=== Artist Report: "$artist" ===');

  if (artistTracks.isEmpty) {
    buffer.writeln('No tracks found for this artist.');
    return buffer.toString();
  }

  buffer.writeln('Total tracks: ${artistTracks.length}');

  final averageDuration = calculateAverageDuration(artistTracks);
  buffer.writeln(
    'Average track duration: ${averageDuration.inMinutes}m ${averageDuration.inSeconds % 60}s\n',
  );

  final sortedTracks = sortTracksByAlbumThenTitle(
    artistTracks,
    asc: sortAscending,
  );

  final albums = groupTracksByAlbum(sortedTracks);

  buffer.writeln('--- Albums & Tracks (${sortAscending ? "A-Z" : "Z-A"}) ---');

  for (final MapEntry(key: albumName, value: albumTracks) in albums.entries) {
    final totalAlbumDuration = calculateTotalDuration(albumTracks);

    buffer.writeln(
      'Album: "$albumName" (${albumTracks.length} tracks, total: ${totalAlbumDuration.inMinutes}m ${totalAlbumDuration.inSeconds % 60}s)',
    );

    for (final track in albumTracks) {
      buffer.writeln(
        '  - ${track.trackName} (${track.duration.inMinutes}m ${track.duration.inSeconds % 60}s)',
      );
    }
  }

  return buffer.toString();
}
