import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:guess_bulgaria/components/color_picker.dart';
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

  getDrawerButton(VoidCallback callback, {double? left, int top = 6}) {
    return Positioned(
      top: MediaQuery.of(context).size.height / top,
      left: left ?? -MediaQuery.of(context).size.width / 14,
      child: InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: callback,
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
                child: const Icon(Icons.person, color: Colors.black),
              ),
            ),
          ],
        ),
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
            getDrawerButton(() => Scaffold.of(context).openDrawer(), top: 6),
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
      onDrawerChanged: (isOpen) {
        if (isOpen) {
          usernameController.text = UserData.username;
        } else {
          setUsername();
        }
      },
      drawerEnableOpenDragGesture: false,
      drawer: Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 4),
        width: MediaQuery.of(context).size.width / 2.2,
        height: MediaQuery.of(context).size.height / 2,
        child: Stack(
          children: [
            Material(
              color: Colors.transparent,
              elevation: 1000,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  getDrawerButton(() => Navigator.pop(context),
                      left: MediaQuery.of(context).size.width / 2.6, top: 24)
                ],
              ),
            ),
            Positioned(
              child: Drawer(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                elevation: 1,
                child: ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: "Потребителско име",
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: ColorPicker(
                        iconMargin: 3,
                        selectedColor: UserData.defaultColor,
                        title: "Предпочитан цвят",
                        onColorChange: setDefaultColor,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setDefaultColor(int i) async {
    await UserData().setDefaultColor(i);
    setState(() => {});
  }

  void setUsername() {
    if (usernameController.text.isNotEmpty) {
      UserData().setUsername(usernameController.text);
    }
  }
}
