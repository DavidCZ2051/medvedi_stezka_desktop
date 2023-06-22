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
