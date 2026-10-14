import 'package:trad/core.dart';
import 'package:trad/validation.dart';

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
/// - row 7, field `Release date`: `1962` → `MCMLXII` (invalid date format)
/// - row 10, field `Album title`: `"Припустим"` → (empty field)
/// - row 11, field `Artist name(s)`: `,"The Unsleeping"` → (missing field, 4 columns instead of 5)
const sampleTrackCsvRows = [
  '"ALL MY FELLAS","ALL MY FELLAS","Frizk",2023-09-19,141334',
  '"Bitrate","Forgotten Arcade","Frizk",2023-10-27,88285',
  '"I Feel Alive","Forgotten Arcade","Frizk",2023-10-27,156253',
  '"Her Name Is Yubin Lady","Her Name Is Yubin Lady","Oliver Hoss",2021-01-20,179355',
  '"supїdo","supїdo","фрози",2023-08-11,sechs-sieben',
  '"It\'s Been a Long, Long Time","Texas Chatter","Harry James",2008-10-29,205773',
  '"Oh, Pretty Woman","Oh, Pretty Woman","Roy Orbison",MCMLXII,178929',
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
  final entries = sampleTrackCsvRows.map(tryParseTrackCsvRow).toList();

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
        '$number. [Valid] ${track.trackName} (${track.artists.join(', ')})',
      );
    }
  }
}
