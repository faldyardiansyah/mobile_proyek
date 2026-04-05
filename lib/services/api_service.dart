import 'package:dio/dio.dart' as dio_lib;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ApiService extends GetxService {
  late dio_lib.Dio _dio;
  final _storage = GetStorage();

  static const String baseUrl = 'http://192.168.1.10:8000/api';

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
}