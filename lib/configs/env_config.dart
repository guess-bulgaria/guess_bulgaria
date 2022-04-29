import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String _backendUrl = "";
  static String _backendWSUrl = "";

  static setupEnvConfig(){
    var envs = dotenv.env;
    _backendUrl = envs['BACKEND_URL'] ?? "";
    _backendWSUrl = envs['BACKEND_WS_URL'] ?? "";
  }

  static String get backendUrl => _backendUrl;
  static String get backendWSUrl => _backendWSUrl;
}
