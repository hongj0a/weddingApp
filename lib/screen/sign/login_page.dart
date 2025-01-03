import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:smart_wedding/screen/main/home_screen.dart';
import 'package:smart_wedding/screen/sign/pairing_page.dart';
import '../../config/ApiConstants.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  _tapCount++;
                  if (_tapCount == 3) {
                    _tapCount = 0;
                    Map<String, dynamic> response = await _sendAuthenticateRequest(
                      "000718.a9f576368b8b407999ab1dcc2b9fcd0f.0348",
                      "사용자",
                      "APPLE",
                    );

                    if (response['isAuthenticated']) {
                      bool pairingYn = response['pairingYn'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => pairingYn
                              ? WeddingHomePage()
                              : PairingCodePage(
                            id: "000718.a9f576368b8b407999ab1dcc2b9fcd0f.0348",
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Image.asset(
                  'asset/img/lgoo.png',
                  height: 300,
                  width: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 15,
              right: 15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _kakaoLogin(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('asset/img/k_btn.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      await _googleLogin(context);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('asset/img/g_btn.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  if (Platform.isIOS) SizedBox(height: 10),
                  if (Platform.isIOS)
                    GestureDetector(
                      onTap: () async {
                        await _appleLogin(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('asset/img/a_btn.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  Text(
                    "우리의 웨딩 월렛 서비스는 예비 부부가 함께 \n결혼 예산 계획을 관리할 수 있도록 설계 되었습니다. \n원활한 앱 사용을 위해 로그인 후 이용해 주세요.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _getFCM() async{
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    print('_fcmToken... $fcmToken');

    return fcmToken;
  }

  Future<void> _kakaoLogin(BuildContext context) async {
    try {
      bool isKakaoInstalled = await isKakaoTalkInstalled();
      OAuthToken? token;

      if (isKakaoInstalled) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      if (token != null) {
        User user = await UserApi.instance.me();
        String id = user.id.toString();
        String name = user.kakaoAccount?.profile?.nickname ?? '사용자';
        String snsType = 'KAKAO';
        Map<String, dynamic> response = await _sendAuthenticateRequest(id, name, snsType);

        if (response['isAuthenticated']) {
          bool pairingYn = response['pairingYn'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              pairingYn ? WeddingHomePage() : PairingCodePage(id: id),
            ),
          );
        }
      }
    } catch (e) {
      print('카카오 로그인 실패: $e');
    }
  }

  Future<void> _googleLogin(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      print('google login...... start.......');
      if (googleUser != null) {
        print('googleUSer... $googleUser');
        String id = googleUser.id;
        String name = googleUser.displayName ?? '사용자';
        String snsType = 'GOOGLE';
        Map<String, dynamic> response = await _sendAuthenticateRequest(id, name, snsType);

        if (response['isAuthenticated']) {
          bool pairingYn = response['pairingYn'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
              pairingYn ? WeddingHomePage() : PairingCodePage(id: id),
            ),
          );
        }
      }
    } catch (e) {
      print('구글 로그인 실패: $e');
    }
  }

  Future<void> _appleLogin(BuildContext context) async {
    try {
      final AuthorizationCredentialAppleID credential =
      await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String id = credential.userIdentifier ?? '';
      if (id.isEmpty) {
        throw Exception('User identifier is missing');
      }
      final String name = credential.givenName ?? '사용자';
      const String snsType = 'APPLE';

      Map<String, dynamic> response = await _sendAuthenticateRequest(id, name, snsType);

      if (response['isAuthenticated']) {
        bool pairingYn = response['pairingYn'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
            pairingYn ? WeddingHomePage() : PairingCodePage(id: id),
          ),
        );
      }
    } catch (e) {
      print('Apple 로그인 실패: $e');
    }
  }



  Future<Map<String, dynamic>> _sendAuthenticateRequest(
      String snsId, String name, String snsType) async {
    final url = ApiConstants.authenticate;
    String? token = await _getFCM();
    print('token.. $token');
    final loginDto = {
      'email': snsId,
      'snsType': snsType,
      'name': name,
      'fcmToken': token,
    };

    try {
      final response = await http.post (
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginDto),
      );

      print('response.statusCode ... ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OK') {
          String accessToken = responseData['data']['accessToken'];
          String refreshToken = responseData['data']['refreshToken'];
          await _saveTokens(accessToken, refreshToken);
          return {
            'isAuthenticated': true,
            'pairingYn': responseData['data']['pairingYn']
          };
        }
      }
      return {'isAuthenticated': false, 'pairingYn': false};
    } catch (e) {
      return {'isAuthenticated': false, 'pairingYn': false};
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstYn = prefs.getBool('isFirstYn');

    print('isFirstYn... $isFirstYn');
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    if (isFirstYn =="" || isFirstYn == null) {
      await prefs.setBool('isFirstYn', true);
    }
  }
}
