// packages
import 'package:flutter/material.dart';
import 'package:medvedi_stezka/globals.dart';
// routes
import 'package:medvedi_stezka/routes/teams.dart';
import 'package:medvedi_stezka/routes/checks.dart';
import 'package:medvedi_stezka/routes/cards.dart';
import 'package:medvedi_stezka/routes/results.dart';

class Competition extends StatefulWidget {
  const Competition({super.key});

  @override
  State<Competition> createState() => _CompetitionState();
}

class _CompetitionState extends State<Competition> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: "Zpět",
          onPressed: () {
            selectedCompetition = null;
            Navigator.pop(context);
          },
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "${selectedCompetition!.type} ${selectedCompetition!.location} ${selectedCompetition!.year}",
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
      body: Row(
        children: [
          NavigationRail(
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
            selectedIndex: selectedIndex,
            trailing: const Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      appVersion,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text("Soutěž"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text("Hlídky"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.check),
                label: Text("Kontroly"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.emoji_events),
                label: Text("Výsledky"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.badge),
                label: Text("Karty"),
              ),
            ],
          ),
          const VerticalDivider(),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: const [
                Placeholder(),
                Teams(),
                Checks(),
                Results(),
                CompetitionCards(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
