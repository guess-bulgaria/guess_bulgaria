import 'package:guess_bulgaria/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobx/mobx.dart';

class UserData {
  //todo rewrite so it auto gets when online
  final _userId = Observable("");

  String get userId => _userId.value;

  UserData() {
    setupUserId();
  }

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return Future.value(_prefs);
  }

  Future<void> setupUserId() async {
    if (_userId.value != "") return;

    _userId.value = await _getPrefString("id") ?? "";
    if (_userId.value != "") return;

    try {
      var response = await UserService.createUser();
      _userId.value = response.data["_id"];
      await _setPrefString("id", _userId.value);
    } catch (e) {}
  }

  Future<void> _setPrefString(String key, String value) async {
    await (await _getPrefs()).setString(key, value);
  }

  Future<String?> _getPrefString(String key) async {
    return (await _getPrefs()).getString(key);
  }
}
