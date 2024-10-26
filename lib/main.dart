import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/main/home_screen.dart';
import 'package:smart_wedding/screen/sign/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:smart_wedding/screen/sign/pairing_page.dart';
import 'config/ApiConstants.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: '9a794384618b41b8322fb7fed2baa529');

  // 저장된 refreshToken 확인
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? refreshToken = prefs.getString('refreshToken');

  if (refreshToken != null) {
    await _extendLogin(refreshToken);
  } else {
    runApp(MaterialApp(home: LoginScreen())); // 토큰이 없으면 로그인 화면으로
  }
}

Future<void> _extendLogin(String refreshToken) async {
  final url = ApiConstants.refreshTokenValidation; // 토큰 갱신 API URL

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['code'] == 'OK') {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // 새로운 accessToken 및 refreshToken 저장
        await prefs.setString('accessToken', responseData['data']['accessToken']);
        await prefs.setString('refreshToken', responseData['data']['refreshToken']);

        print('accessToken :::::: ${prefs.getString('accessToken')}');
        // pairingYn에 따른 분기 처리
        bool pairingYn = responseData['data']['pairingYn'];

        if (pairingYn) {
          // pairing이 완료된 상태라면 WeddingHomePage로 이동
          runApp(MaterialApp(home: WeddingHomePage()));
        } else {
          // pairing이 완료되지 않은 상태라면 PairingCodePage로 이동
          String id = responseData['data']['id']; // id 값 추출
          runApp(MaterialApp(home: PairingCodePage(id: id)));
        }
      } else {
        print('토큰 갱신 실패: ${responseData['message']}');
        runApp(MaterialApp(home: LoginScreen())); // 로그인 화면으로 이동
      }
    } else {
      print('HTTP 요청 실패: ${response.statusCode}');
      runApp(MaterialApp(home: LoginScreen())); // 로그인 화면으로 이동
    }
  } catch (e) {
    print('예외 발생: $e');
    runApp(MaterialApp(home: LoginScreen())); // 예외 발생 시 로그인 화면으로 이동
  }
}
