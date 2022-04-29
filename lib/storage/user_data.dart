import 'package:guess_bulgaria/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static var _userId = "";

  static String get userId => _userId;

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
    } catch (e) {}
  }

  Future<void> _setPrefString(String key, String value) async {
    await (await _getPrefs()).setString(key, value);
  }

  Future<String?> _getPrefString(String key) async {
    return (await _getPrefs()).getString(key);
  }
}
