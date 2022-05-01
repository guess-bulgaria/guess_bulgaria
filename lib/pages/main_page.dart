import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guess_bulgaria/components/color_picker.dart';
import 'package:guess_bulgaria/components/main_page_drawer.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/components/scrolling_background.dart';
import 'package:guess_bulgaria/pages/join_lobby_screen.dart';
import 'package:guess_bulgaria/pages/lobby_page.dart';
import 'package:guess_bulgaria/pages/game_page.dart';
import 'package:guess_bulgaria/pages/stats_page.dart';
import 'package:guess_bulgaria/storage/online_checker.dart';
import 'package:guess_bulgaria/storage/user_data.dart';

import '../components/open_drawer_button.dart';

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

  landmarks() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Builder(
        builder: (context) => Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            const ScrollingBackground(),
            Align(
              alignment: Alignment.topCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height / 16,
                        left: 50,
                        right: 50),
                    child: Stack(
                      children: [
                        Text(
                          // "РАЗУЧИ БългариЯ",
                          // "Познай къде в българия",
                          "НАМЕРИ БългариЯ",
                          style: GoogleFonts.amaticSc(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              height: 0.77),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
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
            ),
            OpenDrawerButton(clickCallback: () => Scaffold.of(context).openDrawer(), top: 6)
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
      drawer: MainPageDrawer(usernameController: usernameController),
    );
  }

  void setUsername() {
    if (usernameController.text.isNotEmpty) {
      UserData().setUsername(usernameController.text);
    }
  }
}
