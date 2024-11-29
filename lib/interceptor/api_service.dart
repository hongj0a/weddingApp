import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/sign/login_page.dart';

class ApiService {
  final Dio dio = Dio();

  ApiService() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 액세스 토큰을 헤더에 추가
        String? accessToken = await _getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options); // 요청을 계속 진행
      },
      onResponse: (response, handler) {
        // 응답 처리
        if (response.data['code'] == '1412') {
          _handlePairingDisconnected();
        }
        return handler.next(response); // 응답을 계속 진행
      },
      onError: (DioError error, handler) {
        // 에러 처리
        if (error.response != null && error.response!.data['code'] == '1412') {
          _handlePairingDisconnected();
        }
        return handler.next(error); // 에러를 계속 진행
      },
    ));
  }

  // GET 요청
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
      rethrow; // 에러 처리 (추후 에러 로깅 등 추가할 수 있음)
    }
  }

  // POST 요청
  Future<Response<dynamic>> post(String url, {dynamic data}) async {
  //Future<Response<dynamic>> post(String url, {Map<String, dynamic>? data}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      final response = await dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken', // Authorization 헤더 추가
            'Content-Type': 'application/json', // 필요 시 Content-Type 추가
          },
        ),
      );
      return response;
    } catch (e) {
      print('e........$e');
      rethrow; // 에러 처리 (추후 에러 로깅 등 추가할 수 있음)
    }
  }

  // 페어링 끊어진 경우 처리
  void _handlePairingDisconnected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');

    // 로그인 화면으로 이동
    runApp(MaterialApp(
      home: LoginScreen(),
    ));
  }


  // 액세스 토큰을 SharedPreferences에서 가져오는 함수
  Future<String?> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
}
