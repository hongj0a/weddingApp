import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/sign/login_page.dart';

class ApiService {
  final Dio dio = Dio();

  ApiService() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? accessToken = await _getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.data['code'] == '1412') {
          _handlePairingDisconnected();
        }
        return handler.next(response);
      },
      onError: (DioError error, handler) {
        if (error.response != null && error.response!.data['code'] == '1412') {
          _handlePairingDisconnected();
        }
        return handler.next(error);
      },
    ));
  }

  Future<Response<dynamic>> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      final response = await dio.get(
          url,
          queryParameters: queryParameters,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      return response;
    } catch (e) {
      print('get...e........$e');
      rethrow;
    }
  }

  Future<Response<dynamic>> post(String url, {dynamic data}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      final response = await dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      return response;
    } catch (e) {
      print('e........$e');
      rethrow;
    }
  }

  void _handlePairingDisconnected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');

    runApp(MaterialApp(
      home: LoginScreen(),
    ));
  }

  Future<String?> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
}
