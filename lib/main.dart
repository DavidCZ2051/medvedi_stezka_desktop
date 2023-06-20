// packages
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

  await loadData();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

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
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
    );
  }
}
