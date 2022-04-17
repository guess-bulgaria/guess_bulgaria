import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String _backendUrl = "";

  static setupEnvConfig(){
    var envs = dotenv.env;
    _backendUrl = envs['BACKEND_URL'] ?? "";
  }

  static String get backendUrl => _backendUrl;
}
