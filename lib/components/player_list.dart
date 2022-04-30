import 'package:flutter/material.dart';
import 'package:guess_bulgaria/configs/player_colors.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class PlayerList extends StatelessWidget {
  final List<dynamic> players;

  const PlayerList(this.players, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];
    for (var player in players) {
      rows.add(Row(
        children: [
          Stack(children: [
            Icon(Icons.circle, color: PlayerColors.color(player['color'])),
            Icon(player['isCreator'] ? Icons.check : null, size: 24),
          ]),
          Text(player['username'] ?? player['id']),
        ],
      ));
    }
    return SizedBox(
        height: 100,
        child: ScrollablePositionedList.builder(
          itemCount: rows.length,
          itemBuilder: (context, index) => rows[index],
          padding: const EdgeInsets.only(bottom: 20),
        ));
  }
}
