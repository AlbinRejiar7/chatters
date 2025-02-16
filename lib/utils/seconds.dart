String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String minutes = twoDigits(duration.inMinutes);
  String seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}
