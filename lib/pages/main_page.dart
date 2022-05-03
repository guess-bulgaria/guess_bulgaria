import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guess_bulgaria/components/color_picker.dart';
import 'package:guess_bulgaria/components/drawer.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/components/scrolling_background.dart';
import 'package:guess_bulgaria/components/user_settings_drawer.dart';
import 'package:guess_bulgaria/pages/lobby_page.dart';
import 'package:guess_bulgaria/pages/game_page.dart';
import 'package:guess_bulgaria/pages/public_lobbies_page.dart';
import 'package:guess_bulgaria/pages/stats_page.dart';
import 'package:guess_bulgaria/services/ws_service.dart';
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
  late TextEditingController _joinCodeController;
  late FocusNode _joinFocusNode;
  late FocusNode _joinTextFocusNode;
  late StreamSubscription<bool> _keyboardSubscription;

  @override
  void initState() {
    super.initState();
    _joinCodeController = TextEditingController(text: '');
    _joinFocusNode = FocusNode();
    _joinTextFocusNode = FocusNode();

    _keyboardSubscription =
        KeyboardVisibilityController().onChange.listen((bool visible) {
      if (!visible) clearFocus();
    });
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
    _joinFocusNode.dispose();
    _joinTextFocusNode.dispose();
    _keyboardSubscription.cancel();
    super.dispose();
  }

  playSingle() {
    _joinCodeController.text = "";
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const GamePage()));
  }

  createRoom() {
    _joinCodeController.text = "";
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LobbyPage()));
  }

  stats() {
    _joinCodeController.text = "";
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const StatsPage()));
  }

  landmarks() {
    _joinCodeController.text = "";
  }

  publicRooms() {
    _joinCodeController.text = "";
    Navigator.push(context, MaterialPageRoute(builder: (context) => const PublicLobbiesPage()));
  }

  bool _hasError = false;

  void onMessageReceived(String type, dynamic message) {
    if (type == 'current-data') {
      _joinCodeController.text = "";
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LobbyPage(joinData: message)));
    } else if (type == 'join-failed') {
      //todo set join field to error
      setState(() {
        _hasError = true;
      });
    }
  }

  clearFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void onJoinCodeType() {
    setState(() {
      _hasError = false;
    });
    if (_joinCodeController.text.length == 6) {
      WSService.joinGame(
          onMessageReceived, int.parse(_joinCodeController.text));
    } else if (_joinCodeController.text.length > 6) {
      _joinCodeController.text = _joinCodeController.text.substring(0, 6);
      _joinCodeController.selection = TextSelection.fromPosition(
          TextPosition(offset: _joinCodeController.text.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Builder(
        builder: (context) => GestureDetector(
          onTap: clearFocus,
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              const ScrollingBackground(),
              Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 10,
                          bottom: MediaQuery.of(context).size.height / 20,
                          left: 50,
                          right: 50),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              // "РАЗУЧИ БългариЯ",
                              // "НАМЕРИ БългариЯ",
                              // "пътешествие\nв БългариЯ",
                              "обиколи\n",
                              style: GoogleFonts.amaticSc(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                height: 1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Center(
                            child: Text(
                              // "РАЗУЧИ БългариЯ",
                              // "НАМЕРИ БългариЯ",
                              // "пътешествие\nв БългариЯ",
                              "\nБългариЯ",
                              style: GoogleFonts.amaticSc(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                                height: 0.9,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    NavigationButton(
                      icon: Icons.person,
                      text: 'Самостоятелна игра',
                      onPressed: playSingle,
                    ),
                    Observer(builder: (_) {
                      return NavigationButton(
                        icon: Icons.people,
                        text: 'Създай онлайн игра',
                        onPressed: onlineChecker.isOnline ? createRoom : null,
                      );
                    }),
                    Observer(builder: (_) {
                      return NavigationButton(
                        icon: Icons.person_search,
                        text: 'Намери онлайн стая',
                        onPressed: onlineChecker.isOnline ? publicRooms : null,
                      );
                    }),
                    Container(
                      width: 230,
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          width: 4,
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Observer(builder: (_) {
                        return Row(
                          children: [
                            Expanded(
                              flex: 20,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(
                                  Icons.person,
                                  color: onlineChecker.isOnline
                                      ? Colors.white
                                      : Colors.black45,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 40,
                              child: TextFormField(
                                enabled: onlineChecker.isOnline,
                                autofocus: false,
                                onEditingComplete: () {
                                  clearFocus();
                                },
                                focusNode: _joinTextFocusNode,
                                controller: _joinCodeController,
                                textAlign: TextAlign.left,
                                style: GoogleFonts.mulish(
                                  color: _hasError ? Colors.red : Colors.white,
                                  letterSpacing: 3,
                                ),
                                onChanged: (_) => onJoinCodeType(),
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                ],
                                decoration: InputDecoration(
                                  hintText: "Въведи код",
                                  hintStyle: GoogleFonts.mulish(
                                    fontSize: 16,
                                    letterSpacing: 0,
                                    color: onlineChecker.isOnline
                                        ? Theme.of(context).secondaryHeaderColor
                                        : Colors.black45,
                                    height: 1,
                                  ),
                                  errorStyle: const TextStyle(height: 0),
                                  errorText: _hasError ? '' : null,
                                  contentPadding:
                                      const EdgeInsets.only(left: 7),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 30,
                              child: InkWell(
                                focusNode: _joinFocusNode,
                                onTap: onlineChecker.isOnline
                                    ? () => _joinTextFocusNode.requestFocus()
                                    : null,
                                child: Icon(
                                  Icons.east,
                                  color: onlineChecker.isOnline
                                      ? Colors.white
                                      : Colors.black45,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    NavigationButton(
                      icon: Icons.landscape,
                      text: 'Забележителности',
                      onPressed: landmarks,
                    ),
                    NavigationButton(
                      icon: Icons.account_box,
                      text: 'Моите статистики',
                      onPressed: stats,
                    ),
                  ],
                ),
              ),
              OpenDrawerButton(
                  clickCallback: () => Scaffold.of(context).openDrawer(),
              )
            ],
          ),
        ),
      ),
      drawerEnableOpenDragGesture: false,
      drawer: const UserSettingsDrawer(),
    );
  }
}
