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
      body: DataTable(
        sortColumnIndex: 1,
        columns: const [
          DataColumn(label: Text("Číslo hlídky")),
          DataColumn(label: Text("Celkový čas")),
        ],
        rows: [
          for (CompetitionCard card in selectedCompetition!.cards)
            DataRow(
              cells: [
                DataCell(Text("Hlídka ${card.team.number.toString()}")),
                DataCell(Text(formatTime(card.getTotalSeconds()))),
              ],
            ),
        ],
      ),
    );
  }
}
