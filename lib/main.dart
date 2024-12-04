import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/main/home_screen.dart';
import 'package:smart_wedding/screen/sign/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:smart_wedding/screen/sign/pairing_page.dart';
import 'config/ApiConstants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 먼저
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Firebase가 초기화된 후에 Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: '9a794384618b41b8322fb7fed2baa529');

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? refreshToken = prefs.getString('refreshToken');
  String? accessToken = prefs.getString('accessToken');
  bool? isFirstYn = prefs.getBool('isFirstYn');

  print('refreshToken..!!!!!!!!!! $refreshToken');
  print('accessToken...!!!!!!!!! $accessToken');
  print('isFirstYn...!!!!!!!!!!! $isFirstYn');

  /*String? _fcmToken = await FirebaseMessaging.instance.getToken();
  print('_fcmToken... $_fcmToken');
*/
  // refreshToken이 있는 경우에만 로그인 연장 시도
  if (refreshToken != null) {
    try {
      Map<String, dynamic> result = await _extendLogin(refreshToken);
      bool pairingYn = result['pairingYn'];
      String id = result['id'];
      // 로그인 연장이 성공하면 홈 화면으로 이동
      if (pairingYn) {
        runApp(WeddingApp());
      } else {
        runApp(PairingCodeApp(id: id));
      }
    } catch (e) {
      print('토큰 갱신 실패: $e');
      // refreshToken 만료 등으로 실패 시 로그인 화면으로 이동
      runApp(LoginApp());
    }
  } else {
    // refreshToken이 없으면 바로 로그인 화면으로 이동
    runApp(LoginApp());
  }
}

Future<Map<String, dynamic>> _extendLogin(String refreshToken) async {
  final url = ApiConstants.refreshTokenValidation;

  try {
    final response = await http.post (
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['code'] == 'OK') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', responseData['data']['accessToken']);
        await prefs.setString('refreshToken', responseData['data']['refreshToken']);
        print('accessToken :::::: ${prefs.getString('accessToken')}');

        bool pairingYn = responseData['data']['pairingYn'];
        String id = responseData['data']['id'];

        return {
          'pairingYn': pairingYn,
          'id': id,
        };
      } else {
        throw Exception('회원을 찾을 수 없습니다');
      }
    } else {
      throw Exception('HTTP 요청 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('예외 발생: $e');
    throw e;
  }
}

class WeddingApp extends StatelessWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermission();
    });
    return MaterialApp(

      navigatorObservers: <NavigatorObserver>[observer],
      home: WeddingHomePage(),
      locale: Locale('ko', 'KR'),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ko', 'KR'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  Future<void> _requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('푸시 알림 권한이 부여되었습니다.');
    } else {
      print('푸시 알림 권한이 거부되었습니다.');
    }
  }

}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      locale: Locale('ko', 'KR'),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ko', 'KR'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

class PairingCodeApp extends StatelessWidget {
  final String id;

  PairingCodeApp({required this.id});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PairingCodePage(id: id,),
      locale: Locale('ko', 'KR'),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ko', 'KR'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

