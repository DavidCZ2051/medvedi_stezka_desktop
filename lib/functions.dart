// packages
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// files
import 'package:medvedi_stezka/globals.dart';

Future<String> getDataString() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getString("data") ?? "";
}

loadData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  if (prefs.containsKey("data")) {
    Map data = jsonDecode(prefs.getString("data")!);

    for (Map competition in data["competitions"]) {
      competitions.add(
        Competition.fromJson(competition as Map<String, dynamic>),
      );
    }
  }
}

saveData() async {
  Map data = {
    "competitions": competitions,
  };

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs.setString("data", jsonEncode(data));
  log("Data saved");
}

String formatDateTime(DateTime time) {
  String hours = time.hour.toString();
  String minutes = time.minute.toString();
  String seconds = time.second.toString();

  if (seconds.length == 1) {
    seconds = "0$seconds";
  }
  if (minutes.length == 1) {
    minutes = "0$minutes";
  }
  if (hours.length == 1) {
    hours = "0$hours";
  }

  return "$hours:$minutes:$seconds";
}

String formatDuration(Duration duration) {
  return "${duration.inHours}:${duration.inMinutes.remainder(60)}:${duration.inSeconds.remainder(60)}";
}

String formatTime(int time) {
  String hours = (time / 3600).floor().toString();
  String minutes = ((time % 3600) / 60).floor().toString();
  String seconds = (time % 60).floor().toString();

  if (seconds.length == 1) {
    seconds = "0$seconds";
  }
  if (minutes.length == 1) {
    minutes = "0$minutes";
  }
  if (hours.length == 1) {
    hours = "0$hours";
  }

  return "$hours:$minutes:$seconds";
}
