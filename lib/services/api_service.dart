import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';

class ApiService extends GetxService {
  late dio_lib.Dio _dio;
  final _storage = GetStorage();

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://192.168.1.10/api';
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
          debugPrint("ERROR STATUS: ${error.response?.statusCode}");
          debugPrint("ERROR DATA: ${error.response?.data}");

          if (error.response?.statusCode == 401) {
            _storage.erase();
            Get.offAllNamed('/login');
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<dio_lib.Response<dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return await _dio.post(endpoint, data: data);
  }

  Future<dio_lib.Response<dynamic>> googleLogin(String idToken) async {
    return await post('/auth/google', {'id_token': idToken});
  }

  Future<dio_lib.Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    return await _dio.get(endpoint, queryParameters: params);
  }

  Future<dio_lib.Response<dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return await _dio.put(endpoint, data: data);
  }

  Future<dio_lib.Response<dynamic>> getProfile() async {
    return await get('/profile');
  }

  Future<dio_lib.Response<dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    return await put('/profile/update', data);
  }

  Future<dio_lib.Response<dynamic>> getProperties() async {
    return await get('/all-properties');
  }

  Future<dio_lib.Response<dynamic>> postFormData(
    String endpoint,
    dio_lib.FormData formData,
  ) async {
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

  Future<dio_lib.Response<dynamic>> postBooking(
    Map<String, dynamic> data,
  ) async {
    return await post('/bookings', data);
  }

  Future<dio_lib.Response<dynamic>> createBooking(
    Map<String, dynamic> data,
  ) async {
    return await post('/bookings', data);
  }

  Future<dio_lib.Response<dynamic>> getSnapToken(String bookingId) async {
    return await get('/bookings/$bookingId/snap-token');
  }

  Future<dio_lib.Response<dynamic>> getRiwayatBooking() async {
    return await get('/bookings');
  }

  Future<dio_lib.Response<dynamic>> cancelBooking(String bookingId) async {
    return await _dio.patch('/bookings/$bookingId/cancel');
  }

  Future<dio_lib.Response<dynamic>> deleteBooking(String bookingId) async {
    return await _dio.delete('/bookings/$bookingId');
  }

  Future<dio_lib.Response<dynamic>> refundBooking(
    String bookingId,
    String alasan,
  ) async {
    return await post('/bookings/$bookingId/refund', {'alasan_refund': alasan});
  }

  Future<dio_lib.Response<dynamic>> getUlasan(
    String tipe,
    int propertiId,
  ) async {
    return await get(
      '/ulasan',
      params: {'tipe': tipe, 'properti_id': propertiId},
    );
  }

  Future<dio_lib.Response<dynamic>> cekBolehReview(
    String tipe,
    int propertiId,
  ) async {
    return await get(
      '/ulasan/cek',
      params: {'tipe': tipe, 'properti_id': propertiId},
    );
  }

  Future<dio_lib.Response<dynamic>> kirimUlasan(
    Map<String, dynamic> data,
  ) async {
    return await post('/ulasan', data);
  }

  Future<dio_lib.Response<dynamic>> getUlasanSaya() async {
    return await get('/ulasan/saya');
  }

  Future<dio_lib.Response<dynamic>> getBookingBelumReview() async {
    return await get('/ulasan/booking-belum-review');
  }
}
