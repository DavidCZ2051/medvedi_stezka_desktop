// packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final TextEditingController _newCompetitionCardStartHoursController =
      TextEditingController();
  final TextEditingController _newCompetitionCardStartMinutesController =
      TextEditingController();
  final TextEditingController _newCompetitionCardStartSecondsController =
      TextEditingController();

  final TextEditingController _newCompetitionCardFinishHoursController =
      TextEditingController();
  final TextEditingController _newCompetitionCardFinishMinutesController =
      TextEditingController();
  final TextEditingController _newCompetitionCardFinishSecondsController =
      TextEditingController();

  List<List<TextEditingController>> deafCheckDataTableTextEditingControllers =
      [];

  List<List<(TextEditingController, TextEditingController)>>
      liveCheckDataTableTextEditingControllers = [];

  Map<String, dynamic> newCompetitionCard = {};
  int biggestQuestionsCount = 0;

  bool isNumberOccupied(int teamNumber) {
    for (CompetitionCard card in selectedCompetition!.cards) {
      if (card.team.number == teamNumber) {
        return true;
      }
    }
    return false;
  }

  int getStartSeconds() {
    int hours = int.tryParse(_newCompetitionCardStartHoursController.text) ?? 0;
    int minutes =
        int.tryParse(_newCompetitionCardStartMinutesController.text) ?? 0;
    int seconds =
        int.tryParse(_newCompetitionCardStartSecondsController.text) ?? 0;

    return hours * 3600 + minutes * 60 + seconds;
  }

  int getFinishSeconds() {
    int hours =
        int.tryParse(_newCompetitionCardFinishHoursController.text) ?? 0;
    int minutes =
        int.tryParse(_newCompetitionCardFinishMinutesController.text) ?? 0;
    int seconds =
        int.tryParse(_newCompetitionCardFinishSecondsController.text) ?? 0;

    return hours * 3600 + minutes * 60 + seconds;
  }

  int getBiggestQuestionsCount(List<DeafCheck> checks) {
    int biggest = 0;
    for (DeafCheck check in checks) {
      if (check.questions.length > biggest) {
        biggest = check.questions.length;
      }
    }
    return biggest;
  }

  void createDeafCheckDataTableTextEditingControllers() {
    deafCheckDataTableTextEditingControllers = [
      for (DeafCheck check in selectedCompetition!.checks
          .whereType<DeafCheck>()
          .where((check) =>
              check.category == CheckCategory.young &&
                  newCompetitionCard["team"].isYoung ||
              check.category == CheckCategory.old &&
                  !newCompetitionCard["team"].isYoung))
        [
          for (int i = 0; i < check.questions.length; i++)
            TextEditingController(),
        ],
    ];
  }

  void createLiveCheckDataTableTextEditingControllers() {
    liveCheckDataTableTextEditingControllers = [
      for (LiveCheck _ in selectedCompetition!.checks.whereType<LiveCheck>())
        [
          (
            // trestný čas
            TextEditingController(), // M
            TextEditingController(), // S
          ),
          (
            // čekačka
            TextEditingController(), // M
            TextEditingController(), // S
          ),
        ],
    ];
  }

  void viewCompetitionCardDialog(CompetitionCard competitionCard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Karta"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Číslo týmu: ${competitionCard.team.number}"),
                    Text("Jednota: ${competitionCard.team.organization}"),
                    Text("Kategorie: ${competitionCard.team.category}"),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Členové: "),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${competitionCard.team.members[0].firstName} ${competitionCard.team.members[0].lastName} ${competitionCard.team.members[0].birthYear}",
                            ),
                            Text(
                              "${competitionCard.team.members[1].firstName} ${competitionCard.team.members[1].lastName} ${competitionCard.team.members[1].birthYear}",
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "Start: ${competitionCard.startSeconds ~/ 3600}:${(competitionCard.startSeconds % 3600) ~/ 60}:${competitionCard.startSeconds % 60}",
                    ),
                    Text(
                      "Cíl: ${competitionCard.finishSeconds ~/ 3600}:${(competitionCard.finishSeconds % 3600) ~/ 60}:${competitionCard.finishSeconds % 60}",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Zavřít"),
          ),
        ],
      ),
    );
  }

  void createCompetitionCardDialog() async {
    newCompetitionCard = {};
    deafCheckDataTableTextEditingControllers = [];
    liveCheckDataTableTextEditingControllers = [];
    biggestQuestionsCount = getBiggestQuestionsCount(
      selectedCompetition!.checks
          .whereType<DeafCheck>()
          .toList(), //TODO: Otestovat různý počet otázek
    );

    _newCompetitionCardStartHoursController.text = "";
    _newCompetitionCardStartMinutesController.text = "";
    _newCompetitionCardStartSecondsController.text = "";

    _newCompetitionCardFinishHoursController.text = "";
    _newCompetitionCardFinishMinutesController.text = "";
    _newCompetitionCardFinishSecondsController.text = "";

    createLiveCheckDataTableTextEditingControllers(); //TODO: Živé kontroly možná mají kategorie, pokud ano, potřeba předělat

    var result = await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Přidat kartu"),
          content: Form(
            key: _newCompetitionCardFormKey,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 800,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FocusTraversalGroup(
                            child: Row(
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
                                              "${team.organization} - ${team.category}: ${team.members[0].lastName}, ${team.members[1].lastName} ",
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
                                      newCompetitionCard["team"] = value;
                                      createDeafCheckDataTableTextEditingControllers();
                                      setState(() {});
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
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FocusTraversalGroup(
                                child: Column(
                                  children: [
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Čas start",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Row(
                                              children: [
                                                // hodiny
                                                SizedBox(
                                                  width: 50,
                                                  child: TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Zadejte hodiny";
                                                      }
                                                      return null;
                                                    },
                                                    controller:
                                                        _newCompetitionCardStartHoursController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      if (value.length == 1) {
                                                        FocusScope.of(context)
                                                            .nextFocus();
                                                      }
                                                    },
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: "H",
                                                    ),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                        1,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Text(
                                                    ":",
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                // minuty
                                                SizedBox(
                                                  width: 50,
                                                  child: TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Zadejte minuty";
                                                      }
                                                      return null;
                                                    },
                                                    controller:
                                                        _newCompetitionCardStartMinutesController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      if (_newCompetitionCardStartHoursController
                                                              .text ==
                                                          "") {
                                                        _newCompetitionCardStartHoursController
                                                            .text = "00";
                                                      }

                                                      if (value.length == 2) {
                                                        FocusScope.of(context)
                                                            .nextFocus();
                                                      }
                                                    },
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: "M",
                                                    ),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                        2,
                                                      ),
                                                      FilteringTextInputFormatter
                                                          .allow(
                                                        RegExp(
                                                          r"^(0?[0-9]|[1-5][0-9])$",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Text(
                                                    ":",
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                // sekundy
                                                SizedBox(
                                                  width: 50,
                                                  child: TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Zadejte sekundy";
                                                      }
                                                      return null;
                                                    },
                                                    controller:
                                                        _newCompetitionCardStartSecondsController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      if (_newCompetitionCardStartHoursController
                                                              .text ==
                                                          "") {
                                                        _newCompetitionCardStartHoursController
                                                            .text = "00";
                                                      }

                                                      if (_newCompetitionCardStartMinutesController
                                                              .text ==
                                                          "") {
                                                        _newCompetitionCardStartMinutesController
                                                            .text = "00";
                                                      }

                                                      if (value.length == 2) {
                                                        FocusScope.of(context)
                                                            .nextFocus();
                                                      }
                                                    },
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: "S",
                                                    ),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                        2,
                                                      ),
                                                      FilteringTextInputFormatter
                                                          .allow(
                                                        RegExp(
                                                          r"^(0?[0-9]|[1-5][0-9])$",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Čas cíl",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Row(
                                              children: [
                                                // hodiny
                                                SizedBox(
                                                  width: 50,
                                                  child: TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Zadejte hodiny";
                                                      }
                                                      return null;
                                                    },
                                                    controller:
                                                        _newCompetitionCardFinishHoursController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      if (_newCompetitionCardStartSecondsController
                                                              .text ==
                                                          "") {
                                                        _newCompetitionCardStartSecondsController
                                                            .text = "00";
                                                      }

                                                      if (value.length == 1) {
                                                        FocusScope.of(context)
                                                            .nextFocus();
                                                      }
                                                    },
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: "H",
                                                    ),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                        1,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Text(
                                                    ":",
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                // minuty
                                                SizedBox(
                                                  width: 50,
                                                  child: TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Zadejte minuty";
                                                      }
                                                      return null;
                                                    },
                                                    controller:
                                                        _newCompetitionCardFinishMinutesController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      if (_newCompetitionCardStartSecondsController
                                                              .text ==
                                                          "") {
                                                        _newCompetitionCardStartSecondsController
                                                            .text = "00";
                                                      }

                                                      if (_newCompetitionCardFinishHoursController
                                                              .text ==
                                                          "") {
                                                        _newCompetitionCardFinishHoursController
                                                            .text = "00";
                                                      }

                                                      if (value.length == 2) {
                                                        FocusScope.of(context)
                                                            .nextFocus();
                                                      }
                                                    },
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: "M",
                                                    ),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                        2,
                                                      ),
                                                      FilteringTextInputFormatter
                                                          .allow(
                                                        RegExp(
                                                          r"^(0?[0-9]|[1-5][0-9])$",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Text(
                                                    ":",
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                // sekundy
                                                SizedBox(
                                                  width: 50,
                                                  child: TextFormField(
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return "Zadejte sekundy";
                                                      }
                                                      return null;
                                                    },
                                                    controller:
                                                        _newCompetitionCardFinishSecondsController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onChanged: (value) {
                                                      if (_newCompetitionCardFinishHoursController
                                                              .text ==
                                                          "") {
                                                        _newCompetitionCardFinishHoursController
                                                            .text = "00";
                                                      }

                                                      if (_newCompetitionCardFinishMinutesController
                                                              .text ==
                                                          "") {
                                                        _newCompetitionCardFinishMinutesController
                                                            .text = "00";
                                                      }

                                                      if (value.length == 2) {
                                                        FocusScope.of(context)
                                                            .nextFocus();
                                                      }
                                                    },
                                                    textAlign: TextAlign.center,
                                                    decoration:
                                                        const InputDecoration(
                                                      hintText: "S",
                                                    ),
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter
                                                          .digitsOnly,
                                                      LengthLimitingTextInputFormatter(
                                                        2,
                                                      ),
                                                      FilteringTextInputFormatter
                                                          .allow(
                                                        RegExp(
                                                          r"^(0?[0-9]|[1-5][0-9])$",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              if (newCompetitionCard["team"] != null)
                                DataTable(
                                  border: TableBorder.all(),
                                  columns: const [
                                    DataColumn(
                                      label: Text(
                                        "Kontrola",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "Trestný čas",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        "Čekačka",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                  rows: [
                                    for (LiveCheck check in selectedCompetition!
                                        .checks
                                        .whereType<LiveCheck>()
                                        .where((check) =>
                                            (newCompetitionCard["team"]
                                                    .isYoung &&
                                                check.category ==
                                                    CheckCategory.young) ||
                                            (!newCompetitionCard["team"]
                                                    .isYoung &&
                                                check.category ==
                                                    CheckCategory.old)))
                                      DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              "Ž${check.number} - ${check.name} - ${check.category}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            FocusTraversalGroup(
                                              child: Row(
                                                children: [
                                                  // minuty
                                                  SizedBox(
                                                    width: 50,
                                                    child: TextFormField(
                                                      controller: liveCheckDataTableTextEditingControllers[
                                                              selectedCompetition!
                                                                  .checks
                                                                  .whereType<
                                                                      LiveCheck>()
                                                                  .toList()
                                                                  .indexOf(
                                                                      check)][0]
                                                          .$1,
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return "Zadejte minuty";
                                                        }
                                                        return null;
                                                      },
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (value) {
                                                        if (value.length == 2) {
                                                          FocusScope.of(context)
                                                              .nextFocus();
                                                        }
                                                      },
                                                      textAlign:
                                                          TextAlign.center,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText: "M",
                                                      ),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                        LengthLimitingTextInputFormatter(
                                                          2,
                                                        ),
                                                        FilteringTextInputFormatter
                                                            .allow(
                                                          RegExp(
                                                            r"^(0?[0-9]|[1-5][0-9])$",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0),
                                                    child: Text(
                                                      ":",
                                                      style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  // sekundy
                                                  SizedBox(
                                                    width: 50,
                                                    child: TextFormField(
                                                      controller: liveCheckDataTableTextEditingControllers[
                                                              selectedCompetition!
                                                                  .checks
                                                                  .whereType<
                                                                      LiveCheck>()
                                                                  .toList()
                                                                  .indexOf(
                                                                      check)][0]
                                                          .$2,
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return "Zadejte sekundy";
                                                        }
                                                        return null;
                                                      },
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (value) {
                                                        if (value.length == 2) {
                                                          FocusScope.of(context)
                                                              .nextFocus();
                                                        }
                                                      },
                                                      textAlign:
                                                          TextAlign.center,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText: "S",
                                                      ),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                        LengthLimitingTextInputFormatter(
                                                          2,
                                                        ),
                                                        FilteringTextInputFormatter
                                                            .allow(
                                                          RegExp(
                                                            r"^(0?[0-9]|[1-5][0-9])$",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            FocusTraversalGroup(
                                              child: Row(
                                                children: [
                                                  // minuty
                                                  SizedBox(
                                                    width: 50,
                                                    child: TextFormField(
                                                      controller: liveCheckDataTableTextEditingControllers[
                                                              selectedCompetition!
                                                                  .checks
                                                                  .whereType<
                                                                      LiveCheck>()
                                                                  .toList()
                                                                  .indexOf(
                                                                      check)][1]
                                                          .$1,
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return "Zadejte minuty";
                                                        }
                                                        return null;
                                                      },
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (value) {
                                                        if (value.length == 2) {
                                                          FocusScope.of(context)
                                                              .nextFocus();
                                                        }
                                                      },
                                                      textAlign:
                                                          TextAlign.center,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText: "M",
                                                      ),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                        LengthLimitingTextInputFormatter(
                                                          2,
                                                        ),
                                                        FilteringTextInputFormatter
                                                            .allow(
                                                          RegExp(
                                                            r"^(0?[0-9]|[1-5][0-9])$",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.all(4.0),
                                                    child: Text(
                                                      ":",
                                                      style: TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  // sekundy
                                                  SizedBox(
                                                    width: 50,
                                                    child: TextFormField(
                                                      controller: liveCheckDataTableTextEditingControllers[
                                                              selectedCompetition!
                                                                  .checks
                                                                  .whereType<
                                                                      LiveCheck>()
                                                                  .toList()
                                                                  .indexOf(
                                                                      check)][1]
                                                          .$2,
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return "Zadejte sekundy";
                                                        }
                                                        return null;
                                                      },
                                                      keyboardType:
                                                          TextInputType.number,
                                                      onChanged: (value) {
                                                        if (value.length == 2) {
                                                          FocusScope.of(context)
                                                              .nextFocus();
                                                        }
                                                      },
                                                      textAlign:
                                                          TextAlign.center,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText: "S",
                                                      ),
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly,
                                                        LengthLimitingTextInputFormatter(
                                                          2,
                                                        ),
                                                        FilteringTextInputFormatter
                                                            .allow(
                                                          RegExp(
                                                            r"^(0?[0-9]|[1-5][0-9])$",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              const Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (newCompetitionCard["team"] != null)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 400,
                          child: VerticalDivider(),
                        ),
                      ),
                    if (newCompetitionCard["team"] != null)
                      FocusTraversalGroup(
                        child: DataTable(
                          border: TableBorder.all(),
                          columns: [
                            for (DeafCheck check in selectedCompetition!.checks
                                .whereType<DeafCheck>()
                                .where((check) =>
                                    (newCompetitionCard["team"].isYoung &&
                                        check.category ==
                                            CheckCategory.young) ||
                                    (!newCompetitionCard["team"].isYoung &&
                                        check.category == CheckCategory.old)))
                              DataColumn(
                                label: Text(
                                  "H${check.number} - ${check.name} - ${check.category}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                          ],
                          rows: [
                            for (int i = 0; i < biggestQuestionsCount; i++)
                              DataRow(
                                cells: [
                                  for (DeafCheck check in selectedCompetition!
                                      .checks
                                      .whereType<DeafCheck>()
                                      .where((check) =>
                                          (newCompetitionCard["team"].isYoung &&
                                              check.category ==
                                                  CheckCategory.young) ||
                                          (!newCompetitionCard["team"]
                                                  .isYoung &&
                                              check.category ==
                                                  CheckCategory.old)))
                                    DataCell(
                                      TextFormField(
                                        controller:
                                            deafCheckDataTableTextEditingControllers[
                                                selectedCompetition!
                                                    .checks
                                                    .whereType<DeafCheck>()
                                                    .where((check) =>
                                                        check
                                                                    .category ==
                                                                CheckCategory
                                                                    .young &&
                                                            newCompetitionCard[
                                                                    "team"]
                                                                .isYoung ||
                                                        check
                                                                    .category ==
                                                                CheckCategory
                                                                    .old &&
                                                            !newCompetitionCard[
                                                                    "team"]
                                                                .isYoung)
                                                    .toList()
                                                    .indexOf(check)][i],
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(1),
                                          UpperCaseTextFormatter(),
                                        ],
                                        decoration: InputDecoration(
                                          hintText: "${i + 1}",
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Zadejte odpověď";
                                          }
                                          return null;
                                        },
                                        onChanged: (value) {
                                          if (value.isNotEmpty) {
                                            FocusScope.of(context).nextFocus();
                                          }
                                        },
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
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
                        organization: newCompetitionCard["team"].organization,
                      ),
                      startSeconds: getStartSeconds(),
                      finishSeconds: getFinishSeconds(),
                      checks: [
                        for (DeafCheck check in selectedCompetition!.checks
                            .whereType<DeafCheck>()
                            .where((check) =>
                                check.category == CheckCategory.young &&
                                    newCompetitionCard["team"].isYoung ||
                                check.category == CheckCategory.old &&
                                    !newCompetitionCard["team"].isYoung))
                          DeafCheck(
                            number: check.number,
                            name: check.name,
                            type: check.type,
                            category: check.category,
                            questions: [
                              for (Question question in check.questions)
                                Question(
                                  number: question.number,
                                  penaltySeconds: question.penaltySeconds,
                                  correctAnswer: question.correctAnswer,
                                  answer:
                                      deafCheckDataTableTextEditingControllers[
                                              selectedCompetition!.checks
                                                  .whereType<DeafCheck>()
                                                  .where((element) =>
                                                      element.category ==
                                                              CheckCategory
                                                                  .young &&
                                                          newCompetitionCard[
                                                                  "team"]
                                                              .isYoung ||
                                                      element.category ==
                                                              CheckCategory
                                                                  .old &&
                                                          !newCompetitionCard[
                                                                  "team"]
                                                              .isYoung)
                                                  .toList()
                                                  .indexOf(
                                                      check)][question.number -
                                              1]
                                          .text,
                                ),
                            ],
                          ),
                        for (LiveCheck check in selectedCompetition!.checks
                            .whereType<LiveCheck>()
                            .where((check) =>
                                check.category == CheckCategory.young &&
                                    newCompetitionCard["team"].isYoung ||
                                check.category == CheckCategory.old &&
                                    !newCompetitionCard["team"].isYoung))
                          LiveCheck(
                            number: check.number,
                            name: check.name,
                            category: check.category,
                            type: check.type,
                            penaltySeconds: int.parse(
                                        liveCheckDataTableTextEditingControllers[
                                                selectedCompetition!.checks
                                                    .whereType<LiveCheck>()
                                                    .toList()
                                                    .indexOf(check)][0]
                                            .$1
                                            .text) *
                                    60 +
                                int.parse(
                                    liveCheckDataTableTextEditingControllers[
                                            selectedCompetition!.checks
                                                .whereType<LiveCheck>()
                                                .toList()
                                                .indexOf(check)][0]
                                        .$2
                                        .text),
                            waitSeconds: int.parse(
                                        liveCheckDataTableTextEditingControllers[
                                                selectedCompetition!.checks
                                                    .whereType<LiveCheck>()
                                                    .toList()
                                                    .indexOf(check)][1]
                                            .$1
                                            .text) *
                                    60 +
                                int.parse(
                                    liveCheckDataTableTextEditingControllers[
                                            selectedCompetition!.checks
                                                .whereType<LiveCheck>()
                                                .toList()
                                                .indexOf(check)][1]
                                        .$2
                                        .text),
                          ),
                      ],
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

                  Navigator.of(context).pop(true);
                }
              },
              child: const Text("Přidat"),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() {});
    }
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
                    child: Row(
                      children: [
                        Text(
                          "Počet karet: ${selectedCompetition!.cards.length}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Zbývá karet: ${selectedCompetition!.teams.length - selectedCompetition!.cards.length}",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
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
                          title: Text(
                            "${card.team.members[0].firstName} ${card.team.members[0].lastName}, ${card.team.members[1].firstName} ${card.team.members[1].lastName}",
                          ),
                          subtitle: Text(
                            card.team.organization,
                          ),
                          onTap: () {
                            viewCompetitionCardDialog(card);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
