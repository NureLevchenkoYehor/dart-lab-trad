import 'package:trad/core.dart';

/// The number of days used for filtering recently released tracks.
const _recentReleaseDaysThreshold = 1200;

/// Default sample artist for report generation and filtering.
const _targetArtist = 'Frizk';

/// Sample CSV data containing music tracks for demonstration and testing.
///
/// Columns (in order):
/// 1. Track title
/// 2. Album title
/// 3. Artist name(s) (separated by `;`)
/// 4. Release date (ISO-8601 string or year)
/// 5. Duration (milliseconds)
///
/// Intentionally corrupted rows:
/// - row 5, field `Duration`: `110125` → `sechs-sieben` (non-integer number)
/// - row 7, field `Release date`: `1962` → `00-1962-00` (invalid date format)
/// - row 10, field `Album title`: `"Припустим"` → (empty field)
/// - row 11, field `Artist name(s)`: `,"The Unsleeping"` → (missing field, 4 columns instead of 5)
const sampleTrackCsvRows = [
  '"ALL MY FELLAS","ALL MY FELLAS","Frizk",2023-09-19,141334',
  '"Bitrate","Forgotten Arcade","Frizk",2023-10-27,88285',
  '"I Feel Alive","Forgotten Arcade","Frizk",2023-10-27,156253',
  '"Her Name Is Yubin Lady","Her Name Is Yubin Lady","Oliver Hoss",2021-01-20,179355',
  '"supїdo","supїdo","фрози",2023-08-11,sechs-sieben',
  '"It\'s Been a Long, Long Time","Texas Chatter","Harry James",2008-10-29,205773',
  '"Oh, Pretty Woman","Oh, Pretty Woman","Roy Orbison",00-1962-00,178929',
  '"Upside Down & Inside Out","Hungry Ghosts","OK Go",2014-10-14,187866',
  '"The Writing\'s On the Wall","Hungry Ghosts","OK Go",2014-10-14,213030',
  '"Припустим",,"The Unsleeping",2020-05-26,171587',
  '"Я кусаю щоки","Справжній бедрум панк",2024-11-15,229587',
  '"It’s TV Time!","DELTARUNE Chapters 3+4 (Original Game Soundtrack)","Toby Fox",2025-06-05,165405',
  '"Attack of the Killer Queen","DELTARUNE Chapter 2 (Original Game Soundtrack)","Toby Fox;Lena Raine;Marcy Nabors",2021-09-17,120000',
  '"Don\'t Forget","DELTARUNE Chapter 1 (Original Game Soundtrack)","Toby Fox;Laura Shigihara",2018-11-01,51424',
  '"乙女の祈り","ユートピア","Chihiro Yamanaka",2018-06-20,256360',
];

void main() {
  print('\n--- 1. CSV Parsing & Domain Validation ---');
  final entries = sampleTrackCsvRows.map(Track.tryFromCsv).toList();

  for (var i = 0; i < entries.length; i++) {
    final track = entries[i];
    final number = i + 1;

    if (track == null) {
      print('$number. [Parse Error] Failed to parse row.');
      continue;
    }

    final violations = validateTrack(track);
    if (violations.isNotEmpty) {
      print(
        '$number. [Invalid] ${track.trackName}:\n> ${violations.join('\n> ')}',
      );
    } else {
      print(
        '$number. [Valid] ${track.trackName} (${track.artists.join(', ')}) '
        '[${track.formattedDuration}] [Single: ${track.isSingle}]',
      );
    }
  }

  final validTracks = entries
      .whereType<Track>()
      .where((t) => validateTrack(t).isEmpty)
      .toList();

  print('\n--- 2. Factory Constructors: Cached & WithDefault ---');
  final cachedA = Track.cached(
    id: 'frizk:all_my_fellas',
    trackName: 'ALL MY FELLAS',
    albumName: 'ALL MY FELLAS',
    artists: const ['Frizk'],
    releaseDate: DateTime.utc(2023, 9, 19),
    duration: const Duration(seconds: 141),
  );
  final cachedB = Track.cached(
    id: 'frizk:all_my_fellas',
    trackName: 'ALL MY FELLAS',
    albumName: 'ALL MY FELLAS',
    artists: const ['Frizk'],
    releaseDate: DateTime.utc(2023, 9, 19),
    duration: const Duration(seconds: 141),
  );
  print('Identical cached instances: ${identical(cachedA, cachedB)}');

  final fallbackTrack = Track.withDefault();
  print('Fallback default track: $fallbackTrack');

  print('\n--- 3. Operator == & hashCode (Set Deduplication) ---');
  final trackCopy1 = Track.create(
    id: 'frizk:bitrate',
    trackName: 'Bitrate',
    albumName: 'Forgotten Arcade',
    artists: const ['Frizk'],
    releaseDate: DateTime.utc(2023, 10, 27),
    duration: const Duration(milliseconds: 88285),
  );
  final trackCopy2 = Track.create(
    id: 'frizk:bitrate',
    trackName: 'Bitrate',
    albumName: 'Forgotten Arcade',
    artists: const ['Frizk'],
    releaseDate: DateTime.utc(2023, 10, 27),
    duration: const Duration(milliseconds: 88285),
  );
  final trackSet = <Track>{trackCopy1, trackCopy2};
  print('trackCopy1 == trackCopy2: ${trackCopy1 == trackCopy2}');
  print('Set size with two equal elements: ${trackSet.length} (expected: 1)');

  print('\n--- 4. Mixin Auditable on Identifiable (Track & Album) ---');
  final sampleAlbum = Album(
    id: 'alb-forgotten-arcade',
    title: 'Forgotten Arcade',
    artist: 'Frizk',
    releaseYear: 2023,
  );
  print(validTracks.first.formatAuditEntry(action: 'STREAM'));
  print('Track URN: ${validTracks.first.urn}');
  print(sampleAlbum.formatAuditEntry(action: 'PURCHASE_ALBUM'));
  print('Album URN: ${sampleAlbum.urn}');

  print('\n--- 5. Enhanced Enum MusicGenre ---');
  for (final genre in MusicGenre.values) {
    print(
      '${genre.formatBadge()} (Explicit: ${genre.allowsExplicitLyrics}, Code: ${genre.code})',
    );
  }

  print('\n--- 6. Collection Processing Pipelines ---');
  final frizkTracks = filterTracksByArtist(validTracks, _targetArtist);
  print('Frizk tracks count: ${frizkTracks.length}');

  final uniqueArtists = extractUniqueArtists(validTracks);
  print('Unique artists: ${uniqueArtists.join(', ')}');

  final sortedAsc = sortTracksByAlbumThenTitle(validTracks, asc: true);
  print(
    'First alphabetically: [${sortedAsc.first.albumName}] ${sortedAsc.first.trackName}',
  );

  final sortedDesc = sortTracksByAlbumThenTitle(validTracks, asc: false);
  print(
    'First reverse: [${sortedDesc.first.albumName}] ${sortedDesc.first.trackName}',
  );

  final report = formatArtistReport(validTracks, _targetArtist);
  print('\n$report');

  print('--- Recent Tracks (within $_recentReleaseDaysThreshold days) ---');
  final recentTracks = validTracks
      .where(releasedWithin(days: _recentReleaseDaysThreshold))
      .toList();
  for (final t in recentTracks) {
    final ageInDays = DateTime.now().difference(t.releaseDate).inDays;
    print('- "${t.trackName}" (${t.releaseDate.year}, $ageInDays days old)');
  }

  print('\n--- Tracks With Date Censored ---');
  for (final t in validTracks) {
    final releaseDate = t.releaseDate.toIso8601String().split('T').first;
    print('- [${t.albumName}] ${t.trackName} | ${censorDate(releaseDate)}');
  }
}
