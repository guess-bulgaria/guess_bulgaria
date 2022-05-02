import 'package:flutter/material.dart';
import 'package:guess_bulgaria/configs/player_colors.dart';
import 'package:guess_bulgaria/storage/user_data.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PlayerList extends StatelessWidget {
  final List<dynamic> players;
  final double height;
  final PlayerListTypes type;

  const PlayerList(this.players, this.type, {Key? key, this.height = 100})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = generateRows(type);

    return ScrollablePositionedList.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index],
      padding: const EdgeInsets.only(bottom: 20),
    );
  }

  List<Widget> generateRows(PlayerListTypes type) {
    switch (type) {
      case PlayerListTypes.lobby:
        return lobby();
      case PlayerListTypes.gameResults:
        return endGameResults();
      case PlayerListTypes.scoreboard:
        return scoreboard();
      default:
        return [];
    }
  }

  List<Widget> lobby() {
    List<Widget> rows = [];
    for (var player in players) {
      rows.add(Row(
        children: [
          Stack(children: [
            Icon(Icons.circle,
                color: PlayerColors.color(player['color']), size: 32),
            Container(
              margin: const EdgeInsets.only(top: 6, left: 6),
              child: Icon(player['isCreator'] ? Icons.star : null, size: 20),
            ),
          ]),
          Text(
            '${player['username'] ?? player['id']} ${player['id'] == UserData.userId ? '(Ти)' : ''}',
            style: const TextStyle(fontSize: 26),
          ),
        ],
      ));
    }
    return rows;
  }

  List<Widget> endGameResults() {
    List<Widget> rows = [];

    players.sort(((a, b) => b["points"] - a["points"]));
    int index = 1;
    for (var player in players) {
      rows.add(Row(
        children: [
          Stack(children: [
            Icon(Icons.circle, color: PlayerColors.color(player['color'])),
            Icon(player['isCreator'] ? Icons.check : null, size: 24),
          ]),
          Text('$index.'),
          Text(player['username'] ?? player['id']),
          const Text(" - "),
          Text(player["points"].toString()),
          if (index == 1)
            Image.asset(
              "assets/icons/gold_medal.png",
              width: 30,
              height: 30,
            ),
          if (index == 2)
            Image.asset(
              "assets/icons/silver_medal.png",
              width: 30,
              height: 30,
            ),
          if (index == 3)
            Image.asset(
              "assets/icons/bronze_medal.png",
              width: 30,
              height: 28,
            ),
        ],
      ));
      index++;
    }
    return rows;
  }

  List<Widget> scoreboard() {
    List<Widget> rows = [];
    //players.sort(((a, b) => b["points"] - a["points"]));
    int index = 1;
    for (var player in players) {
      int total = player["points"];
      //todo get points for current round
      int points = 1000;
      rows.add(Row(
        children: [
          Icon(Icons.circle,
              color: PlayerColors.color(player['color']), size: 20),
          Text('$index.'),
          Container(
            constraints: const BoxConstraints(maxWidth: 70),
            child: Text(
              '${player['username'] ?? player['id']}',
              style: const TextStyle(fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(' $total'),
          Text(' (+$points)'),
        ],
      ));
      index++;
    }
    return rows;
  }
}

enum PlayerListTypes { lobby, gameResults, scoreboard }
