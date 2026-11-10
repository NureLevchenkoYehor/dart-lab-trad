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
