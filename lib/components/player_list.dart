import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:guess_bulgaria/configs/player_colors.dart';
import 'package:guess_bulgaria/storage/user_data.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PlayerList extends StatefulWidget {
  final List<dynamic> players;
  final double height;
  final PlayerListType type;

  const PlayerList(this.players, this.type, {Key? key, this.height = 100})
      : super(key: key);

  @override
  State<PlayerList> createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  final List<double> opacities = [];

  @override
  void initState() {
    super.initState();
    int dur = 150;
    for (int i = 0; i < widget.players.length; i++) {
      opacities.add(0);
      if (widget.type == PlayerListType.gameResults) {
        opacities.add(0);
        Future.delayed(Duration(milliseconds: dur))
            .then((value) => setState(() => opacities[i] = 1));
        dur += 250;
      } else {
        opacities.add(1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = generateRows(context);

    return ScrollablePositionedList.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index],
      padding: const EdgeInsets.only(bottom: 20),
    );
  }

  List<Widget> generateRows(BuildContext context) {
    switch (widget.type) {
      case PlayerListType.lobby:
        return lobby(context);
      case PlayerListType.gameResults:
      case PlayerListType.scoreboard:
        return scoreboard(context);
      default:
        return [];
    }
  }

  List<Widget> lobby(BuildContext context) {
    return widget.players
        .map((player) => Row(
              children: [
                Stack(children: [
                  Icon(Icons.circle,
                      color: PlayerColors.color(player['color']), size: 32),
                  Container(
                    margin: const EdgeInsets.only(top: 6, left: 6),
                    child:
                        Icon(player['isCreator'] ? Icons.star : null, size: 20),
                  ),
                ]),
                Text(
                  '${player['username'] ?? player['id']} ${player['id'] == UserData.userId ? '(Ти)' : ''}',
                  style: const TextStyle(fontSize: 26),
                ),
              ],
            ))
        .toList(growable: false);
  }

  List<Widget> scoreboard(BuildContext context) {
    int index = 0;
    widget.players.sort(((a, b) => b["points"] - a["points"]));

    return widget.players.map((player) {
      index++;
      int total = player["points"];
      int points = player["roundPoints"] ?? 0;
      return Container(
        margin: const EdgeInsets.only(bottom: 3.6),
        height: 20,
        child: AnimatedOpacity(
          opacity: opacities[index-1],
          duration: const Duration(milliseconds: 200),
          // The green box must be a child of the AnimatedOpacity widget.
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
                  child: widget.type == PlayerListType.gameResults
                      ? SvgPicture.asset(
                          'assets/icons/crown.svg',
                          height: 11,
                          color: Theme.of(context).secondaryHeaderColor,
                        )
                      : Text(
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
                      Text('$total', style: const TextStyle(fontSize: 13)),
                      if (widget.type != PlayerListType.gameResults)
                        Text(
                          points > 0 ? ' +$points' : '',
                          style: const TextStyle(fontSize: 10),
                        )
                    ],
                  )),
              if (widget.type != PlayerListType.gameResults)
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: player['hasAnswered'] == true
                      ? Theme.of(context).secondaryHeaderColor
                      : Theme.of(context).colorScheme.secondary,
                )
            ],
          ),
        ),
      );
    }).toList(growable: false);
  }
}

enum PlayerListType { lobby, gameResults, scoreboard }
