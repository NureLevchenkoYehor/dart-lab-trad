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

  print('\n--- 2. Generic Repository<Track extends Identifiable> ---');
  final repository = Repository<Track>();
  repository.addAll(validTracks);
  print('Total items loaded in repository: ${repository.count}');

  final lookupId = validTracks.first.id;
  final foundTrack = repository.findById(lookupId);
  print('Lookup by id "$lookupId": ${foundTrack?.trackName}');

  final shortTracks = repository
      .where((t) => t.duration.inMinutes < 2)
      .toList();
  print('Tracks under 2 minutes in repository: ${shortTracks.length}');

  print('\n--- 3. Factory Constructors: Cached & WithDefault ---');
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

  print('\n--- 4. Operator == & hashCode (Set Deduplication) ---');
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

  print('\n--- 5. Mixin Auditable on Identifiable (Track & Album) ---');
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

  print('\n--- 6. Sealed Hierarchy (AudioItem) & Polymorphic Methods ---');
  final audioItems = <AudioItem>[
    StudioTrack(
      id: 'studio-1',
      title: 'Echoes of Silence',
      duration: const Duration(minutes: 11, seconds: 20),
      studioName: 'Abbey Road Studios',
    ),
    LiveRecording(
      id: 'live-1',
      title: 'Rockin in the Free World',
      duration: const Duration(minutes: 6, seconds: 45),
      venue: 'Glastonbury Festival',
      concertDate: DateTime.utc(2023, 6, 24),
    ),
    RemixTrack(
      id: 'remix-1',
      title: 'Bitrate Club Edit',
      duration: const Duration(minutes: 4, seconds: 15),
      remixer: 'Club Edit',
      originalTrackTitle: 'Bitrate',
    ),
    PodcastEpisode(
      id: 'podcast-1',
      title: 'History of Synthesizers',
      duration: const Duration(minutes: 45),
      episodeNumber: 1,
    ),
  ];

  for (final item in audioItems) {
    print('- Polymorphic summary: ${item.formatSummary()}');
    print('  Pattern match (with when guard): ${describeAudioItem(item)}');
  }

  print('\n--- 7. Enhanced Enum MusicGenre ---');
  for (final genre in MusicGenre.values) {
    print(
      '${genre.formatBadge()} (Explicit: ${genre.allowsExplicitLyrics}, Code: ${genre.code})',
    );
  }

  print('\n--- 8. Extension Methods (Duration, DateTime, Iterable<Track>) ---');
  final totalDurationExtension = validTracks.totalDuration;
  final avgDurationExtension = validTracks.averageDuration;
  print(
    'Total duration (toMinutesSecondsUk): ${totalDurationExtension.toMinutesSecondsUk()}',
  );
  print('Total duration (toMmSs): ${totalDurationExtension.toMmSs()}');
  print('Average duration: ${avgDurationExtension.toMmSs()}');

  final firstTrack = validTracks.first;
  print('Track release date: ${firstTrack.releaseDate.toIsoDateOnly()}');
  print('Track age in days: ${firstTrack.releaseDate.ageInDays()} days');

  print('\n--- 9. Collection Processing Pipelines ---');
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
    print(
      '- "${t.trackName}" (${t.releaseYear}, ${t.releaseDate.ageInDays()} days old)',
    );
  }

  print('\n--- Tracks With Date Censored ---');
  for (final t in validTracks.take(3)) {
    final releaseDate = t.releaseDate.toIsoDateOnly();
    print('- [${t.albumName}] ${t.trackName} | ${censorDate(releaseDate)}');
  }
}
