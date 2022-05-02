import 'package:flutter/material.dart';
import 'package:guess_bulgaria/components/badge.dart';
import 'package:guess_bulgaria/components/loader.dart';
import 'package:guess_bulgaria/components/scrolling_background.dart';
import 'package:guess_bulgaria/pages/lobby_page.dart';
import 'package:guess_bulgaria/services/ws_service.dart';
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
  void initState() {
    super.initState();
    final Map<String, int> singleStatsData = {
      "Изиграни рундове": UserData.stats.single.roundsPlayed,
      "Общо спечелени точки": UserData.stats.single.totalPoints,
      "Перфектни отговорени": UserData.stats.single.perfectAnswers
    };
    for (var entry in singleStatsData.entries) {
      singleStats.add(Text('${entry.key}: ${entry.value}'));
    }

    final gamesPlayed = UserData.stats.multi.gamesPlayed;
    final winRate = UserData.stats.multi.firstPlaces /
        (gamesPlayed == 0 ? 1 : gamesPlayed) *
        100;
    final Map<String, dynamic> multiStatsData = {
      "Изиграни игри": gamesPlayed,
      "Победи": UserData.stats.multi.firstPlaces,
      "Процент спечелени игри": '${winRate.toStringAsFixed(2)}%',
      "Изиграни рундове": UserData.stats.multi.roundsPlayed,
      "Общо спечелени точки": UserData.stats.multi.totalPoints,
      "Перфектни отговорени": UserData.stats.multi.perfectAnswers,
    };
    for (var entry in multiStatsData.entries) {
      multiStats.add(Text('${entry.key}: ${entry.value}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          const ScrollingBackground(),
          Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Badge(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Icon(Icons.person), Text("Самостоятелна")],
                  ),
                ),
                ...singleStats,
                Badge(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Icon(Icons.people), Text("Мултиплейър")],
                  ),
                ),
                ...multiStats
              ],
            ),
          ),
        ],
      ),
    );
  }
}
