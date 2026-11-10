import 'package:trad/src/models/track.dart';

/// Extension methods for [Duration] formatting.
extension DurationFormatting on Duration {
  /// Formats the duration into a standard `m:ss` or `h:mm:ss` representation.
  String toMmSs() {
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = inHours;

    if (hours > 0) {
      final paddedMinutes = minutes.toString().padLeft(2, '0');
      return '$hours:$paddedMinutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  /// Formats the duration into Ukrainian text format (e.g. `2 хв 30 с`).
  String toMinutesSecondsUk() {
    final minutes = inMinutes;
    final seconds = inSeconds % 60;
    return '$minutes хв $seconds с';
  }
}

/// Domain extensions for [DateTime].
extension DateTimeDomainExtensions on DateTime {
  /// Formats the date as an ISO date string (`YYYY-MM-DD`).
  String toIsoDateOnly() {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Returns the age in whole days from this date until [targetDate] (defaults to current time).
  int ageInDays({DateTime? targetDate}) {
    final reference = targetDate ?? DateTime.now();
    return reference.difference(this).inDays;
  }
}

/// Collection extensions for iterables of [Track].
extension TrackIterableExtensions on Iterable<Track> {
  /// Computes the aggregate duration of all tracks in the collection.
  Duration get totalDuration =>
      fold<Duration>(Duration.zero, (sum, track) => sum + track.duration);

  /// Computes the average duration across all tracks in the collection.
  Duration get averageDuration {
    if (isEmpty) return Duration.zero;
    return Duration(milliseconds: totalDuration.inMilliseconds ~/ length);
  }

  /// Extracts all unique artist names credited across the collection.
  Set<String> get allUniqueArtists => expand((track) => track.artists).toSet();
}
