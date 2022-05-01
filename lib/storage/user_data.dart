import 'dart:math';
import 'package:guess_bulgaria/models/player_stats_model.dart';
import 'package:guess_bulgaria/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static const _userIdKey = "id";
  static var _userId = "";
  static const _usernameKey = "username";
  static var _username = "";
  static const _defaultColorKey = "defaultColor";
  static var _defaultColor = 0;
  static PlayerStatsModel stats = PlayerStatsModel();

  static String get username => _username;

  static int get defaultColor => _defaultColor;

  static String get userId => _userId;

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return Future.value(_prefs);
  }

  Future<void> setupUserId() async {
    if (_userId != "") return;

    _userId = await _getPrefString(_userIdKey) ?? "";
    if (_userId != "") return;

    try {
      var response = await UserService.createUser();
      _userId = response.data["_id"];
      await _setPrefString(_userIdKey, _userId);
    } catch (_) {}
  }

  Future<void> setUsername(String username) {
    _username = username;
    return _setPrefString(_usernameKey, username);
  }

  Future<void> loadUsername() async {
    var storedUsername = await _getPrefString(_usernameKey);
    if (storedUsername != null && storedUsername.isNotEmpty) {
      _username = storedUsername;
    } else {
      _username = getRandomUsername();
      await setUsername(_username);
    }
  }

  Future<void> setDefaultColor(int color) {
    _defaultColor = color;
    return _setPrefInt(_defaultColorKey, _defaultColor);
  }

  Future<void> loadDefaultColor() async {
    var storedDefaultColor = await _getPrefInt(_defaultColorKey);
    if (storedDefaultColor != null) {
      _defaultColor = storedDefaultColor;
    } else {
      _defaultColor = 0;
      await setDefaultColor(_defaultColor);
    }
  }

  String getRandomUsername() {
    return 'Пешо-${Random().nextInt(9000) + 1000}';
  }

  Future<void> setupUserData() async {
    await setupUserId();
    await loadUsername();
    await loadDefaultColor();
  }

  Future<void> _setPrefString(String key, String value) async {
    await (await _getPrefs()).setString(key, value);
  }

  Future<void> _setPrefInt(String key, int value) async {
    await (await _getPrefs()).setInt(key, value);
  }

  Future<String?> _getPrefString(String key) async {
    return (await _getPrefs()).getString(key);
  }

  Future<int?> _getPrefInt(String key) async {
    return (await _getPrefs()).getInt(key);
  }
}
