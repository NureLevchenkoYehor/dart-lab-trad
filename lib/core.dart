import 'package:trad/src/models/track.dart';
import 'package:trad/src/processing.dart';

export 'package:trad/src/csv_parsing.dart';
export 'package:trad/src/models/track.dart';
export 'package:trad/src/processing.dart';
export 'package:trad/src/validation.dart';

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
