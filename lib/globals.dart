// packages
import 'package:flutter/services.dart';

const String appVersion = "1.0.0-DEV";

List<Competition> competitions = [];

Competition? selectedCompetition;

enum DeafCheckCategory {
  young, // 1-2
  old; // 3-5

  @override
  String toString() {
    switch (this) {
      case DeafCheckCategory.young:
        return "Mladší";
      case DeafCheckCategory.old:
        return "Starší";
    }
  }

  static DeafCheckCategory? fromString(String string) {
    switch (string) {
      case "Mladší":
        return DeafCheckCategory.young;
      case "Starší":
        return DeafCheckCategory.old;
    }
    return null;
  }
}

enum TeamCategory {
  one,
  twoFemale,
  twoMale,
  threeFemale,
  threeMale,
  fourFemale,
  fourMale,
  grownupFemale,
  grownupMale;

  @override
  String toString() {
    switch (this) {
      case TeamCategory.one:
        return "Mladší I";
      case TeamCategory.twoFemale:
        return "Mladší žákyně II";
      case TeamCategory.twoMale:
        return "Mladší žáci II";
      case TeamCategory.threeFemale:
        return "Starší žákyně III";
      case TeamCategory.threeMale:
        return "Starší žáci III";
      case TeamCategory.fourFemale:
        return "Starší žákyně IV";
      case TeamCategory.fourMale:
        return "Starší žáci IV";
      case TeamCategory.grownupFemale:
        return "Dorostenky";
      case TeamCategory.grownupMale:
        return "Dorostenci";
    }
  }

  static TeamCategory? fromString(String string) {
    switch (string) {
      case "Mladší I":
        return TeamCategory.one;
      case "Mladší žákyně II":
        return TeamCategory.twoFemale;
      case "Mladší žáci II":
        return TeamCategory.twoMale;
      case "Starší žákyně III":
        return TeamCategory.threeFemale;
      case "Starší žáci III":
        return TeamCategory.threeMale;
      case "Starší žákyně IV":
        return TeamCategory.fourFemale;
      case "Starší žáci IV":
        return TeamCategory.fourMale;
      case "Dorostenky":
        return TeamCategory.grownupFemale;
      case "Dorostenci":
        return TeamCategory.grownupMale;
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

  List<String> organizations = [];
  List<Team> teams = [];
  List<Check> checks = [];
  List<CompetitionCard> cards = [];

  Map<String, dynamic> toJson() => {
        "type": type.toString(),
        "location": location,
        "year": year,
        "teams": <Map>[
          for (Team team in teams) team.toJson(),
        ],
        "checks": <Map>[
          for (Check check in checks)
            if (check is DeafCheck)
              check.toJson()
            else if (check is LiveCheck)
              check.toJson()
        ],
        "cards": <Map>[
          for (CompetitionCard card in cards) card.toJson(),
        ],
        "organizations": organizations,
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
        ],
        organizations = [
          for (String organization in json["organizations"]) organization
        ];

  int getPlace(CompetitionCard card) {
    int position = 0;
    return position;
  }

  Competition({
    required this.type,
    required this.location,
    required this.year,
  });
}

class TeamMember {
  String firstName;
  String lastName;
  int birthYear;

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "birthYear": birthYear,
      };

  TeamMember.fromJson(Map<String, dynamic> json)
      : firstName = json["firstName"],
        lastName = json["lastName"],
        birthYear = json["birthYear"];

  TeamMember({
    required this.firstName,
    required this.lastName,
    required this.birthYear,
  });
}

class Team {
  int number;
  String organization;
  TeamCategory category;
  List<TeamMember> members = [];

  Map<String, dynamic> toJson() => {
        "number": number,
        "organization": organization,
        "category": category.toString(),
        "members": <Map>[
          for (TeamMember member in members) member.toJson(),
        ]
      };

  Team.fromJson(Map<String, dynamic> json)
      : number = json["number"],
        organization = json["organization"],
        category = TeamCategory.fromString(json["category"])!,
        members = [
          for (Map member in json["members"])
            TeamMember.fromJson(member as Map<String, dynamic>)
        ];

  bool get isYoung {
    return [TeamCategory.one, TeamCategory.twoFemale, TeamCategory.twoMale]
        .contains(category);
  }

  Team({
    required this.number,
    required this.category,
    required this.organization,
    required this.members,
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
  DeafCheckCategory category;

  Map<String, dynamic> toJson() => {
        "number": number,
        "name": name,
        "category": category.toString(),
        "type": type.toString(),
        "questions": <Map>[
          for (Question question in questions) question.toJson(),
        ]
      };

  static DeafCheck? fromJson(Map<String, dynamic> json) {
    return DeafCheck(
      number: json["number"],
      name: json["name"],
      category: DeafCheckCategory.fromString(json["category"])!,
      type: CheckType.fromString(json["type"])!,
      questions: <Question>[
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
    required this.category,
    required this.questions,
  });
}

class LiveCheck extends Check {
  int? penaltySeconds;
  int? waitSeconds;

  Map<String, dynamic> toJson() => {
        "number": number,
        "name": name,
        "type": type.toString(),
        "penaltySeconds": penaltySeconds,
        "waitSeconds": waitSeconds,
      };

  static LiveCheck? fromJson(Map<String, dynamic> json) {
    return LiveCheck(
      number: json["number"],
      name: json["name"],
      type: CheckType.fromString(json["type"])!,
      penaltySeconds: json["penaltySeconds"],
      waitSeconds: json["waitSeconds"],
    );
  }

  LiveCheck({
    required super.number,
    required super.name,
    required super.type,
    this.penaltySeconds,
    this.waitSeconds,
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
  int startSeconds;
  int finishSeconds;

  List<Check> checks = [];

  Map<String, dynamic> toJson() => {
        "team": team.toJson(),
        "startSeconds": startSeconds,
        "finishSeconds": finishSeconds,
        "checks": <Map>[
          for (Check check in checks)
            if (check is DeafCheck)
              check.toJson()
            else if (check is LiveCheck)
              check.toJson()
        ]
      };

  CompetitionCard.fromJson(Map<String, dynamic> json)
      : team = Team.fromJson(json["team"]),
        checks = [
          for (Map check in json["checks"])
            if (check["type"] == "Hluchá")
              DeafCheck.fromJson(check as Map<String, dynamic>)!
            else
              LiveCheck.fromJson(check as Map<String, dynamic>)!
        ],
        startSeconds = json["startSeconds"],
        finishSeconds = json["finishSeconds"];

  int getTotalWaitSeconds() {
    int totalWaitSeconds = 0;
    for (Check check in checks) {
      if (check is LiveCheck) {
        totalWaitSeconds += check.waitSeconds ?? 0;
      }
    }
    return totalWaitSeconds;
  }

  int getTotalPenaltySeconds() {
    int totalPenaltySeconds = 0;
    for (Check check in checks) {
      if (check is DeafCheck) {
        for (Question question in check.questions) {
          if (question.answer != question.correctAnswer) {
            totalPenaltySeconds += question.penaltySeconds;
          }
        }
      } else if (check is LiveCheck) {
        totalPenaltySeconds += check.penaltySeconds ?? 0;
      }
    }
    return totalPenaltySeconds;
  }

  int getTotalSeconds() {
    int totalSeconds = 0;
    totalSeconds += finishSeconds - startSeconds;
    totalSeconds += getTotalPenaltySeconds();
    totalSeconds -= getTotalWaitSeconds();
    return totalSeconds;
  }

  CompetitionCard({
    required this.team,
    required this.startSeconds,
    required this.finishSeconds,
  });
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
