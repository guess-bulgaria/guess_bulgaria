import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/components/scrolling_background.dart';
import 'package:guess_bulgaria/pages/join_lobby_screen.dart';
import 'package:guess_bulgaria/pages/lobby_page.dart';
import 'package:guess_bulgaria/pages/game_page.dart';
import 'package:guess_bulgaria/pages/stats_page.dart';
import 'package:guess_bulgaria/storage/online_checker.dart';
import 'package:guess_bulgaria/storage/user_data.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final onlineChecker = OnlineChecker();
  TextEditingController usernameController =
      TextEditingController(text: UserData.username);

  playSingle() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GamePage()));
  }

  createRoom() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LobbyPage()));
  }

  joinRoom() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const JoinLobbyScreen()));
  }

  stats() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const StatsPage()));
  }

  getDrawerButton(VoidCallback callback, {double? left}) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 6,
      left: left ?? -MediaQuery.of(context).size.width / 14,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.circle,
                color: Theme.of(context).colorScheme.primary, size: 64),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 29, top: 20),
              child: InkWell(
                onTap: callback,
                child: const Icon(Icons.person, color: Colors.black),
              ),
            ),
          )
        ],
      ),
    );
  }

  landmarks() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Builder(
        builder: (context) => Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            const ScrollingBackground(),
            getDrawerButton(() => Scaffold.of(context).openDrawer()),
            Align(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NavigationButton(
                      text: 'Самостоятелна игра', onPressed: playSingle),
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
                  NavigationButton(
                      text: 'Забележителности', onPressed: landmarks),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Builder(builder: (context) {
        return FloatingActionButton(
          onPressed: () =>
              Scaffold.of(context).openDrawer(), // <-- Opens drawer.
        );
      }),
      onDrawerChanged: (isOpen) {
        if (isOpen) usernameController.text = UserData.username;
      },
      drawerEnableOpenDragGesture: false,
      drawer: Stack(
        children: [
          Material(
              color: Colors.transparent,
              elevation: 1000,
              child: Stack(children: [
                getDrawerButton(() => Navigator.pop(context),
                    left: MediaQuery.of(context).size.width / 2.6)
              ])),
          Positioned(
            top: MediaQuery.of(context).size.height / 8,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2.2,
              height: MediaQuery.of(context).size.height / 2,
              child: Drawer(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                elevation: 1,
                child: ListView(
                  children: [
                    const SizedBox(height: 50),
                    const Text('Никнейм'),
                    TextFormField(controller: usernameController),
                    ElevatedButton(
                        onPressed: setUsername, child: const Text('Запазване')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setUsername() {
    UserData().setUsername(usernameController.text);
  }
}
