import 'dart:convert';

class PlayerStatsModel {
  SingleStats single = SingleStats();
  MultiStats multi = MultiStats();

  PlayerStatsModel();

  PlayerStatsModel.fromApi(this.single, this.multi);
}

class SingleStats {
  int totalPoints = 0;
  int roundsPlayed = 0;
  int perfectAnswers = 0;

  SingleStats();

  SingleStats.fromData(
      this.totalPoints, this.roundsPlayed, this.perfectAnswers);

  SingleStats.fromJson(dynamic object) {
    totalPoints = object['totalPoints'];
    roundsPlayed = object['roundsPlayed'];
    perfectAnswers = object['perfectAnswers'];
  }

  String toJson() {
    dynamic resp = {};
    resp['totalPoints'] = totalPoints;
    resp['roundsPlayed'] = roundsPlayed;
    resp['perfectAnswers'] = perfectAnswers;
    return jsonEncode(resp);
  }
}

class MultiStats {
  int totalPoints = 0;
  int roundsPlayed = 0;
  int perfectAnswers = 0;
  int gamesPlayed = 0;
  int firstPlaces = 0;

  MultiStats();

  MultiStats.fromData(this.totalPoints, this.roundsPlayed, this.perfectAnswers,
      this.gamesPlayed, this.firstPlaces);

  MultiStats.fromJson(dynamic object) {
    totalPoints = object['totalPoints'];
    roundsPlayed = object['roundsPlayed'];
    perfectAnswers = object['perfectAnswers'];
    gamesPlayed = object['gamesPlayed'];
    firstPlaces = object['firstPlaces'];
  }

  String toJson() {
    dynamic resp = {};
    resp['totalPoints'] = totalPoints;
    resp['roundsPlayed'] = roundsPlayed;
    resp['perfectAnswers'] = perfectAnswers;
    resp['gamesPlayed'] = gamesPlayed;
    resp['firstPlaces'] = firstPlaces;
    return jsonEncode(resp);
  }
}
