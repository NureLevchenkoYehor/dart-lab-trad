import 'package:trad/src/models/identifiable.dart';
import 'package:trad/src/models/mixins.dart';

/// Sealed base class representing various types of audio items in the catalog.
///
/// Subtypes demonstrate polymorphic dispatch and exhaustive switch expressions
/// with pattern matching guards.
sealed class AudioItem extends Identifiable with Auditable {
  /// The audio item title.
  String get title;

  /// The playback duration.
  Duration get duration;

  /// Polymorphic method providing a formatted summary of the audio item.
  String formatSummary();
}

/// Represents a standard studio-recorded track.
class StudioTrack extends AudioItem {
  @override
  final String id;

  @override
  final String title;

  @override
  final Duration duration;

  /// The recording studio where this track was mastered.
  final String studioName;

  /// Creates a [StudioTrack] instance.
  StudioTrack({
    required this.id,
    required this.title,
    required this.duration,
    required this.studioName,
  });

  @override
  String formatSummary() =>
      'Studio track "$title" recorded at $studioName (${duration.inMinutes}m)';
}

/// Represents a live concert audio recording.
class LiveRecording extends AudioItem {
  @override
  final String id;

  @override
  final String title;

  @override
  final Duration duration;

  /// The concert venue or stadium where the performance took place.
  final String venue;

  /// The date of the live concert.
  final DateTime concertDate;

  /// Creates a [LiveRecording] instance.
  LiveRecording({
    required this.id,
    required this.title,
    required this.duration,
    required this.venue,
    required this.concertDate,
  });

  @override
  String formatSummary() =>
      'Live recording "$title" captured at $venue (${duration.inMinutes}m)';
}

/// Represents an official remix of an existing track.
class RemixTrack extends AudioItem {
  @override
  final String id;

  @override
  final String title;

  @override
  final Duration duration;

  /// The name of the artist or producer who created the remix.
  final String remixer;

  /// The title of the original unremixed track.
  final String originalTrackTitle;

  /// Creates a [RemixTrack] instance.
  RemixTrack({
    required this.id,
    required this.title,
    required this.duration,
    required this.remixer,
    required this.originalTrackTitle,
  });

  @override
  String formatSummary() =>
      'Remix "$title" by $remixer of original "$originalTrackTitle" (${duration.inMinutes}m)';
}

/// Represents a spoken-word podcast episode.
class PodcastEpisode extends AudioItem {
  @override
  final String id;

  @override
  final String title;

  @override
  final Duration duration;

  /// The episode index in the podcast series.
  final int episodeNumber;

  /// Creates a [PodcastEpisode] instance.
  PodcastEpisode({
    required this.id,
    required this.title,
    required this.duration,
    required this.episodeNumber,
  });

  @override
  String formatSummary() =>
      'Podcast episode #$episodeNumber: "$title" (${duration.inMinutes}m)';
}

/// Categorizes and describes an [AudioItem] using an exhaustive switch expression
/// without a default clause, employing pattern matching with `when` guard clauses.
String describeAudioItem(AudioItem item) {
  return switch (item) {
    StudioTrack(:final duration, :final studioName)
        when duration.inMinutes >= 10 =>
      'Epic Studio Masterpiece ($studioName, ${duration.inMinutes}m)',
    StudioTrack(:final studioName) =>
      'Studio Production recorded at $studioName',
    LiveRecording(:final venue) when venue.toLowerCase().contains('festival') =>
      'Live Open-Air Festival Recording at $venue',
    LiveRecording(:final venue) => 'Concert Recording captured live at $venue',
    RemixTrack(:final remixer, :final originalTrackTitle)
        when remixer.toLowerCase() == 'club edit' =>
      'Club Edit of "$originalTrackTitle"',
    RemixTrack(:final remixer, :final originalTrackTitle) =>
      'Remix by $remixer of "$originalTrackTitle"',
    PodcastEpisode(:final episodeNumber) when episodeNumber == 1 =>
      'Podcast Series Premiere: Episode #$episodeNumber',
    PodcastEpisode(:final episodeNumber) =>
      'Podcast Regular Episode #$episodeNumber',
  };
}
