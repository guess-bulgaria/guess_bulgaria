import 'package:dio/dio.dart';
import 'package:guess_bulgaria/configs/env_config.dart';

class PingService {
  static Future<void> ping() async {
    await Dio(BaseOptions(connectTimeout: Duration(seconds: 5))).get("${EnvConfig.backendUrl}/ping");
  }
}