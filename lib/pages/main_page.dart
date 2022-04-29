import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/pages/lobby_page.dart';
import 'package:guess_bulgaria/pages/game_page.dart';
import 'package:guess_bulgaria/storage/online_checker.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final onlineChecker = OnlineChecker();

  playSingle() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const GamePage()));
  }

  createRoom() {
    Navigator.push(
      context, MaterialPageRoute(builder: (context) => CreateGamePage())
    );
  }

  joinRoom() {}

  stats() {}

  landmarks() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NavigationButton(text: 'Самостоятелна игра', onPressed: playSingle),
            Observer(builder: (_) {
              return NavigationButton(
                  text: 'Създай онлайн игра',
                  onPressed: onlineChecker.isOnline ? createRoom : null);
            }),
            Observer(builder: (_) {
              return NavigationButton(
                  text: 'Присъедини се към стая',
                  onPressed: onlineChecker.isOnline ? joinRoom : null);
            }),
            NavigationButton(text: 'Статистики', onPressed: stats),
            NavigationButton(text: 'Забележителности', onPressed: landmarks)
          ],
        ),
      ),
    );
  }
}