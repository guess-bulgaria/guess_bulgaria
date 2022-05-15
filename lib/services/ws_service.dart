import 'dart:convert';

import 'package:guess_bulgaria/configs/env_config.dart';
import 'package:guess_bulgaria/models/lobby_settings_model.dart';
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

  static void changeCallback(Function? callback) {
    _messageCallback = callback;
  }

  static void createGame(Function callback, {LobbySettings? settings}) {
    _createChannel(callback);
    _sendMessage('create',
        data: settings?.maxRounds != null ? settings!.toJson() : {});
  }

  static void joinGame(Function callback, int roomId) {
    _createChannel(callback);
    _sendMessage('join', data: {'roomId': roomId});
  }

  static void changeSettings(int roomId, int maxRounds, int answerTimeInSeconds,
      bool isPublic, List<int>? regions) {
    _sendMessage('change-settings', data: {
      'roomId': roomId,
      'maxRounds': maxRounds,
      'answerTimeInSeconds': answerTimeInSeconds,
      'regions': regions,
      'isPublic': isPublic
    });
  }

  static void changeColor(int roomId, int color) {
    _sendMessage('change-color', data: {
      'roomId': roomId,
      'color': color,
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
      'color': UserData.defaultColor,
      ...(data ?? {})
    };
    _lastMessage = data;
    _channel!.sink.add(json.encode(data));
  }

  static void startRound(int roomId, {Function? callback}) {
    if (callback != null) _createChannel(callback);
    _sendMessage('start', data: {'roomId': roomId});
  }

  static void lockAnswer(int roomId, List<double> answer) {
    _sendMessage('answer', data: {'answer': answer, 'roomId': roomId});
  }

  static void nextRound(int roomId) {
    _sendMessage('next-round', data: {'roomId': roomId});
  }

  static void roundLoaded(int roomId) {
    _sendMessage('round-loaded',
        data: {'roomId': roomId});
  }
}
