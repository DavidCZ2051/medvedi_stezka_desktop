// packages
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:windows_single_instance/windows_single_instance.dart';
// routes
import 'package:medvedi_stezka/routes/competitions.dart';
import 'package:medvedi_stezka/routes/competition.dart';
// files
import 'package:medvedi_stezka/functions.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowsSingleInstance.ensureSingleInstance(args, "medvedistezka");

  if (kDebugMode) {
    log(await getDataString());
  }

  await loadData();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const Competitions(),
        "/competition": (context) => const Competition(),
      },
      title: "Medvědí stezka",
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
    );
  }
}
