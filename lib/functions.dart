loadData() async {}

saveData() async {}

String formatTime(int seconds) {
  String minutes = (seconds / 60).floor().toString();
  String secs = (seconds % 60).toString();
  if (minutes.length == 1) {
    minutes = "0$minutes";
  }
  if (secs.length == 1) {
    secs = "0$secs";
  }
  return "$minutes:$secs";
}
