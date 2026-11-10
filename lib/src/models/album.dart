import 'package:trad/src/models/identifiable.dart';
import 'package:trad/src/models/mixins.dart';

/// Represents an album container containing metadata and tracks.
class Album extends Identifiable with Auditable {
  @override
  final String id;

  /// The album title.
  final String title;

  /// The primary artist or group credited for this album.
  final String artist;

  /// The release year of this album.
  final int releaseYear;

  /// Creates an [Album] entity.
  Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.releaseYear,
  });

  @override
  String toString() =>
      'Album(id: "$id", title: "$title", artist: "$artist", year: $releaseYear)';
}
