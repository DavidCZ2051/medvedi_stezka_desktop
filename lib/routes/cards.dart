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

  void createCompetitionCardDialog() {
    newCompetitionCard = {};
    biggestQuestionsCount = getBiggestQuestionsCount(
      selectedCompetition!.checks.whereType<DeafCheck>().toList(),
    );

    _newCompetitionCardStartHoursController.text = "";
    _newCompetitionCardStartMinutesController.text = "";
    _newCompetitionCardStartSecondsController.text = "";

    _newCompetitionCardFinishHoursController.text = "";
    _newCompetitionCardFinishMinutesController.text = "";
    _newCompetitionCardFinishSecondsController.text = "";

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
                  minWidth: 800,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
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
                                      .whereType<LiveCheck>())
                                    DataRow(
                                      cells: [
                                        DataCell(
                                          Text(
                                            "Ž${check.number} - ${check.name}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
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
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onChanged: (value) {
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
                                                    fontWeight: FontWeight.w500,
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
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onChanged: (value) {
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
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
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
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onChanged: (value) {
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
                                                    fontWeight: FontWeight.w500,
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
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onChanged: (value) {
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
                    const SizedBox(width: 8),
                    const SizedBox(
                      height: 400,
                      child: VerticalDivider(),
                    ),
                    const SizedBox(width: 8),
                    DataTable(
                      border: TableBorder.all(),
                      columns: [
                        for (DeafCheck check in selectedCompetition!.checks
                            .whereType<DeafCheck>())
                          DataColumn(
                            label: Text(
                              "H${check.number} - ${check.name}",
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
                                  .whereType<DeafCheck>())
                                DataCell(
                                  // TODO: add fields
                                  Text(check.questions[i].correctAnswer),
                                ),
                            ],
                          ),
                      ],
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
                      team: Team(
                        // team number is assigned here
                        number: newCompetitionCard["teamNumber"],
                        category: newCompetitionCard["team"].category,
                        members: newCompetitionCard["team"].members,
                        organization: newCompetitionCard["team"].organization,
                      ),
                      startSeconds: getStartSeconds(),
                      finishSeconds: getFinishSeconds(),
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
        ),
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
