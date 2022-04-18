import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => const GamePage()));
  }

  createRoom() {}

  joinRoom() {}

  stats() {}

  landmarks() {}

  @override
  Widget build(BuildContext context) {
    const width = 200.0;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: width,
              child: TextButton(
                child: const Text("Самостоятелна игра"),
                onPressed: () => playSingle(),
              ),
            ),
            Observer(
              builder: (_) {
                return SizedBox(
                  width: width,
                  child: TextButton(
                    child: const Text("Създай онлайн игра"),
                    onPressed: onlineChecker.isOnline ? (() => createRoom()) : null,
                  ),
                );
              },
            ),
            Observer(
              builder: (_) {
                return SizedBox(
                  width: width,
                  child: TextButton(
                    child: const Text("Присъедини се към стая"),
                    onPressed: onlineChecker.isOnline ? (() => joinRoom()) : null,
                  ),
                );
              },
            ),
            SizedBox(
              width: width,
              child: TextButton(
                child: const Text("Статистики"),
                onPressed: () => stats(),
              ),
            ),
            SizedBox(
              width: width,
              child: TextButton(
                child: const Text("Забележителности"),
                onPressed: () => landmarks(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}