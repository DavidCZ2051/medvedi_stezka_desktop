// packages
import 'package:flutter/material.dart';
import 'package:medvedi_stezka/globals.dart';

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
                  /* TextFormField(
                    controller: _newTeamNumberTextEditingControler,
                    decoration: const InputDecoration(
                      labelText: "Číslo hlídky",
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Zadejte číslo hlídky";
                      } else if (int.tryParse(value) == null) {
                        return "Zadejte platné číslo";
                      } else if (isTeamNumberOccupied(int.parse(value))) {
                        return "Toto číslo je již obsazené";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      setState(() {
                        newTeam["number"] = int.parse(value!);
                      });
                    },
                  ), */
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
                    waitSeconds: 0, //newCompetitionCard["waitSeconds"],
                  ),
                );

                selectedCompetition!.cards.sort(
                  (a, b) => a.team.number.compareTo(b.team.number),
                );

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
      body: selectedCompetition!.teams.isEmpty
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
                      child: ListTile(
                        leading: Text(
                          "${card.team.number}",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
