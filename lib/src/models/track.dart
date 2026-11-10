import 'package:trad/src/csv_parsing.dart';
import 'package:trad/src/models/genre.dart';
import 'package:trad/src/models/identifiable.dart';
import 'package:trad/src/models/mixins.dart';

/// The expected number of CSV columns in a [Track] row.
const _expectedCsvColumnCount = 5;

/// Compares two lists of strings for structural equality.
bool _listEquals(List<String> a, List<String> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// An immutable music track entity.
///
/// Implements [Identifiable] and mixes in [Auditable] using Dart 3.13 primary constructor syntax.
class Track(
  /// Unique identifier of the track.
  @override final String id,

  /// Title of the music track.
  final String trackName,

  /// Title of the containing album.
  final String albumName,

  /// Ordered list of credited artists.
  final List<String> artists,

  /// Date when the track was released.
  final DateTime releaseDate,

  /// Playback duration of the track.
  final Duration duration, {

  /// Musical genre classification.
  final MusicGenre genre = MusicGenre.soundtrack,
}) extends Identifiable with Auditable {
  /// Creates a [Track] from its individual fields.
  this;

  /// In-memory cache for track instances keyed by their [id].
  static final Map<String, Track> _cache = {};

  /// Generative named constructor providing named parameters for [Track] instantiation.
  Track.create({
    required String id,
    required String trackName,
    required String albumName,
    required List<String> artists,
    required DateTime releaseDate,
    required Duration duration,
    MusicGenre genre = MusicGenre.soundtrack,
  }) : this(
         id,
         trackName,
         albumName,
         List.unmodifiable(artists),
         releaseDate,
         duration,
         genre: genre,
       );

  /// Creates a [Track] by parsing a CSV row.
  ///
  /// The CSV row must contain exactly 5 columns:
  /// `trackName,albumName,artists,releaseDate,durationMs`.
  ///
  /// Throws a [FormatException] if the CSV data is invalid or malformed.
  factory Track.fromCsv(String line) {
    final fields = parseCsvRow(line);

    if (fields.length != _expectedCsvColumnCount) {
      throw FormatException(
        'Expected $_expectedCsvColumnCount CSV columns but found ${fields.length}',
        line,
      );
    }

    final releaseDate = DateTime.tryParse(fields[3]);
    if (releaseDate == null) {
      throw FormatException(
        'Invalid release date format: "${fields[3]}"',
        line,
      );
    }

    final durationMs = int.tryParse(fields[4]);
    if (durationMs == null) {
      throw FormatException(
        'Invalid duration milliseconds: "${fields[4]}"',
        line,
      );
    }

    final trackName = fields[0];
    final albumName = fields[1];
    final artists = List<String>.unmodifiable(fields[2].split(';'));
    final id = '$albumName:$trackName';

    return Track(
      id,
      trackName,
      albumName,
      artists,
      releaseDate,
      Duration(milliseconds: durationMs),
      genre: MusicGenre.soundtrack,
    );
  }

  /// Attempts to parse a CSV [line] into a [Track], returning `null` on error.
  static Track? tryFromCsv(String line) {
    try {
      return Track.fromCsv(line);
    } on FormatException {
      return null;
    }
  }

  /// Returns a cached [Track] instance if present, or creates, stores, and returns a new one.
  factory Track.cached({
    required String id,
    required String trackName,
    required String albumName,
    required List<String> artists,
    required DateTime releaseDate,
    required Duration duration,
    MusicGenre genre = MusicGenre.soundtrack,
  }) {
    return _cache.putIfAbsent(
      id,
      () => Track(
        id,
        trackName,
        albumName,
        List.unmodifiable(artists),
        releaseDate,
        duration,
        genre: genre,
      ),
    );
  }

  /// Returns a fallback [Track] populated with standard default values.
  factory Track.withDefault({
    String id = 'default:untitled',
    String trackName = 'Untitled Track',
    String albumName = 'Unknown Album',
    List<String> artists = const ['Unknown Artist'],
    DateTime? releaseDate,
    Duration duration = const Duration(minutes: 3),
    MusicGenre genre = MusicGenre.soundtrack,
  }) {
    return Track(
      id,
      trackName,
      albumName,
      List.unmodifiable(artists),
      releaseDate ?? DateTime.utc(2000, 1, 1),
      duration,
      genre: genre,
    );
  }

  /// The release calendar year.
  int get releaseYear => releaseDate.year;

  /// Whether the track is a single (track title matches album title).
  bool get isSingle => albumName.toLowerCase() == trackName.toLowerCase();

  /// The primary lead artist credited for this track.
  String get leadArtist => artists.isNotEmpty ? artists.first : '';

  /// Formatted duration string as `m:ss`.
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  String toString() =>
      'Track(id: "$id", title: "$trackName", album: "$albumName", duration: $formattedDuration)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Track) return false;
    return id == other.id &&
        trackName == other.trackName &&
        albumName == other.albumName &&
        _listEquals(artists, other.artists) &&
        releaseDate == other.releaseDate &&
        duration == other.duration &&
        genre == other.genre;
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackName,
    albumName,
    Object.hashAll(artists),
    releaseDate,
    duration,
    genre,
  );
}
