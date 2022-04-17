import 'package:dio/dio.dart';
import 'package:guess_bulgaria/configs/env_config.dart';

class UserService {
  static Future<Response<dynamic>> createUser() {
    return Dio().get(EnvConfig.backendUrl + "/users");
  }
}