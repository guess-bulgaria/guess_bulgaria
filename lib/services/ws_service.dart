import 'dart:convert';

import 'package:guess_bulgaria/configs/env_config.dart';
import 'package:guess_bulgaria/storage/user_data.dart';
import 'package:web_socket_channel/io.dart';

class WSService {
  static IOWebSocketChannel? _channel;

  static Function? _messageCallback;

  static dynamic _lastMessage = {};

  static void _createChannel(Function callback) {
    _channel = IOWebSocketChannel.connect(
      Uri.parse(EnvConfig.backendWSUrl),
    );
    _messageCallback = callback;
    _channel!.stream.listen(
      (message) {
        print("received: " + message);
        if (_messageCallback != null) {
          var jsonMessage = json.decode(message);
          _messageCallback!(
            jsonMessage?['type'] ?? '',
            jsonMessage?['message'] ?? {},
          );
        }
      },
      onError: (_) => {
        if (_lastMessage != {})
          {
            _createChannel(_messageCallback!),
            _sendMessage(_lastMessage['type'], data: _lastMessage)
          }
      },
    );
  }

  static void _closeChannel() {
    _channel!.sink.close();
    _channel = null;
  }

  static void changeCallback(Function callback) {
    _messageCallback = callback;
  }

  static void createGame(Function callback) {
    _createChannel(callback);
    _sendMessage('create');
  }

  static void joinGame(Function callback, int roomId) {
    _createChannel(callback);
    _sendMessage('join', data: {'roomId': roomId});
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
    data = {
      'type': type,
      'id': UserData.userId,
      'username': UserData.username,
      ...(data ?? {})
    };
    _lastMessage = data;
    _channel!.sink.add(json.encode(data));
  }
}
