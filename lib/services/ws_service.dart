import 'dart:convert';

import 'package:guess_bulgaria/configs/env_config.dart';
import 'package:guess_bulgaria/storage/user_data.dart';
import 'package:web_socket_channel/io.dart';

class WSService {
  static IOWebSocketChannel? _channel;

  static Function? _messageCallback;

  static void _createChannel(Function callback) {
    _channel = IOWebSocketChannel.connect(
      Uri.parse(EnvConfig.backendWSUrl),
    );
    _messageCallback = callback;
    _channel!.stream.listen((message) {
      print("received: " + message);
      if (_messageCallback != null) {
        var jsonMessage = json.decode(message);
        _messageCallback!(
          jsonMessage?['type'] ?? '',
          jsonMessage?['message'] ?? {},
        );
      }
    });
  }

  static void _closeChannel() {
    _channel!.sink.close();
    _channel = null;
  }

  static void createGame(Function callback) {
    _createChannel(callback);
    _sendMessage('create');
  }

  static void changeSettings(
      int roomId, int maxRounds, int answerTimeInSeconds, List<int>? regions) {
    _sendMessage('change-settings', data: {
      'roomId': roomId,
      'maxRounds': maxRounds,
      'answerTimeInSeconds': answerTimeInSeconds,
      'regions': regions
    });
  }

  static void leave(int roomId) {
    _sendMessage('leave', data: {'roomId': roomId});
  }

  static void _sendMessage(String type, {dynamic data}) {
    data = {'type': type, 'id': UserData.userId, ...(data ?? {})};
    _channel!.sink.add(json.encode(data));
  }
}
