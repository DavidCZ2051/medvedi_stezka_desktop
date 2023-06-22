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
        "checks": checks.map((check) => check.toJson()).toList(),
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
            Check.fromJson(check as Map<String, dynamic>)
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
        category = json["category"];

  Team({
    required this.number,
    required this.category,
  });
}

class Check {
  int number;
  String name;
  CheckType type;

  Map<String, dynamic> toJson() => {
        "number": number,
        "name": name,
        "type": type.toString(),
      };

  Check.fromJson(Map<String, dynamic> json)
      : number = json["number"],
        name = json["name"],
        type = json["type"];

  Check({
    required this.number,
    required this.name,
    required this.type,
  });
}

class DeafCheck extends Check {
  List<Question> questions = [];

  DeafCheck({
    required super.number,
    required super.name,
    required super.type,
    required this.questions,
  });
}

class LiveCheck extends Check {
  int? penaltySeconds;

  LiveCheck({
    required super.number,
    required super.name,
    required super.type,
  });
}

class Question {
  int number;
  int penaltySeconds;
  String correctAnswer;
  String? answer;

  Question({
    required this.number,
    required this.penaltySeconds,
    required this.correctAnswer,
  });
}

class CompetitionCard {
  Team team;
  int waitSeconds;

  List<Check> checks = [];

  int get totalPenaltySeconds {
    int totalPenaltySeconds = 0;

    for (Check check in checks) {
      if (check is DeafCheck) {
        for (Question question in check.questions) {
          if (question.answer != question.correctAnswer) {
            totalPenaltySeconds += question.penaltySeconds;
          }
        }
      } else if (check is LiveCheck) {
        totalPenaltySeconds += check.penaltySeconds!;
      }
    }

    totalPenaltySeconds -= waitSeconds;

    return totalPenaltySeconds;
  }

  Map<String, dynamic> toJson() => {
        "team": team.toJson(),
        "waitSeconds": waitSeconds,
        "checks": checks.map((check) => check.toJson()).toList(),
      };

  CompetitionCard.fromJson(Map<String, dynamic> json)
      : team = Team.fromJson(json["team"]),
        waitSeconds = json["waitSeconds"],
        checks = json["checks"].map((check) => Check.fromJson(check)).toList();

  CompetitionCard({
    required this.team,
    required this.waitSeconds,
  });
}
