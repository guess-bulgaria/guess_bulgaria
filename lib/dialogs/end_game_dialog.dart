import 'package:flutter/material.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/components/player_list.dart';

class EndGameDialog extends StatefulWidget {
  final dynamic players;

  const EndGameDialog(this.players, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EndGameDialogState();
}

class _EndGameDialogState extends State<EndGameDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(40.0),
        ),
      ),
      title: Align(
        alignment: Alignment.center,
        child: Text(
          "Резултати",
          style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        ),
      ),
      content: SizedBox(
        height: double.maxFinite,
        width: double.maxFinite,
        child: PlayerList(widget.players, PlayerListTypes.gameResults),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: NavigationButton(
                  text: "Начална\nстраница",
                  icon: Icons.home,
                  onPressed: endGame,
                ),
              ),
              const VerticalDivider(width: 8),
              Expanded(
                child: NavigationButton(
                  text: "Върни се\nв лобито",
                  icon: Icons.subdirectory_arrow_left,
                  onPressed: toLobby,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void endGame() {
    // TODO: stats
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }

  void toLobby() {
    // TODO: pop until the lobby
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }
}
