import 'dart:math';
import 'package:guess_bulgaria/models/player_stats_model.dart';
import 'package:guess_bulgaria/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static var _userId = "";
  static PlayerStatsModel stats = PlayerStatsModel();

  static String get userId => _userId;

  static var _username = "";

  static String get username => _username;

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return Future.value(_prefs);
  }

  Future<void> setupUserId() async {
    if (_userId != "") return;

    _userId = await _getPrefString("id") ?? "";
    if (_userId != "") return;

    try {
      var response = await UserService.createUser();
      _userId = response.data["_id"];
      await _setPrefString("id", _userId);
    } catch (_) {}
  }

  Future<void> setUsername(String username) {
    _username = username;
    return _setPrefString("username", username);
  }

  Future<void> loadUsername() async {
    var storedUsername = await _getPrefString("username");
    if (storedUsername != null && storedUsername.isNotEmpty) {
      _username = storedUsername;
    } else {
      _username = getRandomUsername();
      await setUsername(_username);
    }
  }

  String getRandomUsername() {
    return 'Пешо${Random().nextInt(9000) + 1000}';
  }

  Future<void> setupUserData() async {
    await setupUserId();
    await loadUsername();
  }

  Future<void> _setPrefString(String key, String value) async {
    await (await _getPrefs()).setString(key, value);
  }

  Future<String?> _getPrefString(String key) async {
    return (await _getPrefs()).getString(key);
  }
}
