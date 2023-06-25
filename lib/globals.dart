const String appVersion = "1.0.0-DEV";

List<Competition> competitions = [];

Competition? selectedCompetition;

enum TeamCategory {
  one,
  two,
  three,
  four,
  grownup;

  @override
  String toString() {
    switch (this) {
      case TeamCategory.one:
        return "I.";
      case TeamCategory.two:
        return "II.";
      case TeamCategory.three:
        return "III.";
      case TeamCategory.four:
        return "IV.";
      case TeamCategory.grownup:
        return "Dorost";
    }
  }

  static TeamCategory? fromString(String string) {
    switch (string) {
      case "I.":
        return TeamCategory.one;
      case "II.":
        return TeamCategory.two;
      case "III.":
        return TeamCategory.three;
      case "IV.":
        return TeamCategory.four;
      case "Dorost":
        return TeamCategory.grownup;
    }
    return null;
  }
}

enum CompetitionType {
  district,
  region,
  nation;

  @override
  String toString() {
    switch (this) {
      case CompetitionType.district:
        return "Okresní";
      case CompetitionType.region:
        return "Krajské";
      case CompetitionType.nation:
        return "Republikové";
    }
  }

  static CompetitionType? fromString(String string) {
    switch (string) {
      case "Okresní":
        return CompetitionType.district;
      case "Krajské":
        return CompetitionType.region;
      case "Republikové":
        return CompetitionType.nation;
    }
    return null;
  }
}

enum CheckType {
  deaf,
  live;

  @override
  String toString() {
    switch (this) {
      case CheckType.deaf:
        return "Hluchá";
      case CheckType.live:
        return "Živá";
    }
  }

  static CheckType? fromString(String string) {
    switch (string) {
      case "Hluchá":
        return CheckType.deaf;
      case "Živá":
        return CheckType.live;
    }
    return null;
  }
}

class Competition {
  CompetitionType type;
  String location;
  int year;

  List<Team> teams = [];
  List<Check> checks = [];
  List<CompetitionCard> cards = [];

  Map<String, dynamic> toJson() => {
        "type": type.toString(),
        "location": location,
        "year": year,
        "teams": teams.map((team) => team.toJson()).toList(),
        "checks": [
          for (Check check in checks)
            if (check is DeafCheck)
              check.toJson()
            else if (check is LiveCheck)
              check.toJson()
        ],
        "cards": cards.map((card) => card.toJson()).toList(),
      };

  Competition.fromJson(Map<String, dynamic> json)
      : type = CompetitionType.fromString(json["type"])!,
        location = json["location"],
        year = json["year"],
        teams = [
          for (Map team in json["teams"])
            Team.fromJson(team as Map<String, dynamic>)
        ],
        checks = [
          for (Map check in json["checks"])
            if (check["type"] == "Hluchá")
              DeafCheck.fromJson(check as Map<String, dynamic>)!
            else
              LiveCheck.fromJson(check as Map<String, dynamic>)!
        ],
        cards = [
          for (Map card in json["cards"])
            CompetitionCard.fromJson(card as Map<String, dynamic>)
        ];

  Competition({
    required this.type,
    required this.location,
    required this.year,
  });
}

class Team {
  int number;
  TeamCategory category;

  Map<String, dynamic> toJson() => {
        "number": number,
        "category": category.toString(),
      };

  Team.fromJson(Map<String, dynamic> json)
      : number = json["number"],
        category = TeamCategory.fromString(json["category"])!;

  Team({
    required this.number,
    required this.category,
  });
}

class Check {
  int number;
  String name;
  CheckType type;

  Check({
    required this.number,
    required this.name,
    required this.type,
  });
}

class DeafCheck extends Check {
  List<Question> questions = [];

  Map<String, dynamic> toJson() => {
        "number": number,
        "name": name,
        "type": type.toString(),
        "questions": questions.map((question) => question.toJson()).toList(),
      };

  static DeafCheck? fromJson(Map<String, dynamic> json) {
    return DeafCheck(
      number: json["number"],
      name: json["name"],
      type: CheckType.fromString(json["type"])!,
      questions: [
        for (Map question in json["questions"])
          Question(
            number: question["number"],
            penaltySeconds: question["penaltySeconds"],
            correctAnswer: question["correctAnswer"],
          ),
      ],
    );
  }

  DeafCheck({
    required super.number,
    required super.name,
    required super.type,
    required this.questions,
  });
}

class LiveCheck extends Check {
  int? penaltySeconds;

  Map<String, dynamic> toJson() => {
        "number": number,
        "name": name,
        "type": type.toString(),
        "penaltySeconds": penaltySeconds,
      };

  static LiveCheck? fromJson(Map<String, dynamic> json) {
    return LiveCheck(
      number: json["number"],
      name: json["name"],
      type: CheckType.fromString(json["type"])!,
      penaltySeconds: json["penaltySeconds"],
    );
  }

  LiveCheck({
    required super.number,
    required super.name,
    required super.type,
    this.penaltySeconds,
  });
}

class Question {
  int number;
  int penaltySeconds;
  String correctAnswer;
  String? answer;

  Map<String, dynamic> toJson() => {
        "number": number,
        "penaltySeconds": penaltySeconds,
        "correctAnswer": correctAnswer,
      };

  Question({
    required this.number,
    required this.penaltySeconds,
    required this.correctAnswer,
  });
}

class CompetitionCard {
  Team team;
  int waitSeconds;
  DateTime start;
  DateTime end;

  List<Check> checks = [];

  int getTotalSeconds() {
    int totalSeconds = 0;

    // start - end
    totalSeconds += end.difference(start).inSeconds;

    // checks
    for (Check check in checks) {
      if (check is DeafCheck) {
        for (Question question in check.questions) {
          if (question.answer != question.correctAnswer) {
            totalSeconds += question.penaltySeconds;
          }
        }
      } else if (check is LiveCheck) {
        totalSeconds += check.penaltySeconds ?? 0;
      }
    }

    // wait time
    totalSeconds -= waitSeconds;

    return totalSeconds;
  }

  Map<String, dynamic> toJson() => {
        "team": team.toJson(),
        "start": start,
        "end": end,
        "waitSeconds": waitSeconds,
        "checks": [
          for (Check check in checks)
            if (check is DeafCheck)
              check.toJson()
            else if (check is LiveCheck)
              check.toJson()
        ]
      };

  CompetitionCard.fromJson(Map<String, dynamic> json)
      : team = Team.fromJson(json["team"]),
        waitSeconds = json["waitSeconds"],
        checks = [
          for (Map check in json["checks"])
            if (check["type"] == "Hluchá")
              DeafCheck.fromJson(check as Map<String, dynamic>)!
            else
              LiveCheck.fromJson(check as Map<String, dynamic>)!
        ],
        start = json["start"],
        end = json["ends"];

  CompetitionCard({
    required this.team,
    required this.waitSeconds,
    required this.start,
    required this.end,
  });
}
