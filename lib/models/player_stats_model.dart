class PlayerStatsModel {
  _SingleStats single = _SingleStats();
  _MultiStats multi = _MultiStats();

  PlayerStatsModel();

  PlayerStatsModel.fromApi(this.single, this.multi);
}

class _SingleStats {
  int totalPoints = 0;
  int roundsPlayed = 0;
  int perfectAnswers = 0;

  _SingleStats();

  _SingleStats.fromData(this.totalPoints, this.roundsPlayed, this.perfectAnswers);

  _SingleStats.fromObject(dynamic object){
    totalPoints = object['totalPoints'];
    roundsPlayed = object['roundsPlayed'];
    perfectAnswers = object['perfectAnswers'];
  }
}

class _MultiStats {
  int totalPoints = 0;
  int roundsPlayed = 0;
  int perfectAnswers = 0;
  int gamesPlayed = 0;
  int firstPlaces = 0;

  _MultiStats();

  _MultiStats.fromData(this.totalPoints, this.roundsPlayed, this.perfectAnswers,
      this.gamesPlayed, this.firstPlaces);

  _MultiStats.fromObject(dynamic object){
    totalPoints = object['totalPoints'];
    roundsPlayed = object['roundsPlayed'];
    perfectAnswers = object['perfectAnswers'];
    gamesPlayed = object['gamesPlayed'];
    firstPlaces = object['firstPlaces'];
  }
}