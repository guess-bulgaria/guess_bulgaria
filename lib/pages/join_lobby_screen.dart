import 'package:flutter/material.dart';
import 'package:guess_bulgaria/components/loader.dart';
import 'package:guess_bulgaria/pages/lobby_page.dart';
import 'package:guess_bulgaria/services/ws_service.dart';

class JoinLobbyScreen extends StatefulWidget {
  const JoinLobbyScreen({Key? key}) : super(key: key);

  @override
  State<JoinLobbyScreen> createState() => _JoinLobbyScreenState();
}

class _JoinLobbyScreenState extends State<JoinLobbyScreen> {
  late BuildContext ctx;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    ctx = context;
    TextEditingController code = TextEditingController();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: isLoading
          ? const GbLoader()
          : Align(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(controller: code),
                  ElevatedButton(
                      onPressed: () => {
                            WSService.joinGame(
                                onMessageReceived, int.parse(code.text)),
                            setState(() {
                              isLoading = true;
                            }),
                          },
                      child: const Text('Join papi'))
                ],
              ),
            ),
    );
  }

  void onMessageReceived(String type, dynamic message) {
    setState(() {
      isLoading = false;
    });
    if (type == 'current-data') {
      Navigator.push(
          ctx,
          MaterialPageRoute(
              builder: (context) => CreateGamePage(joinData: message)));
    }
  }
}
