const String appVersion = "1.0.0-DEV";

List<Competition> competitions = [
  Competition(
    type: CompetitionType.district,
    location: "Vratislavice",
    year: 2023,
  ),
];

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

  Competition({
    required this.type,
    required this.location,
    required this.year,
  });
}

class Team {
  int number;
  TeamCategory category;

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

  DeafCheck({
    required super.number,
    required super.name,
    required super.type,
    required this.questions,
  });
}

class Question {
  int number;
  int penaltySeconds;
  String correctAnswer;

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

  CompetitionCard({
    required this.team,
    required this.waitSeconds,
  });
}
