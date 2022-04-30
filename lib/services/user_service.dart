import 'package:dio/dio.dart';
import 'package:guess_bulgaria/configs/env_config.dart';
import 'package:guess_bulgaria/storage/user_data.dart';

class UserService {
  static Future<Response<dynamic>> createUser() {
    return Dio().get(EnvConfig.backendUrl + "/users");
  }

  static Future<Response<dynamic>> getStatistics() {
    return Dio().get(EnvConfig.backendUrl + "/users/${UserData.userId}");
  }
}
