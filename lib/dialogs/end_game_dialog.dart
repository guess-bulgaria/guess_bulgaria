import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:guess_bulgaria/components/badge.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/components/player_list.dart';

class EndGameDialog extends StatefulWidget {
  final dynamic players;
  final dynamic endGameStats;

  const EndGameDialog(this.players, this.endGameStats, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EndGameDialogState();
}

class _EndGameDialogState extends State<EndGameDialog> {
  final List<double> opacities = [0, 0, 0];


  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 150)).then((value) => setState(() => opacities[0] = 1));
    Future.delayed(const Duration(milliseconds: 550)).then((value) => setState(() => opacities[1] = 1));
    Future.delayed(const Duration(milliseconds: 950)).then((value) => setState(() => opacities[2] = 1));
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> multiStatsData = widget.endGameStats == null ? [] :
      [
        {
          'title': 'Изиграни рундове',
          'value': widget.endGameStats['roundsPlayed'][0],
          'plus': widget.endGameStats['roundsPlayed'][1],
          'image': "assets/icons/gamepad.svg"
        },
        {
          'title': 'Перфектни отговорени',
          'value': widget.endGameStats['perfectAnswers'][0],
          'plus': widget.endGameStats['perfectAnswers'][1],
          'icon': Icons.star
        },
        {
          'title': 'Общо спечелени точки',
          'value': widget.endGameStats['totalPoints'][0],
          'plus': widget.endGameStats['totalPoints'][1],
          'image': "assets/icons/location-dot.svg"
        },
        {
          'title': 'Изиграни игри',
          'value': widget.endGameStats['gamesPlayed'][0],
          'plus': widget.endGameStats['gamesPlayed'][1],
          'icon': Icons.play_circle_outline
        },
        {
          'title': 'Победи',
          'value': widget.endGameStats['firstPlaces'][0],
          'plus': widget.endGameStats['firstPlaces'][1],
          'image': "assets/icons/ranking-star.svg"
        },
        {'title': 'Процент спечелени игри', 'value': 0, 'icon': Icons.percent},
      ];

    return AlertDialog(
      contentPadding: const EdgeInsets.all(4),
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
          style: TextStyle(
              fontSize: 20, color: Theme.of(context).secondaryHeaderColor),
        ),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: SizedBox(
            height: double.maxFinite,
            width: double.maxFinite,
            child: PlayerList(widget.players, PlayerListTypes.gameResults),
          )),
          if(multiStatsData.isNotEmpty) Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              "Статистики",
              style: TextStyle(
                  fontSize: 20, color: Theme.of(context).secondaryHeaderColor),
            ),
          ),
          if(multiStatsData.isNotEmpty) Column(
            children: [
              for (int i = 0; i < 3; i++)
                AnimatedOpacity(
                  // If the widget is visible, animate to 0.0 (invisible).
                  // If the widget is hidden, animate to 1.0 (fully visible).
                  opacity: opacities[i],
                  duration: const Duration(milliseconds: 300),
                  // The green box must be a child of the AnimatedOpacity widget.
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int j = 0; j < 2; j++)
                        Expanded(
                          child: Badge(
                            title: multiStatsData[(i + i) + j]['title'],
                            value: multiStatsData[(i + i) + j]['value'],
                            plus: multiStatsData[(i + i) + j]['plus'],
                            icon: multiStatsData[(i + i) + j]['icon'],
                            image: multiStatsData[(i + i) + j]['image'],
                            startAnimation: opacities[i] == 1
                          ),
                        )
                    ],
                  ),
                )
            ],
          ),
        ],
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
    Navigator.of(context).pop(true);
  }

  void toLobby() {
    Navigator.of(context).pop();
  }
}
