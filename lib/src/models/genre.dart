/// Represents musical genres supported by the music catalog system.
enum MusicGenre {
  /// Rock music genre.
  rock(code: 'RCK', displayName: 'Rock', allowsExplicitLyrics: true),

  /// Pop music genre.
  pop(code: 'POP', displayName: 'Pop', allowsExplicitLyrics: true),

  /// Electronic music genre.
  electronic(
    code: 'ELC',
    displayName: 'Electronic',
    allowsExplicitLyrics: false,
  ),

  /// Soundtrack music genre (video games, cinema, theater).
  soundtrack(
    code: 'OST',
    displayName: 'Soundtrack',
    allowsExplicitLyrics: false,
  ),

  /// Classical orchestral and acoustic music genre.
  classical(code: 'CLS', displayName: 'Classical', allowsExplicitLyrics: false);

  /// A short uppercase classification code.
  final String code;

  /// The human-readable display title for this genre.
  final String displayName;

  /// Indicates whether tracks in this genre typically allow explicit lyrics.
  final bool allowsExplicitLyrics;

  /// Creates a [MusicGenre] instance.
  const MusicGenre({
    required this.code,
    required this.displayName,
    required this.allowsExplicitLyrics,
  });

  /// Formats a badge label combining the classification [code] and [displayName].
  String formatBadge() => '[$code] $displayName';

  /// Determines whether this genre matches the given search [query] (case-insensitive).
  bool matches(String query) {
    final lower = query.toLowerCase();
    return code.toLowerCase() == lower ||
        displayName.toLowerCase().contains(lower);
  }
}
