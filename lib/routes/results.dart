// packages
import 'package:flutter/material.dart';
// files
import 'package:medvedi_stezka/functions.dart';
import 'package:medvedi_stezka/globals.dart';

class Results extends StatefulWidget {
  const Results({super.key});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  TeamCategory? selectedCategory;

  List<CompetitionCard> search() {
    return selectedCompetition!.cards
        .where((element) =>
            selectedCategory == null ||
            element.team.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    selectedCompetition!.cards
        .sort((a, b) => a.getTotalSeconds().compareTo(b.getTotalSeconds()));

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton(
                value: selectedCategory,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("Všechny kategorie"),
                  ),
                  for (TeamCategory category in TeamCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(
                        category.toString(),
                      ),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columnSpacing: 40,
                    border: TableBorder.all(
                      color: Colors.black,
                    ),
                    sortColumnIndex: 1,
                    columns: const [
                      DataColumn(
                        label: Text("Umístění hlídky"),
                      ),
                      DataColumn(
                        label: Text("Číslo hlídky"),
                      ),
                      DataColumn(
                        label: Text("Příjmení a jméno"),
                      ),
                      DataColumn(
                        label: Text("Rok narození"),
                      ),
                      DataColumn(
                        label: Text("Jednota"),
                      ),
                      DataColumn(
                        label: Text("Kategorie"),
                      ),
                      DataColumn(
                        label: Text("Start"),
                        tooltip: "H:MM:SS",
                      ),
                      DataColumn(
                        label: Text("Cíl"),
                        tooltip: "H:MM:SS",
                      ),
                      DataColumn(
                        label: Text("Čas běhu"),
                        tooltip: "H:MM:SS",
                      ),
                      DataColumn(
                        label: Text("Trestné minuty celkem"),
                        tooltip: "H:MM:SS",
                      ),
                      DataColumn(
                        label: Text("Čekací doba celkem"),
                        tooltip: "H:MM:SS",
                      ),
                      DataColumn(
                        label: Text("Výsledný čas"),
                        tooltip: "H:MM:SS",
                      ),
                    ],
                    rows: <DataRow>[
                      for (CompetitionCard card in search())
                        DataRow(
                          cells: <DataCell>[
                            DataCell(
                              Text("${selectedCompetition!.getPlace(card)}"),
                            ),
                            DataCell(
                              Text("${card.team.number}"),
                            ),
                            DataCell(
                              Text(
                                "${card.team.members[0].firstName} ${card.team.members[0].lastName}\n${card.team.members[1].firstName} ${card.team.members[1].lastName}",
                              ),
                            ),
                            DataCell(
                              Text(
                                  "${card.team.members[0].birthYear}\n${card.team.members[1].birthYear}"),
                            ),
                            DataCell(
                              Text(card.team.organization),
                            ),
                            DataCell(
                              Text(card.team.category.toString()),
                            ),
                            DataCell(
                              Text(formatTime(card.startSeconds)),
                            ),
                            DataCell(
                              Text(formatTime(card.finishSeconds)),
                            ),
                            DataCell(
                              Text(
                                formatTime(
                                    card.finishSeconds - card.startSeconds),
                              ),
                            ),
                            DataCell(
                              Text(
                                formatTime(card.getTotalPenaltySeconds()),
                              ),
                            ),
                            DataCell(
                              Text(
                                formatTime(card.getTotalWaitSeconds()),
                              ),
                            ),
                            DataCell(
                              Text(
                                formatTime(card.getTotalSeconds()),
                              ),
                            ),
                          ],
                        ),
                    ],
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
