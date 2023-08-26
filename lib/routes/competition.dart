// packages
import 'package:flutter/material.dart';
import 'package:medvedi_stezka/globals.dart';
// routes
import 'package:medvedi_stezka/routes/teams.dart';
import 'package:medvedi_stezka/routes/checks.dart';
import 'package:medvedi_stezka/routes/cards.dart';
import 'package:medvedi_stezka/routes/results.dart';
import 'package:medvedi_stezka/routes/organizations.dart';

class Competition extends StatefulWidget {
  const Competition({super.key});

  @override
  State<Competition> createState() => _CompetitionState();
}

class _CompetitionState extends State<Competition> {
  final PageController pageController = PageController(initialPage: 0);
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
          color: Colors.white,
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "${selectedCompetition!.type} ${selectedCompetition!.location} ${selectedCompetition!.year}",
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (value) {
              setState(() {
                pageController.jumpToPage(value);
                selectedIndex = value;
              });
            },
            selectedIndex: selectedIndex,
            trailing: const Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
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
                icon: Icon(Icons.business),
                label: Text("Jednoty"),
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
                icon: Icon(Icons.badge),
                label: Text("Karty"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.emoji_events),
                label: Text("Výsledky"),
              ),
            ],
          ),
          const VerticalDivider(),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              children: const <Widget>[
                Placeholder(),
                Organizations(),
                Teams(),
                Checks(),
                CompetitionCards(),
                Results(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
