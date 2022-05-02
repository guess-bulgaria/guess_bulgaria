import 'package:dio/dio.dart';
import 'package:guess_bulgaria/configs/env_config.dart';

class RoomService {
  static Future<Response<List<dynamic>>> getPublicRooms() {
    return Dio().get(EnvConfig.backendUrl + "/public-rooms");
  }
}
