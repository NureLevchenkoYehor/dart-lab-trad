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

/// Calculates the total track duration for each album in [groupedTracks].
Map<String, Duration> calculateTotalDurationByAlbum(
  Map<String, List<Track>> groupedTracks,
) {
  return groupedTracks.map((album, tracks) {
    return MapEntry(album, calculateTotalDuration(tracks));
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

/// Creates a predicate that checks whether a track was released within the specified
/// number of [days] before [beforeDate] (defaults to [DateTime.now]).
///
/// For example:
/// ```dart
/// // Matches tracks released between October 10 and October 15, 2000:
/// final recentTracks = tracks
///   .where(releasedWithin(days: 5, before: DateTime(2000, 10, 15)))
///   .toList();
/// ```
bool Function(Track) releasedWithin({required int days, DateTime? beforeDate}) {
  final targetDate = beforeDate ?? DateTime.now();

  return (Track track) {
    final daysAgo = targetDate.difference(track.releaseDate).inDays;
    return daysAgo >= 0 && daysAgo <= days;
  };
}

/// Compiled regex pattern for matching ISO-8601 date variants (`YYYY`, `YYYY-MM`, `YYYY-MM-DD`).
final _datePattern = RegExp(
  r'^(?<year>\d{4})(?:-(?<month>\d{2})(?:-(?<day>\d{2}))?)?$',
);

/// Masks the month and day of a [date], preserving only the year.
///
/// Supports `YYYY`, `YYYY-MM`, and `YYYY-MM-DD` formats.
/// If the input does not match any of these formats, it is returned unmodified.
///
/// Throws a [StateError] if the internal regex pattern matched but failed to capture
/// the mandatory `year` group.
String censorDate(String date) {
  return date.replaceAllMapped(_datePattern, (match) {
    final regExpMatch = match as RegExpMatch;
    final year = regExpMatch.namedGroup('year');
    if (year == null) {
      throw StateError(
        'Mandatory group was not captured in matched date "$date". '
        'Verify the regex definition.',
      );
    }
    final month = regExpMatch.namedGroup('month');
    final day = regExpMatch.namedGroup('day');

    if (day != null) {
      return '$year-**-**';
    }
    if (month != null) {
      return '$year-**';
    }
    return year;
  });
}
