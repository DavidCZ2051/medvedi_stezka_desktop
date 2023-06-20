// packages
import 'package:flutter/material.dart';
// files
import 'package:medvedi_stezka/globals.dart';

class Competitions extends StatefulWidget {
  const Competitions({super.key});

  @override
  State<Competitions> createState() => _CompetitionsState();
}

class _CompetitionsState extends State<Competitions> {
  final _newCompetitionFormKey = GlobalKey<FormState>();

  Map<String, dynamic> newCompetition = {};

  void showDataDialog() {}

  void createCompetitionDialog() {
    newCompetition = {};
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Přidat soutěž"),
        content: Form(
          key: _newCompetitionFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: "Typ soutěže",
                  ),
                  value: newCompetition["type"],
                  items: [
                    DropdownMenuItem(
                      value: CompetitionType.district,
                      child: Text("${CompetitionType.district}"),
                    ),
                    DropdownMenuItem(
                      value: CompetitionType.region,
                      child: Text("${CompetitionType.region}"),
                    ),
                    DropdownMenuItem(
                      value: CompetitionType.nation,
                      child: Text("${CompetitionType.nation}"),
                    ),
                  ],
                  validator: (value) {
                    if (value == null) {
                      return "Vyberte typ soutěže";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      newCompetition["type"] = value;
                    });
                  },
                  onSaved: (value) {
                    setState(() {
                      newCompetition["type"] = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Místo konání",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Zadejte místo konání";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      newCompetition["location"] = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Rok",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Zadejte rok";
                    } else if (int.tryParse(value) == null) {
                      return "Zadejte platné číslo";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      newCompetition["year"] = int.parse(value!);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Zrušit"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          OutlinedButton(
            onPressed: () {
              if (_newCompetitionFormKey.currentState!.validate()) {
                _newCompetitionFormKey.currentState!.save();

                competitions.add(
                  Competition(
                    type: newCompetition["type"],
                    location: newCompetition["location"],
                    year: newCompetition["year"],
                  ),
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
        heroTag: "createCompetition",
        tooltip: "Vytvořit soutěž",
        onPressed: createCompetitionDialog,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: showDataDialog,
            tooltip: "Zobrazit data",
            icon: const Icon(Icons.data_object),
            color: Colors.white,
            // TODO
          ),
        ],
        title: const Text(
          "Seznam soutěží",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: competitions.isEmpty
            ? const Text(
                "Zatím žádná soutěž...",
                style: TextStyle(
                  fontSize: 24,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    for (Competition competition in competitions)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.emoji_events),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          title: Text(
                            "${competition.year} ${competition.location}",
                          ),
                          subtitle: Text(competition.type.toString()),
                          onTap: () {
                            selectedCompetition = competition;
                            Navigator.pushNamed(context, "/competition");
                          },
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
