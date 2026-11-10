import 'package:trad/src/models/extensions.dart';
import 'package:trad/src/models/track.dart';
import 'package:trad/src/processing.dart';

export 'package:trad/src/csv_parsing.dart';
export 'package:trad/src/models/album.dart';
export 'package:trad/src/models/audio_item.dart';
export 'package:trad/src/models/extensions.dart';
export 'package:trad/src/models/genre.dart';
export 'package:trad/src/models/identifiable.dart';
export 'package:trad/src/models/mixins.dart';
export 'package:trad/src/models/repository.dart';
export 'package:trad/src/models/track.dart';
export 'package:trad/src/processing.dart';
export 'package:trad/src/validation.dart';

/// Aggregated catalog metrics returned as a typed record.
typedef CatalogMetrics = ({
  Duration totalDuration,
  Duration averageDuration,
  int trackCount,
  Track? longestTrack,
});

/// Computes summary metrics across a collection of [tracks], returning a record.
CatalogMetrics computeCatalogMetrics(Iterable<Track> tracks) {
  if (tracks.isEmpty) {
    return (
      totalDuration: Duration.zero,
      averageDuration: Duration.zero,
      trackCount: 0,
      longestTrack: null,
    );
  }

  final trackList = tracks.toList();
  final total = trackList.totalDuration;
  final avg = trackList.averageDuration;

  Track? longest;
  for (final track in trackList) {
    if (longest == null || track.duration > longest.duration) {
      longest = track;
    }
  }

  return (
    totalDuration: total,
    averageDuration: avg,
    trackCount: trackList.length,
    longestTrack: longest,
  );
}

/// Categorizes a [Track] based on its duration and artist collaboration,
/// demonstrating pattern matching with `when` guard clauses.
String categorizeTrackPlayback(Track track) {
  return switch (track) {
    Track(:final duration) when duration.inMinutes >= 10 =>
      'Epic (${duration.inMinutes} min)',
    Track(:final duration) when duration.inSeconds < 60 =>
      'Interlude (${duration.inSeconds} sec)',
    Track(:final artists) when artists.length > 2 =>
      'Collaboration (${artists.length} artists)',
    Track() => 'Standard Track (${track.formattedDuration})',
  };
}

/// Convenience function that safely parses a CSV [row] into a [Track].
///
/// Provided for backwards compatibility with Laboratory Work 1;
/// delegates directly to [Track.tryFromCsv].
Track? tryParseTrackCsvRow(String row) => Track.tryFromCsv(row);

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
