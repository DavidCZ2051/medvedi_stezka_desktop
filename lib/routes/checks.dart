// packages
import 'package:flutter/material.dart';
// files
import 'package:medvedi_stezka/globals.dart';
import 'package:medvedi_stezka/functions.dart';

class Checks extends StatefulWidget {
  const Checks({super.key});

  @override
  State<Checks> createState() => _ChecksState();
}

class _ChecksState extends State<Checks> {
  final _newCheckFormKey = GlobalKey<FormState>();

  Map<String, dynamic> newCheck = {};

  bool isCheckNumberOccupied(int number) {
    for (Check check in selectedCompetition!.checks) {
      if (check.number == number) {
        return true;
      }
    }
    return false;
  }

  void mySetState() {
    setState(() {});
  }

  viewDeafCheckDetails(DeafCheck check) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${check.number}. ${check.name}"),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 325),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Počet otázek: ${check.questions.length}",
                  style: const TextStyle(fontSize: 18),
                ),
                const Divider(),
                for (Question question in check.questions)
                  ListTile(
                    title: Row(
                      children: [
                        Text(
                          "Otázka ${question.number}",
                          style: const TextStyle(fontSize: 20),
                        ),
                        const Spacer(),
                        Text(
                          formatTime(question.penaltySeconds),
                          style: const TextStyle(fontSize: 20),
                        ),
                        const Spacer(),
                        Text(
                          "\"${question.correctAnswer}\"",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
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
            child: const Text("Zavřít"),
          ),
        ],
      ),
    );
  }

  void createCheckDialog() {
    newCheck = {};
    newCheck["questions"] = [];
    newCheck["penaltySeconds"] = 0;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Přidat kontrolu"),
          content: Form(
            key: _newCheckFormKey,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 325),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    DropdownButtonFormField(
                      decoration: const InputDecoration(
                        labelText: "Typ kontroly",
                      ),
                      value: newCheck["type"],
                      items: [
                        DropdownMenuItem(
                          value: CheckType.deaf,
                          child: Text("${CheckType.deaf}"),
                        ),
                        DropdownMenuItem(
                          value: CheckType.live,
                          child: Text("${CheckType.live}"),
                        ),
                      ],
                      validator: (value) {
                        if (value == null) {
                          return "Vyberte typ kontroly";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          newCheck["type"] = value;
                        });
                      },
                      onSaved: (value) {
                        setState(() {
                          newCheck["type"] = value;
                        });
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Název kontroly",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Zadejte název kontroly";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() {
                          newCheck["name"] = value;
                        });
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: "Číslo kontroly",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Zadejte číslo kontroly";
                        } else if (int.tryParse(value) == null) {
                          return "Zadejte platné číslo";
                        } else if (isCheckNumberOccupied(int.parse(value))) {
                          return "Toto číslo je již obsazené";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        setState(() {
                          newCheck["number"] = int.parse(value!);
                        });
                      },
                    ),
                    if (newCheck["type"] == CheckType.deaf)
                      Column(
                        children: [
                          const Divider(),
                          OutlinedButton(
                            onPressed: () async {
                              TimeOfDay? time = await showTimePicker(
                                context: context,
                                cancelText: "Zrušit",
                                confirmText: "Potvrdit",
                                errorInvalidText: "Zadejte platný čas",
                                hourLabelText: "Minuty",
                                minuteLabelText: "Sekundy",
                                helpText: "Vyberte trestný čas",
                                initialEntryMode: TimePickerEntryMode.input,
                                initialTime: const TimeOfDay(
                                  hour: 0,
                                  minute: 30,
                                ),
                              );
                              if (time != null) {
                                setState(() {
                                  newCheck["penaltySeconds"] =
                                      time.hour * 60 + time.minute;
                                });
                              }
                            },
                            child: Text(
                                "Trestný čas: ${formatTime(newCheck["penaltySeconds"])}"),
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Počet otázek",
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Zadejte počet otázek";
                              } else if (int.tryParse(value) == null) {
                                return "Zadejte platné číslo";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                newCheck["questionCount"] = int.tryParse(value);
                              });
                            },
                            onSaved: (value) {
                              setState(() {
                                newCheck["questionCount"] = int.parse(value!);
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          if (newCheck["questionCount"].runtimeType == int)
                            Column(
                              children: [
                                for (int i = 1;
                                    i <= newCheck["questionCount"];
                                    i++)
                                  ListTile(
                                    title: Text("Otázka $i"),
                                    trailing: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 160,
                                      ),
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          hintText: "Správná odpověď",
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Zadejte správnou odpověď";
                                          }
                                          return null;
                                        },
                                        onSaved: (value) {
                                          setState(() {
                                            newCheck["questions"].add(
                                              {
                                                "number": i,
                                                "correctAnswer": value,
                                              },
                                            );
                                          });
                                        },
                                      ),
                                    ),
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
                if (_newCheckFormKey.currentState!.validate()) {
                  _newCheckFormKey.currentState!.save();

                  selectedCompetition!.checks.add(
                    newCheck["type"] == CheckType.deaf
                        ? DeafCheck(
                            number: newCheck["number"],
                            name: newCheck["name"],
                            type: CheckType.deaf,
                            questions: [
                              for (Map question in newCheck["questions"])
                                Question(
                                  number: question["number"],
                                  correctAnswer: question["correctAnswer"],
                                  penaltySeconds: newCheck["penaltySeconds"],
                                ),
                            ],
                          )
                        : Check(
                            number: newCheck["number"],
                            name: newCheck["name"],
                            type: CheckType.live,
                          ),
                  );

                  selectedCompetition!.checks.sort(
                    (a, b) => a.number.compareTo(b.number),
                  );

                  setState(() {});
                  mySetState();
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
        heroTag: "createCheck",
        tooltip: "Přidat kontrolu",
        onPressed: createCheckDialog,
        child: const Icon(Icons.add),
      ),
      body: selectedCompetition!.checks.isEmpty
          ? const Center(
              child: Text(
                "Zatím žádné kontroly...",
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
                      "Počet kontrol: ${selectedCompetition!.checks.length}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Živé kontroly:",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  for (Check check in selectedCompetition!.checks.where(
                    (check) => check.type == CheckType.live,
                  ))
                    Card(
                      child: ListTile(
                        leading: Text(
                          "${check.number}",
                          style: const TextStyle(fontSize: 20),
                        ),
                        title: Text(check.name),
                      ),
                    ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Hluché kontroly:",
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  for (Check check in selectedCompetition!.checks.where(
                    (check) => check.type == CheckType.deaf,
                  ))
                    Card(
                      child: ListTile(
                        leading: Text(
                          "${check.number}",
                          style: const TextStyle(fontSize: 20),
                        ),
                        title: Text(
                          check.name,
                          style: const TextStyle(fontSize: 20),
                        ),
                        subtitle: Text(
                          "${(check as DeafCheck).questions.length} otázek",
                        ),
                        onTap: () {
                          viewDeafCheckDetails(check);
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
