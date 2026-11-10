import 'package:test/test.dart';
import 'package:trad/core.dart';

void main() {
  group('Track model & constructors', () {
    test('primary constructor initializes all fields', () {
      final releaseDate = DateTime.utc(2023, 10, 27);
      final duration = const Duration(seconds: 156);
      final track = Track(
        'frizk:alive',
        'I Feel Alive',
        'Forgotten Arcade',
        const ['Frizk'],
        releaseDate,
        duration,
        genre: MusicGenre.electronic,
      );

      expect(track.id, 'frizk:alive');
      expect(track.trackName, 'I Feel Alive');
      expect(track.albumName, 'Forgotten Arcade');
      expect(track.artists, ['Frizk']);
      expect(track.releaseDate, releaseDate);
      expect(track.duration, duration);
      expect(track.genre, MusicGenre.electronic);
    });

    test('computed properties return expected values', () {
      final singleTrack = Track.create(
        id: 'single:1',
        trackName: 'ALL MY FELLAS',
        albumName: 'ALL MY FELLAS',
        artists: const ['Frizk', 'Guest'],
        releaseDate: DateTime.utc(2023, 9, 19),
        duration: const Duration(minutes: 2, seconds: 21),
      );

      expect(singleTrack.isSingle, isTrue);
      expect(singleTrack.releaseYear, 2023);
      expect(singleTrack.leadArtist, 'Frizk');
      expect(singleTrack.formattedDuration, '2:21');
      expect(singleTrack.toString(), contains('ALL MY FELLAS'));
    });

    test('Track.fromCsv correctly parses valid CSV line', () {
      const csvLine = '"Bitrate","Forgotten Arcade","Frizk",2023-10-27,88285';
      final track = Track.fromCsv(csvLine);

      expect(track.trackName, 'Bitrate');
      expect(track.albumName, 'Forgotten Arcade');
      expect(track.artists, ['Frizk']);
      expect(track.releaseDate, DateTime.parse('2023-10-27'));
      expect(track.duration, const Duration(milliseconds: 88285));
    });

    test('Track.fromCsv throws FormatException on malformed data', () {
      // Missing column (4 instead of 5)
      expect(
        () => Track.fromCsv('"Title","Album","Artist",2023-01-01'),
        throwsFormatException,
      );
      // Invalid date
      expect(
        () => Track.fromCsv('"Title","Album","Artist",invalid-date,1000'),
        throwsFormatException,
      );
      // Non-integer duration
      expect(
        () => Track.fromCsv('"Title","Album","Artist",2023-01-01,not-a-number'),
        throwsFormatException,
      );
    });

    test('Track.tryFromCsv safely returns null on parse failure', () {
      expect(Track.tryFromCsv('invalid csv'), isNull);
      expect(
        Track.tryFromCsv('"supїdo","supїdo","фрози",2023-08-11,sechs-sieben'),
        isNull,
      );
    });

    test('Track.cached returns identical instances for identical IDs', () {
      final instance1 = Track.cached(
        id: 'cache-test-id',
        trackName: 'Cached Song',
        albumName: 'Cached Album',
        artists: const ['Artist A'],
        releaseDate: DateTime.utc(2022, 1, 1),
        duration: const Duration(minutes: 3),
      );

      final instance2 = Track.cached(
        id: 'cache-test-id',
        trackName: 'Cached Song',
        albumName: 'Cached Album',
        artists: const ['Artist A'],
        releaseDate: DateTime.utc(2022, 1, 1),
        duration: const Duration(minutes: 3),
      );

      expect(identical(instance1, instance2), isTrue);
    });

    test('Track.withDefault returns track with default placeholder data', () {
      final defaultTrack = Track.withDefault();
      expect(defaultTrack.id, 'default:untitled');
      expect(defaultTrack.trackName, 'Untitled Track');
      expect(defaultTrack.artists, ['Unknown Artist']);
      expect(defaultTrack.duration, const Duration(minutes: 3));
    });
  });

  group('Operator == and hashCode', () {
    test(
      'two instances with same properties are equal and have same hashCode',
      () {
        final t1 = Track.create(
          id: 'id-1',
          trackName: 'Song',
          albumName: 'Album',
          artists: const ['Artist'],
          releaseDate: DateTime.utc(2020, 1, 1),
          duration: const Duration(seconds: 120),
        );

        final t2 = Track.create(
          id: 'id-1',
          trackName: 'Song',
          albumName: 'Album',
          artists: const ['Artist'],
          releaseDate: DateTime.utc(2020, 1, 1),
          duration: const Duration(seconds: 120),
        );

        expect(t1, equals(t2));
        expect(t1.hashCode, equals(t2.hashCode));

        final set = <Track>{t1, t2};
        expect(set.length, 1);
      },
    );

    test('instances with different properties are not equal', () {
      final t1 = Track.create(
        id: 'id-1',
        trackName: 'Song 1',
        albumName: 'Album',
        artists: const ['Artist'],
        releaseDate: DateTime.utc(2020, 1, 1),
        duration: const Duration(seconds: 120),
      );

      final t2 = Track.create(
        id: 'id-2',
        trackName: 'Song 2',
        albumName: 'Album',
        artists: const ['Artist'],
        releaseDate: DateTime.utc(2020, 1, 1),
        duration: const Duration(seconds: 120),
      );

      expect(t1, isNot(equals(t2)));
      final set = <Track>{t1, t2};
      expect(set.length, 2);
    });
  });

  group('Mixin Auditable on Identifiable', () {
    test('Track and Album can both use Auditable mixin', () {
      final track = Track.create(
        id: 'track-urn-test',
        trackName: 'Song',
        albumName: 'Album',
        artists: const ['Artist'],
        releaseDate: DateTime.utc(2021, 5, 1),
        duration: const Duration(seconds: 200),
      );

      final album = Album(
        id: 'album-urn-test',
        title: 'Greatest Hits',
        artist: 'Various',
        releaseYear: 2021,
      );

      expect(track.urn, 'urn:trad:entity:track-urn-test');
      expect(album.urn, 'urn:trad:entity:album-urn-test');
      expect(
        track.formatAuditEntry(action: 'PLAY'),
        '[PLAY] Entity(id: "track-urn-test")',
      );
      expect(
        album.formatAuditEntry(action: 'ARCHIVE'),
        '[ARCHIVE] Entity(id: "album-urn-test")',
      );
      expect(track.matchesId('TRACK-URN'), isTrue);
    });
  });

  group('Sealed hierarchy AudioItem & Pattern Matching', () {
    test('polymorphic formatSummary() returns specific description for each subtype', () {
      final studio = StudioTrack(
        id: 'st-1',
        title: 'Master Audio',
        duration: const Duration(minutes: 4),
        studioName: 'Sun Studio',
      );
      final live = LiveRecording(
        id: 'lv-1',
        title: 'Live at Wembley',
        duration: const Duration(minutes: 7),
        venue: 'Wembley Stadium',
        concertDate: DateTime.utc(1986, 7, 12),
      );
      final remix = RemixTrack(
        id: 'rm-1',
        title: 'Remixed Song',
        duration: const Duration(minutes: 5),
        remixer: 'DJ Test',
        originalTrackTitle: 'Original Song',
      );
      final podcast = PodcastEpisode(
        id: 'pc-1',
        title: 'Episode One',
        duration: const Duration(minutes: 30),
        episodeNumber: 1,
      );

      expect(studio.formatSummary(), contains('Sun Studio'));
      expect(live.formatSummary(), contains('Wembley Stadium'));
      expect(remix.formatSummary(), contains('DJ Test'));
      expect(podcast.formatSummary(), contains('episode #1'));
    });

    test('describeAudioItem exhaustively matches with when guards', () {
      final epicStudio = StudioTrack(
        id: 's-epic',
        title: 'Symphony',
        duration: const Duration(minutes: 12),
        studioName: 'AIR Studios',
      );
      final festLive = LiveRecording(
        id: 'l-fest',
        title: 'Festival Jam',
        duration: const Duration(minutes: 8),
        venue: 'Woodstock Festival',
        concertDate: DateTime.utc(1969, 8, 15),
      );
      final clubRemix = RemixTrack(
        id: 'r-club',
        title: 'Club Track',
        duration: const Duration(minutes: 3),
        remixer: 'Club Edit',
        originalTrackTitle: 'Original Track',
      );
      final premierPodcast = PodcastEpisode(
        id: 'p-1',
        title: 'Launch',
        duration: const Duration(minutes: 20),
        episodeNumber: 1,
      );

      expect(
        describeAudioItem(epicStudio),
        contains('Epic Studio Masterpiece'),
      );
      expect(describeAudioItem(festLive), contains('Live Open-Air Festival'));
      expect(describeAudioItem(clubRemix), 'Club Edit of "Original Track"');
      expect(
        describeAudioItem(premierPodcast),
        'Podcast Series Premiere: Episode #1',
      );
    });
  });

  group('Generic Repository<T extends Identifiable>', () {
    test('adds, finds, filters, and removes items', () {
      final repo = Repository<Track>();
      final t1 = Track.create(
        id: 'trk-1',
        trackName: 'Track One',
        albumName: 'Album A',
        artists: const ['Artist A'],
        releaseDate: DateTime.utc(2020, 1, 1),
        duration: const Duration(minutes: 2),
      );
      final t2 = Track.create(
        id: 'trk-2',
        trackName: 'Track Two',
        albumName: 'Album B',
        artists: const ['Artist B'],
        releaseDate: DateTime.utc(2021, 1, 1),
        duration: const Duration(minutes: 4),
      );

      repo.addAll([t1, t2]);
      expect(repo.count, 2);
      expect(repo.findById('trk-1')?.trackName, 'Track One');
      expect(repo.findById('non-existent'), isNull);

      final overThreeMin = repo.where((t) => t.duration.inMinutes > 3).toList();
      expect(overThreeMin.length, 1);
      expect(overThreeMin.first.id, 'trk-2');

      expect(repo.remove('trk-1'), isTrue);
      expect(repo.count, 1);
      repo.clear();
      expect(repo.count, 0);
    });
  });

  group('Enhanced Enum MusicGenre', () {
    test('contains fields, constructor, and methods', () {
      const rock = MusicGenre.rock;
      expect(rock.code, 'RCK');
      expect(rock.displayName, 'Rock');
      expect(rock.allowsExplicitLyrics, isTrue);
      expect(rock.formatBadge(), '[RCK] Rock');
      expect(rock.matches('rck'), isTrue);
      expect(rock.matches('rock'), isTrue);
      expect(rock.matches('jazz'), isFalse);
    });
  });

  group('Extension methods', () {
    test('DurationFormatting formats correctly', () {
      final d1 = const Duration(minutes: 3, seconds: 45);
      final d2 = const Duration(hours: 1, minutes: 5, seconds: 9);

      expect(d1.toMmSs(), '3:45');
      expect(d2.toMmSs(), '1:05:09');
      expect(d1.toMinutesSecondsUk(), '3 хв 45 с');
    });

    test('DateTimeDomainExtensions formats and calculates age', () {
      final dt = DateTime.utc(2022, 5, 14);
      expect(dt.toIsoDateOnly(), '2022-05-14');

      final target = DateTime.utc(2022, 5, 24);
      expect(dt.ageInDays(targetDate: target), 10);
    });

    test(
      'TrackIterableExtensions calculates total, average and unique artists',
      () {
        final t1 = Track.create(
          id: '1',
          trackName: 'T1',
          albumName: 'A',
          artists: const ['Artist 1'],
          releaseDate: DateTime.utc(2020),
          duration: const Duration(seconds: 100),
        );
        final t2 = Track.create(
          id: '2',
          trackName: 'T2',
          albumName: 'A',
          artists: const ['Artist 2', 'Artist 1'],
          releaseDate: DateTime.utc(2020),
          duration: const Duration(seconds: 200),
        );

        final tracks = [t1, t2];
        expect(tracks.totalDuration, const Duration(seconds: 300));
        expect(tracks.averageDuration, const Duration(seconds: 150));
        expect(tracks.allUniqueArtists, containsAll(['Artist 1', 'Artist 2']));
      },
    );
  });

  group('Records and Destructuring', () {
    test('computeCatalogMetrics returns destructurable record', () {
      final t1 = Track.create(
        id: '1',
        trackName: 'T1',
        albumName: 'A',
        artists: const ['Artist 1'],
        releaseDate: DateTime.utc(2020),
        duration: const Duration(seconds: 60),
      );
      final t2 = Track.create(
        id: '2',
        trackName: 'T2',
        albumName: 'A',
        artists: const ['Artist 2'],
        releaseDate: DateTime.utc(2020),
        duration: const Duration(seconds: 180),
      );

      final (:totalDuration, :averageDuration, :trackCount, :longestTrack) =
          computeCatalogMetrics([t1, t2]);

      expect(totalDuration, const Duration(seconds: 240));
      expect(averageDuration, const Duration(seconds: 120));
      expect(trackCount, 2);
      expect(longestTrack?.id, '2');
    });

    test('computeCatalogMetrics returns zeroed record for empty iterable', () {
      final (:totalDuration, :averageDuration, :trackCount, :longestTrack) =
          computeCatalogMetrics(const []);

      expect(totalDuration, Duration.zero);
      expect(averageDuration, Duration.zero);
      expect(trackCount, 0);
      expect(longestTrack, isNull);
    });
  });

  group('Validation & Processing', () {
    test('validateTrack detects invalid fields', () {
      final invalidTrack = Track.create(
        id: 'inv',
        trackName: '   ',
        albumName: '',
        artists: const [],
        releaseDate: DateTime.utc(1800),
        duration: Duration.zero,
      );

      final violations = validateTrack(invalidTrack);
      expect(violations, isNotEmpty);
      expect(violations.any((v) => v.contains('whitespace')), isTrue);
      expect(violations.any((v) => v.contains('Release Year')), isTrue);
    });

    test('processing functions work with Track objects', () {
      final t1 = Track.create(
        id: '1',
        trackName: 'Song A',
        albumName: 'Album 2',
        artists: const ['Frizk'],
        releaseDate: DateTime.utc(2023, 1, 1),
        duration: const Duration(minutes: 2),
      );
      final t2 = Track.create(
        id: '2',
        trackName: 'Song B',
        albumName: 'Album 1',
        artists: const ['Frizk'],
        releaseDate: DateTime.utc(2023, 5, 1),
        duration: const Duration(minutes: 3),
      );

      final tracks = [t1, t2];
      final filtered = filterTracksByArtist(tracks, 'frizk');
      expect(filtered.length, 2);

      final sorted = sortTracksByAlbumThenTitle(tracks, asc: true);
      expect(sorted.first.albumName, 'Album 1');

      final grouped = groupTracksByAlbum(tracks);
      expect(grouped.keys, containsAll(['Album 1', 'Album 2']));
    });
  });
}
