// packages
import 'package:flutter/material.dart';
import 'package:medvedi_stezka/globals.dart';
// files
import 'package:medvedi_stezka/functions.dart';

class CompetitionCards extends StatefulWidget {
  const CompetitionCards({super.key});

  @override
  State<CompetitionCards> createState() => _CompetitionCardsState();
}

class _CompetitionCardsState extends State<CompetitionCards> {
  final _newCompetitionCardFormKey = GlobalKey<FormState>();

  Map<String, dynamic> newCompetitionCard = {};

  void createCompetitionCardDialog() {
    newCompetitionCard = {};

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Přidat kartu"),
        content: Form(
          key: _newCompetitionCardFormKey,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 700,
                minHeight: 400,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  DropdownButtonFormField(
                    decoration: const InputDecoration(
                      labelText: "Hlídka",
                    ),
                    value: newCompetitionCard["team"],
                    items: [
                      for (Team team in selectedCompetition!.teams.where(
                        (team) => !selectedCompetition!.cards
                            .any((card) => card.team == team),
                      ))
                        DropdownMenuItem(
                          value: team,
                          child: Text("Hlídka ${team.number}"),
                        ),
                    ],
                    validator: (value) {
                      if (value == null) {
                        return "Vyberte hlídku";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        newCompetitionCard["team"] = value;
                      });
                    },
                    onSaved: (value) {
                      setState(() {
                        newCompetitionCard["team"] = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Zrušit"),
          ),
          OutlinedButton(
            onPressed: () {
              if (_newCompetitionCardFormKey.currentState!.validate()) {
                _newCompetitionCardFormKey.currentState!.save();

                selectedCompetition!.cards.add(
                  CompetitionCard(
                    team: newCompetitionCard["team"],
                    start: DateTime.now(), //newCompetitionCard["startSeconds"],
                    finish:
                        DateTime.now(), //newCompetitionCard["finishSeconds"],
                  ),
                );

                selectedCompetition!.cards.sort(
                  (a, b) => a.team.number.compareTo(b.team.number),
                );

                saveData();

                setState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text("Přidat"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "createCompetitionCard",
        tooltip: "Přidat kartu",
        onPressed: createCompetitionCardDialog,
        child: const Icon(Icons.add),
      ),
      body: selectedCompetition!.cards.isEmpty
          ? const Center(
              child: Text(
                "Zatím žádné karty...",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Počet karet: ${selectedCompetition!.cards.length}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  for (CompetitionCard card in selectedCompetition!.cards)
                    Card(
                      child: InkWell(
                        onSecondaryTapDown: (TapDownDetails tap) {
                          // TODO
                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              tap.globalPosition.dx,
                              tap.globalPosition.dy,
                              tap.globalPosition.dx,
                              tap.globalPosition.dy,
                            ),
                            items: [
                              PopupMenuItem(
                                onTap: () {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {});
                                },
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                    ),
                                    SizedBox(width: 8),
                                    Text("Upravit"),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () {},
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                    ),
                                    SizedBox(width: 8),
                                    Text("Smazat"),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        child: ListTile(
                          leading: Text(
                            "${card.team.number}",
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
