import 'package:dio/dio.dart' as dio_lib;
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';

class ApiService extends GetxService {
  late dio_lib.Dio _dio;
  final _storage = GetStorage();

 static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://192.168.1.10:8000/api';
  @override

  void onInit() {
    super.onInit();

    _dio = dio_lib.Dio(
      dio_lib.BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      dio_lib.InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _storage.read('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          print("ERROR STATUS: ${error.response?.statusCode}");
          print("ERROR DATA: ${error.response?.data}");

          if (error.response?.statusCode == 401) {
            _storage.erase();
            Get.offAllNamed('/login');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<dio_lib.Response<dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    return await _dio.post(endpoint, data: data);
  }

  Future<dio_lib.Response<dynamic>> get(String endpoint, {Map<String, dynamic>? params}) async {
    return await _dio.get(endpoint, queryParameters: params);
  }

  Future<dio_lib.Response<dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    return await _dio.put(endpoint, data: data);
  }

  Future<dio_lib.Response<dynamic>> getProfile() async {
    return await get('/profile');
  }

  Future<dio_lib.Response<dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await put('/profile/update', data);
  }

  Future<dio_lib.Response<dynamic>> getProperties() async {
    return await get('/all-properties');
  }

  Future<dio_lib.Response<dynamic>> postFormData(
    String endpoint, dio_lib.FormData formData) async {
  return await _dio.post(
    endpoint,
    data: formData,
    options: dio_lib.Options(
      headers: {'Content-Type': 'multipart/form-data'},
    ),
  );
}
Future<dio_lib.Response<dynamic>> getDetailKosan(int id) async {
  return await get('/properties/kosan/$id/detail');
}

Future<dio_lib.Response<dynamic>> getDetailKontrakan(int id) async {
  return await get('/properties/kontrakan/$id/detail');
}

Future<dio_lib.Response<dynamic>> postBooking(Map<String, dynamic> data) async {
  return await post('/bookings', data);
}
}