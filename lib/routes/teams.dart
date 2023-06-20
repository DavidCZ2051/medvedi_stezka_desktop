// packages
import 'package:flutter/material.dart';
import 'package:medvedi_stezka/globals.dart';

class Teams extends StatefulWidget {
  const Teams({super.key});

  @override
  State<Teams> createState() => _TeamsState();
}

class _TeamsState extends State<Teams> {
  final _newTeamFormKey = GlobalKey<FormState>();
  final _newTeamNumberTextEditingControler = TextEditingController();

  Map<String, dynamic> newTeam = {};

  bool isTeamNumberOccupied(int number) {
    for (Team team in selectedCompetition!.teams) {
      if (team.number == number) {
        return true;
      }
    }
    return false;
  }

  void createTeamDialog() {
    newTeam = {};
    _newTeamNumberTextEditingControler.text = selectedCompetition!.teams.isEmpty
        ? "1"
        : "${selectedCompetition!.teams.last.number + 1}";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Přidat hlídku"),
        content: Form(
          key: _newTeamFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: "Kategorie",
                  ),
                  value: newTeam["category"],
                  items: [
                    DropdownMenuItem(
                      value: TeamCategory.one,
                      child: Text("${TeamCategory.one}"),
                    ),
                    DropdownMenuItem(
                      value: TeamCategory.two,
                      child: Text("${TeamCategory.two}"),
                    ),
                    DropdownMenuItem(
                      value: TeamCategory.three,
                      child: Text("${TeamCategory.three}"),
                    ),
                    DropdownMenuItem(
                      value: TeamCategory.four,
                      child: Text("${TeamCategory.four}"),
                    ),
                    DropdownMenuItem(
                      value: TeamCategory.grownup,
                      child: Text("${TeamCategory.grownup}"),
                    ),
                  ],
                  validator: (value) {
                    if (value == null) {
                      return "Vyberte kategorii hlídky";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      newTeam["category"] = value;
                    });
                  },
                  onSaved: (value) {
                    setState(() {
                      newTeam["category"] = value;
                    });
                  },
                ),
                TextFormField(
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
                ),
              ],
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
              if (_newTeamFormKey.currentState!.validate()) {
                _newTeamFormKey.currentState!.save();

                selectedCompetition!.teams.add(
                  Team(
                    number: newTeam["number"],
                    category: newTeam["category"],
                  ),
                );

                selectedCompetition!.teams.sort(
                  (a, b) => a.number.compareTo(b.number),
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
        heroTag: "createTeam",
        tooltip: "Přidat hlídku",
        onPressed: createTeamDialog,
        child: const Icon(Icons.add),
      ),
      body: selectedCompetition!.teams.isEmpty
          ? const Center(
              child: Text(
                "Zatím žádné hlídky...",
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
                      "Počet hlídek: ${selectedCompetition!.teams.length}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  for (Team team in selectedCompetition!.teams)
                    Card(
                      child: ListTile(
                        leading: Text(
                          "${team.number}",
                          style: const TextStyle(fontSize: 20),
                        ),
                        title: Text("${team.category}"),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
