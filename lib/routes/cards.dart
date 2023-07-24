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

  bool isNumberOccupied(int teamNumber) {
    for (CompetitionCard card in selectedCompetition!.cards) {
      if (card.team.number == teamNumber) {
        return true;
      }
    }
    return false;
  }

  void createCompetitionCardDialog() {
    newCompetitionCard = {};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
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
                          Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    labelText: "Hlídka",
                                  ),
                                  value: newCompetitionCard["team"],
                                  items: [
                                    for (Team team
                                        in selectedCompetition!.teams)
                                      if (!isNumberOccupied(team.number))
                                        DropdownMenuItem(
                                          value: team,
                                          child: Text(
                                            "${team.organization}: ${team.members[0].lastName}, ${team.members[1].lastName}",
                                          ),
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
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: "Číslo týmu",
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Zadejte číslo týmu";
                                    } else if (int.tryParse(value) == null) {
                                      return "Zadejte platné číslo";
                                    } else if (isNumberOccupied(
                                        int.parse(value))) {
                                      return "Číslo je již obsazené";
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      newCompetitionCard["teamNumber"] =
                                          int.tryParse(value);
                                    });
                                  },
                                  onSaved: (value) {
                                    setState(() {
                                      newCompetitionCard["teamNumber"] =
                                          int.parse(value!);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          // using a DataTable sounds like a good idea, but it probably isn't
                          DataTable(
                            columns: [
                              for (DeafCheck check in selectedCompetition!
                                  .checks
                                  .whereType<DeafCheck>())
                                DataColumn(
                                  label: Text(
                                    "H${check.number} ${check.name}",
                                  ),
                                ),
                            ],
                            rows: [
                              // every DeafCheck shoul have a cell for every question in that check under it. If there are no questions. If the number of questions is not the same for every check, place an empty cell.
                              DataRow(
                                cells: [
                                  for (DeafCheck check in selectedCompetition!
                                      .checks
                                      .whereType<DeafCheck>())
                                    DataCell(
                                      SizedBox(
                                        height: 1000,
                                        width: 100,
                                        child: Column(
                                          children: [
                                            Text(
                                                "H${check.number} ${check.name}"),
                                            for (Question question
                                                in check.questions)
                                              Expanded(
                                                child: TextFormField(),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          /* // young
                          if (newCompetitionCard["team"] != null &&
                              newCompetitionCard["team"].isYoung)
                            for (Check check
                                in selectedCompetition!.checks.where(
                              (check) =>
                                  check.type == CheckType.deaf &&
                                  (check as DeafCheck).category ==
                                      DeafCheckCategory.young,
                            ))
                              Column(
                                children: [
                                  Text(
                                      "H${check.number} (Mladší) ${check.name}"),
                                ],
                              ),
                          // old
                          if (newCompetitionCard["team"] != null &&
                              !newCompetitionCard["team"].isYoung)
                            for (Check check
                                in selectedCompetition!.checks.where(
                              (check) =>
                                  check.type == CheckType.deaf &&
                                  (check as DeafCheck).category ==
                                      DeafCheckCategory.old,
                            ))
                              SizedBox(
                                height: 400,
                                width: 50,
                                child: Column(
                                  children: [
                                    Text(
                                        "H${check.number} (Starší) ${check.name}"),
                                    for (Question question
                                        in (check as DeafCheck).questions)
                                      Expanded(
                                        child: TextFormField(),
                                      ),
                                  ],
                                ),
                              ) */
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
                            team: Team(
                              // team number is assigned here
                              number: newCompetitionCard["teamNumber"],
                              category: newCompetitionCard["team"].category,
                              members: newCompetitionCard["team"].members,
                              organization:
                                  newCompetitionCard["team"].organization,
                            ),
                            start: DateTime
                                .now(), //newCompetitionCard["startSeconds"],
                            finish: DateTime
                                .now(), //newCompetitionCard["finishSeconds"],
                          ),
                        );

                        // find the appropriate team and give them the number
                        for (Team team in selectedCompetition!.teams) {
                          if (team == newCompetitionCard["team"]) {
                            team.number = newCompetitionCard["teamNumber"];
                          }
                        }

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
              )),
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
                children: <Widget>[
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
                                  children: <Widget>[
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
                                  children: <Widget>[
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
