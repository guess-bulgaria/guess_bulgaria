import 'package:flutter/material.dart';
import 'package:guess_bulgaria/components/board.dart';
import 'package:guess_bulgaria/components/loader.dart';
import 'package:guess_bulgaria/components/room_row.dart';
import 'package:guess_bulgaria/components/scrolling_background.dart';
import 'package:guess_bulgaria/components/user_settings_drawer.dart';
import 'package:guess_bulgaria/pages/lobby_page.dart';
import 'package:guess_bulgaria/services/room_service.dart';
import 'package:guess_bulgaria/services/ws_service.dart';
import 'package:guess_bulgaria/storage/online_checker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../components/open_drawer_button.dart';

class PublicLobbiesPage extends StatefulWidget {
  const PublicLobbiesPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PublicLobbiesPageState();
}

class _PublicLobbiesPageState extends State<PublicLobbiesPage> {
  final onlineChecker = OnlineChecker();
  List<dynamic>? rooms;
  bool hasLoaded = false;

  @override
  void initState() {
    super.initState();
    RoomService.getPublicRooms().then((value) =>
        setState(() => {rooms = value.data ?? [], hasLoaded = true}));
  }

  landmarks() {}

  bool _hasError = false;

  void onMessageReceived(String type, dynamic message) {
    if (type == 'current-data') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LobbyPage(joinData: message),
        ),
      );
    } else if (type == 'join-failed') {
      setState(() {
        //todo show error on screen
        _hasError = true;
      });
    }
  }

  clearFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> roomWidgets = (rooms ?? [])
        .map((room) =>
            RoomRow(room, (id) => WSService.joinGame(onMessageReceived, id)))
        .toList(growable: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: !hasLoaded
          ? const GbLoader()
          : Builder(
              builder: (context) => GestureDetector(
                onTap: clearFocus,
                child: Stack(
                  clipBehavior: Clip.antiAlias,
                  children: [
                    const ScrollingBackground(),
                    Board(
                      title: "Онлайн стаи",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (roomWidgets.isEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              width: double.infinity,
                              child: const Center(
                                  child: Text(
                                "Няма намерени стаи",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              )),
                            ),
                          if (roomWidgets.isNotEmpty)
                            Expanded(
                              flex: 10,
                              child: ScrollablePositionedList.builder(
                                itemCount: roomWidgets.length,
                                itemBuilder: (context, index) =>
                                    roomWidgets[index],
                                padding: const EdgeInsets.only(bottom: 20),
                              ),
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
