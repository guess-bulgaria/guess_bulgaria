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
    List<Widget> rows = generateRows(type, context);

    return ScrollablePositionedList.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index],
      padding: const EdgeInsets.only(bottom: 20),
    );
  }

  List<Widget> generateRows(PlayerListTypes type, BuildContext context) {
    switch (type) {
      case PlayerListTypes.lobby:
        return lobby(context);
      case PlayerListTypes.gameResults:
        return endGameResults(context);
      case PlayerListTypes.scoreboard:
        return scoreboard(context);
      default:
        return [];
    }
  }

  List<Widget> lobby(BuildContext context) {
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

  List<Widget> endGameResults(BuildContext context) {
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

  List<Widget> scoreboard(BuildContext context) {
    List<Widget> rows = [];
    players.sort(((a, b) => b["points"] - a["points"]));
    int index = 1;
    for (var player in players) {
      int total = player["points"];
      int points = player["roundPoints"] ?? 0;
      rows.add(Container(
        margin: const EdgeInsets.only(bottom: 3.6),
        height: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 17,
              height: 17,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: PlayerColors.color(player['color']),
                borderRadius: BorderRadius.circular(180.0),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: 100,
                child: FittedBox(
                  alignment: Alignment.bottomLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${player['username'] ?? player['id']}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                margin: const EdgeInsets.only(right: 4),
              ),
            ),
            Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Icon(Icons.star,
                        size: 12,
                        color: Theme.of(context).secondaryHeaderColor),
                    Text('$total ${points > 0 ? '(+$points)' : ''}',
                        style: const TextStyle(fontSize: 13)),
                  ],
                )),
            Icon(
              Icons.check_circle,
              size: 16,
              color: player['hasAnswered'] == true
                  ? Theme.of(context).secondaryHeaderColor
                  : Theme.of(context).colorScheme.secondary,
            )
          ],
        ),
      ));
      index++;
    }
    return rows;
  }
}

enum PlayerListTypes { lobby, gameResults, scoreboard }
