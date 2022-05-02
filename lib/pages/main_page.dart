import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guess_bulgaria/components/color_picker.dart';
import 'package:guess_bulgaria/components/drawer.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';
import 'package:guess_bulgaria/components/scrolling_background.dart';
import 'package:guess_bulgaria/pages/lobby_page.dart';
import 'package:guess_bulgaria/pages/game_page.dart';
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
  late TextEditingController _usernameController;
  late TextEditingController _joinCodeController;
  late FocusNode _joinFocusNode;
  late StreamSubscription<bool> _keyboardSubscription;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: UserData.username);
    _joinCodeController = TextEditingController(text: '');
    _joinFocusNode = FocusNode();

    _keyboardSubscription =
        KeyboardVisibilityController().onChange.listen((bool visible) {
      if (!visible) clearFocus();
    });
  }

  @override
  void dispose() {
    _joinCodeController.dispose();
    _usernameController.dispose();
    _joinFocusNode.dispose();
    _keyboardSubscription.cancel();
    super.dispose();
  }

  playSingle() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const GamePage()));
  }

  createRoom() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LobbyPage()));
  }

  stats() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const StatsPage()));
  }

  landmarks() {}

  void onMessageReceived(String type, dynamic message) {
    if (type == 'current-data') {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LobbyPage(joinData: message)));
    } else if (type =='join-failed'){
      //todo set join field to error
    }
  }

  clearFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void onJoinCodeType(){
    if(_joinCodeController.text.length == 6){
      WSService.joinGame(
          onMessageReceived, int.parse(_joinCodeController.text));
    }
    else if(_joinCodeController.text.length > 6){
      _joinCodeController.text = _joinCodeController.text.substring(0, 6);
      _joinCodeController.selection =
          TextSelection.fromPosition(TextPosition(offset: _joinCodeController.text.length));
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
                                  height: 1),
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
                                  height: 0.9),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    NavigationButton(
                        text: 'Самостоятелна игра', onPressed: playSingle),
                    Observer(builder: (_) {
                      return NavigationButton(
                          text: 'Създай онлайн игра',
                          onPressed:
                              onlineChecker.isOnline ? createRoom : null);
                    }),
                    Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            width: 4),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Observer(builder: (_) {
                        return Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: TextFormField(
                                enabled: onlineChecker.isOnline,
                                autofocus: false,
                                onEditingComplete: () {
                                  clearFocus();
                                },
                                controller: _joinCodeController,
                                style: const TextStyle(
                                  letterSpacing: 3,
                                ),
                                onChanged: (_) => onJoinCodeType(),
                                decoration: InputDecoration(
                                  hintText: "Въведи код",
                                  hintStyle: GoogleFonts.caveat(
                                    fontSize: 16,
                                    letterSpacing: 0,
                                    color: Theme.of(context).secondaryHeaderColor,
                                    height: 1,
                                  ),
                                  contentPadding:
                                      const EdgeInsets.only(left: 21),
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
                              flex: 2,
                              child: InkWell(
                                focusNode: _joinFocusNode,
                                onTap: onlineChecker.isOnline ? () => WSService.joinGame(
                                    onMessageReceived, int.parse(_joinCodeController.text)) : null,
                                child: Icon(
                                  Icons.send,
                                  color:
                                      Theme.of(context).secondaryHeaderColor,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    // Observer(builder: (_) {
                    //   return NavigationButton(
                    //       text: 'Присъедини се към стая',
                    //       onPressed: onlineChecker.isOnline ? joinRoom : null);
                    // }),
                    NavigationButton(text: 'Статистики', onPressed: stats),
                    NavigationButton(
                        text: 'Забележителности', onPressed: landmarks),
                  ],
                ),
              ),
              OpenDrawerButton(
                  clickCallback: () => Scaffold.of(context).openDrawer(),
                  top: 6)
            ],
          ),
        ),
      ),
      onDrawerChanged: (isOpen) {
        clearFocus();
        if (isOpen) {
          _usernameController.text = UserData.username;
        } else {
          setUsername();
        }
      },
      drawerEnableOpenDragGesture: false,
      drawer: GbDrawer(
        children: [
          const Text(
            "Потребителско име",
            textAlign: TextAlign.center,
          ),
          TextFormField(
            decoration: const InputDecoration(
              prefixIconConstraints:
                  BoxConstraints(minWidth: 22, maxHeight: 20),
              prefixIcon: Icon(Icons.edit, size: 16),
            ),
            textAlign: TextAlign.left,
            controller: _usernameController,
            // style: TextStyle(color: Colors.white70),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: ColorPicker(
              iconMargin: 3,
              selectedColor: UserData.defaultColor,
              title: "Предпочитан цвят",
              onColorChange: setDefaultColor,
            ),
          ),
          const Divider(thickness: 0.45)
        ],
      ),
    );
  }

  void setDefaultColor(int i) async {
    await UserData().setDefaultColor(i);
    setState(() => {});
  }

  void setUsername() {
    if (_usernameController.text.isNotEmpty) {
      UserData().setUsername(_usernameController.text);
    }
  }
}
