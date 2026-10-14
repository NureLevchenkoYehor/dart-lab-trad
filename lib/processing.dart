import 'package:trad/core.dart';

/// Filters [tracks] by the specified [artist] name (case-insensitive).
///
/// Returns an empty list if no tracks match the specified [artist].
List<Track> filterTracksByArtist(List<Track> tracks, String artist) {
  final targetArtist = artist.toLowerCase();

  return tracks
      .where(
        (track) => track.artists.any((a) => a.toLowerCase() == targetArtist),
      )
      .toList();
}

/// Extracts all unique artist names credited across the provided [tracks].
///
/// Returns an empty set if [tracks] is empty.
Set<String> extractUniqueArtists(List<Track> tracks) {
  return tracks.expand((track) => track.artists).toSet();
}

int _totalDurationMs(List<Track> tracks) {
  return tracks.fold<int>(
    0,
    (sum, track) => sum + track.duration.inMilliseconds,
  );
}

/// Calculates the average duration of the provided [tracks].
///
/// Returns [Duration.zero] if [tracks] is empty.
Duration calculateAverageDuration(List<Track> tracks) {
  if (tracks.isEmpty) return Duration.zero;
  return Duration(milliseconds: _totalDurationMs(tracks) ~/ tracks.length);
}

/// Calculates the total duration of the provided [tracks].
///
/// Returns [Duration.zero] if [tracks] is empty.
Duration calculateTotalDuration(List<Track> tracks) {
  if (tracks.isEmpty) return Duration.zero;
  return Duration(milliseconds: _totalDurationMs(tracks));
}

/// Groups [tracks] by their album title.
Map<String, List<Track>> groupTracksByAlbum(List<Track> tracks) {
  final groups = <String, List<Track>>{};

  for (final track in tracks) {
    groups.putIfAbsent(track.albumName, () => []).add(track);
  }

  return groups;
}

/// Calculates the average track duration for each album in [groupedTracks].
Map<String, Duration> calculateAverageDurationByAlbum(
  Map<String, List<Track>> groupedTracks,
) {
  return groupedTracks.map((album, tracks) {
    return MapEntry(album, calculateAverageDuration(tracks));
  });
}

/// Sorts [tracks] primarily by album name and secondarily by track name.
///
/// Sorts in ascending order by default. Set [asc] to `false` for descending order.
List<Track> sortTracksByAlbumThenTitle(List<Track> tracks, {bool asc = true}) {
  final direction = asc ? 1 : -1;

  return tracks.toList()..sort((a, b) {
    final albumComparison = a.albumName.compareTo(b.albumName);

    if (albumComparison != 0) {
      return albumComparison * direction;
    }

    return a.trackName.compareTo(b.trackName) * direction;
  });
}
