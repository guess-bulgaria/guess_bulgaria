import 'dart:convert';
import 'dart:math';
import 'package:guess_bulgaria/models/lobby_settings_model.dart';
import 'package:guess_bulgaria/models/player_stats_model.dart';
import 'package:guess_bulgaria/services/user_service.dart';
import 'package:guess_bulgaria/storage/online_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static const _userIdKey = "id";
  static var _userId = "";
  static const _usernameKey = "username";
  static var _username = "";
  static const _defaultColorKey = "defaultColor";
  static var _defaultColor = 0;
  static const _singleStatsKey = "singleStats";
  static const _multiStatsKey = "multiStats";
  static const _lobbySettingsKey = "lobbySettings";
  static PlayerStatsModel stats = PlayerStatsModel();
  static LobbySettings lobbySettings = LobbySettings();

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

  void setDefaultColor(int color) {
    _defaultColor = color;
    _setPrefInt(_defaultColorKey, _defaultColor);
  }

  Future<void> loadDefaultColor() async {
    var storedDefaultColor = await _getPrefInt(_defaultColorKey);
    if (storedDefaultColor != null) {
      _defaultColor = storedDefaultColor;
    } else {
      _defaultColor = 0;
      setDefaultColor(_defaultColor);
    }
  }

  Future<void> loadStatistics() async {
    if (await OnlineChecker.checkOnlineStat()) {
      try {
        var apiStats = await UserService.getStatistics();
        if (apiStats.statusCode != null && apiStats.statusCode! < 300) {
          stats = PlayerStatsModel.fromApi(
              SingleStats.fromJson(apiStats.data['single']),
              MultiStats.fromJson(apiStats.data['multi']));
          _storeStats();
          return;
        }
      } catch (_) {}
    }
    stats = await loadStoreStats();
  }

  Future<PlayerStatsModel> loadStoreStats() async {
    var singleStats = SingleStats();
    var multiStats = MultiStats();
    var singleStoreStats = await _getPrefString(_singleStatsKey);
    var multiStoreStats = await _getPrefString(_multiStatsKey);

    if (singleStoreStats != null && singleStoreStats.isNotEmpty) {
      singleStats = SingleStats.fromJson(jsonDecode(singleStoreStats));
    }
    if (multiStoreStats != null && multiStoreStats.isNotEmpty) {
      multiStats = MultiStats.fromJson(jsonDecode(multiStoreStats));
    }

    return PlayerStatsModel.fromApi(singleStats, multiStats);
  }

  Future<void> loadLobbySettings() async {
    var storeSettings = await _getPrefString(_lobbySettingsKey);

    if (storeSettings != null && storeSettings.isNotEmpty) {
      lobbySettings = LobbySettings.fromJson(jsonDecode(storeSettings));
    }
  }

  Future<void> setLobbySettings(int maxRounds, int answerTimeInSeconds, bool isPublic) async {
    lobbySettings.maxRounds = maxRounds;
    lobbySettings.answerTimeInSeconds = answerTimeInSeconds;
    lobbySettings.isPublic = isPublic;
    await _setPrefString(_lobbySettingsKey, jsonEncode(lobbySettings.toJson()));
  }

  String getRandomUsername() {
    return 'Пешо-${Random().nextInt(9000) + 1000}';
  }

  Future<void> _storeStats() async {
    await _setPrefString(_singleStatsKey, stats.single.toJson());
    await _setPrefString(_multiStatsKey, stats.multi.toJson());
  }

  Future<void> setupUserData() async {
    await setupUserId();
    await loadUsername();
    await loadDefaultColor();
    await loadStatistics();
    await loadLobbySettings();
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
