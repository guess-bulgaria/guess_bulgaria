import 'package:flutter/material.dart';
import 'package:guess_bulgaria/components/badge.dart';
import 'package:guess_bulgaria/components/board.dart';
import 'package:guess_bulgaria/components/scrolling_background.dart';
import 'package:guess_bulgaria/storage/user_data.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final List<Widget> singleStats = [];
  final List<Widget> multiStats = [];

  @override
  Widget build(BuildContext context) {
    final List<dynamic> singleStatsData = [
      {
        'title': 'Изиграни рундове',
        'value': UserData.stats.single.roundsPlayed,
        'image': "assets/icons/gamepad.svg"
      },
      {
        'title': 'Перфектни отговора',
        'value': UserData.stats.single.perfectAnswers,
        'icon': Icons.star
      },
      {
        'title': 'Общо спечелени точки',
        'value': UserData.stats.single.totalPoints,
        'image': "assets/icons/location-dot.svg"
      },
    ];
    final gamesPlayed = UserData.stats.multi.gamesPlayed;
    final winRate = UserData.stats.multi.firstPlaces /
        (gamesPlayed == 0 ? 1 : gamesPlayed) *
        100;
    final List<dynamic> multiStatsData = [
      {
        'title': 'Изиграни рундове',
        'value': UserData.stats.multi.roundsPlayed,
        'image': "assets/icons/gamepad.svg"
      },
      {
        'title': 'Перфектни отговора',
        'value': UserData.stats.multi.perfectAnswers,
        'icon': Icons.star
      },
      {
        'title': 'Общо спечелени точки',
        'value': UserData.stats.multi.totalPoints,
        'image': "assets/icons/location-dot.svg"
      },
      {
        'title': 'Изиграни игри',
        'value': gamesPlayed,
        'icon': Icons.play_circle_outline
      },
      {
        'title': 'Победи',
        'value': UserData.stats.multi.firstPlaces,
        'image': "assets/icons/ranking-star.svg"
      },
      {
        'title': 'Процент спечелени игри',
        'value': winRate.toStringAsFixed(2),
        'icon': Icons.percent
      },
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          const ScrollingBackground(),
          Board(
            title: "Статистики",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(top: 4),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Icon(Icons.person,
                //           color: Theme.of(context).secondaryHeaderColor),
                //       const Text("Самостоятелна игра")
                //     ],
                //   ),
                // ),
                // const Divider(thickness: 0.7),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     for (int j = 0; j < 2; j++)
                //       Expanded(
                //         child: Badge(
                //           title: singleStatsData[j]['title'],
                //           text: '${singleStatsData[j]['value']}',
                //           icon: singleStatsData[j]['icon'],
                //           image: singleStatsData[j]['image'],
                //         ),
                //       )
                //   ],
                // ),
                // Badge(
                //   title: singleStatsData[2]['title'],
                //   text: '${singleStatsData[2]['value']}',
                //   icon: singleStatsData[2]['icon'],
                //   image: singleStatsData[2]['image'],
                // ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people,
                          color: Theme.of(context).secondaryHeaderColor),
                      const Text(" Мултиплейър")
                    ],
                  ),
                ),
                const Divider(
                  thickness: 0.7,
                ),
                for (int i = 0; i < 3; i++)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int j = 0; j < 2; j++)
                        Expanded(
                          child: Badge(
                            title: multiStatsData[(i + i) + j]['title'],
                            text: '${multiStatsData[(i + i) + j]['value']}',
                            icon: multiStatsData[(i + i) + j]['icon'],
                            image: multiStatsData[(i + i) + j]['image'],
                          ),
                        )
                    ],
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
