import 'package:trad/core.dart';

/// Maximum allowed character length for track and album titles.
const _maxTitleLength = 500;

/// Maximum allowed character length for an individual artist's name.
const _maxArtistNameLength = 250;

/// Earliest known intelligible recording of a human voice (Édouard-Léon Scott de Martinville).
/// Any audio material prior to this year represents sheet music or compositions, not recorded tracks.
const _minReleaseDateYear = 1860;

/// Maximum acceptable playback duration for a single audio track (24 hours in seconds).
const _maxTrackDurationInSeconds = 60 * 60 * 24;

/// Validates that a numeric [value] falls within the inclusive range from [min] to [max].
///
/// Returns an error message if the boundary check fails, or `null` if the value is valid.
String? validateRange(
  num value, {
  required num min,
  required num max,
  required String fieldName,
}) {
  if (value < min || value > max) {
    return 'Field "$fieldName" ($value) must be between $min and $max.';
  }
  return null;
}

/// Validates the release year of a given [date].
///
/// Ensures the year is not earlier than the advent of recorded audio ([_minReleaseDateYear])
/// and does not point to a future calendar year.
List<String> validateReleaseDate(DateTime date) {
  final currentYear = DateTime.now().year;
  final violations = <String>[];

  final rangeViolation = validateRange(
    date.year,
    min: _minReleaseDateYear,
    max: currentYear,
    fieldName: 'Release Year',
  );

  if (rangeViolation != null) {
    violations.add(rangeViolation);
  }

  return violations;
}

/// Validates that track [duration] falls within acceptable playback limits.
///
/// Ensures the duration is at least 1 second and
/// does not exceed the 24-hour threshold ([_maxTrackDurationInSeconds]).
List<String> validateDuration(Duration duration) {
  final violations = <String>[];

  final rangeViolation = validateRange(
    duration.inSeconds,
    min: 1,
    max: _maxTrackDurationInSeconds,
    fieldName: 'Duration in seconds',
  );

  if (rangeViolation != null) {
    violations.add(rangeViolation);
  }

  return violations;
}

/// Validates the format and length constraints of a [trackName].
///
/// Ensures the title is non-empty, contains non-whitespace characters,
/// and does not exceed [_maxTitleLength].
List<String> validateTrackName(String trackName) {
  final violations = <String>[];

  if (trackName.trim().isEmpty) {
    violations.add('Track title cannot be empty or contain only whitespace.');
  } else if (trackName.length > _maxTitleLength) {
    violations.add(
      'Track title exceeds maximum allowed length of $_maxTitleLength characters '
      '(received ${trackName.length}).',
    );
  }

  return violations;
}

/// Validates the format and length constraints of an [albumName].
///
/// Ensures the title is non-empty, contains non-whitespace characters,
/// and does not exceed [_maxTitleLength].
List<String> validateAlbumName(String albumName) {
  final violations = <String>[];

  if (albumName.trim().isEmpty) {
    violations.add('Album title cannot be empty or contain only whitespace.');
  } else if (albumName.length > _maxTitleLength) {
    violations.add(
      'Album title exceeds maximum allowed length of $_maxTitleLength characters '
      '(received ${albumName.length}).',
    );
  }

  return violations;
}

/// Validates the format and length of an individual [artistName].
///
/// Ensures the artist name is non-empty, contains non-whitespace characters,
/// and does not exceed [_maxArtistNameLength].
List<String> validateArtistName(String artistName) {
  final violations = <String>[];

  if (artistName.trim().isEmpty) {
    violations.add('Artist name cannot be empty or contain only whitespace.');
  } else if (artistName.length > _maxArtistNameLength) {
    violations.add(
      'Artist name exceeds maximum allowed length of $_maxArtistNameLength characters '
      '(received ${artistName.length}).',
    );
  }

  return violations;
}

/// Validates the collection of [artists] credited on a track.
///
/// Ensures at least one artist is credited and delegates individual name
/// validation to [validateArtistName].
List<String> validateArtists(List<String> artists) {
  final violations = <String>[];

  if (artists.isEmpty) {
    violations.add('Track must credit at least one artist.');
    return violations;
  }

  for (var i = 0; i < artists.length; i++) {
    final artistViolations = validateArtistName(artists[i]);
    for (final violation in artistViolations) {
      violations.add('Artist #${i + 1}: $violation');
    }
  }

  return violations;
}

/// Validates all domain constraints of a [track] entity.
///
/// Aggregates and returns all violations found across the track\'s metadata fields.
/// Returns an empty list if the track is fully valid.
List<String> validateTrack(Track track) {
  return [
    ...validateTrackName(track.trackName),
    ...validateAlbumName(track.albumName),
    ...validateArtists(track.artists),
    ...validateReleaseDate(track.releaseDate),
    ...validateDuration(track.duration),
  ];
}
