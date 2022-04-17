import 'package:dio/dio.dart';
import 'package:guess_bulgaria/configs/env_config.dart';

class PingService {
  static Future<void> ping() async {
    await Dio(BaseOptions(connectTimeout: 5000)).get(EnvConfig.backendUrl + "/ping");
  }
}