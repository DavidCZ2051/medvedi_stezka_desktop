// packages
import 'package:flutter/material.dart';
import 'package:medvedi_stezka/functions.dart';
import 'package:medvedi_stezka/globals.dart';

class Results extends StatefulWidget {
  const Results({super.key});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        // TODO: make scrollable both ways
        padding: const EdgeInsets.all(8.0),
        child: DataTable(
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
            for (CompetitionCard card in selectedCompetition!.cards)
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
                    Text(formatTime(card.startSeconds)),
                  ),
                  DataCell(
                    Text(formatTime(card.finishSeconds)),
                  ),
                  DataCell(
                    Text(
                      formatTime(card.finishSeconds - card.startSeconds),
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
    );
  }
}
