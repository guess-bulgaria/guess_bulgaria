class LobbySettings {
  bool? isPublic = false;
  List<int>? regions;
  int? maxRounds;
  int? answerTimeInSeconds;

  LobbySettings();

  LobbySettings.fromJson(dynamic object) {
    isPublic = object['isPublic'];
    regions = object['regions'];
    maxRounds = object['maxRounds'];
    answerTimeInSeconds = object['answerTimeInSeconds'];
  }

  dynamic toJson() {
    return {
      'isPublic': isPublic,
      'regions': regions,
      'maxRounds': maxRounds,
      'answerTimeInSeconds': answerTimeInSeconds
    };
  }
}
