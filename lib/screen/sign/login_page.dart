import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:smart_wedding/screen/main/home_screen.dart';
import 'package:smart_wedding/screen/sign/pairing_page.dart';

import '../../config/ApiConstants.dart'; // API URL 정의된 파일
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 로고 가운데 정렬
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'asset/img/heart_logo.png', // 로고 이미지 경로
                    height: 35,
                    width: 35,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '우월',
                    style: TextStyle(fontFamily: 'PretendardVariable', fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 70),
              // 카카오 로그인 버튼
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    print('카카오 로그인 시도 중...');
                    bool isKakaoInstalled = await isKakaoTalkInstalled();
                    OAuthToken? token;

                    if (isKakaoInstalled) {
                      token = await UserApi.instance.loginWithKakaoTalk();
                    } else {
                      token = await UserApi.instance.loginWithKakaoAccount();
                    }

                    if (token != null) {
                      // 로그인 성공
                      print('카카오 로그인 성공: ${token.accessToken}');
                      User user = await UserApi.instance.me();
                      String id = user.id.toString(); // 카카오톡 ID 추출
                      String name = user.kakaoAccount?.profile?.nickname ?? '사용자';
                      String snsType = 'KAKAO'; // SNS 유형 설정

                      print('유저 정보: ${user.kakaoAccount}, name: ${user.kakaoAccount?.profile?.nickname}');

                      // authenticate API 호출
                      Map<String, dynamic> response = await _sendAuthenticateRequest(id, name, snsType);

                      bool isAuthenticated = response['isAuthenticated'];
                      bool pairingYn = response['pairingYn'];

                      // 페어링 여부에 따라 분기 처리
                      if (isAuthenticated) {
                        if (pairingYn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WeddingHomePage()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PairingCodePage(id: id)),
                          );
                        }
                      } else {
                        print('인증 실패');
                      }
                    }
                  } catch (e) {
                    print('카카오 로그인 실패: $e');
                  }
                },
                icon: SvgPicture.asset(
                  'asset/img/kakao_btn.svg', // 카카오톡 아이콘 경로
                  height: 24,
                ),
                label: Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Text('카카오 로그인', style:  TextStyle(fontFamily: 'PretendardVariable')),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFE812), // 카카오 노란색
                  foregroundColor: Colors.black, // 텍스트 색상
                  minimumSize: Size(double.infinity, 50), // 버튼 전체 너비
                ),
              ),
              SizedBox(height: 10),
              // 구글 로그인 버튼
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    print('구글 로그인 시도 중...');
                    final GoogleSignIn googleSignIn = GoogleSignIn();

                    // 이전 로그인 세션 종료
                    await googleSignIn.signOut();

                    // 구글 로그인 화면 표시
                    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

                    if (googleUser != null) {
                      // 로그인 성공
                      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
                      String id = googleUser.id; // 구글 사용자 ID
                      String name = googleUser.displayName ?? '사용자'; // 사용자 이름
                      String snsType = 'GOOGLE'; // SNS 유형 설정

                      print('유저 정보: ${googleUser}, ID: $id');
                      print('name? : ${googleUser.displayName}');
                      print('name! : $name');

                      // authenticate API 호출
                      Map<String, dynamic> response = await _sendAuthenticateRequest(id, name, snsType);

                      bool isAuthenticated = response['isAuthenticated'];
                      print('isAuthenticated : $isAuthenticated');
                      print('response: $response');
                      bool pairingYn = response['pairingYn'];

                      // 페어링 여부에 따라 분기 처리
                      if (isAuthenticated) {
                        if (pairingYn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WeddingHomePage()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PairingCodePage(id: id)),
                          );
                        }
                      } else {
                        print('인증 실패');
                      }
                    }
                  } catch (e) {
                    print('구글 로그인 실패: $e');
                  }
                },
                icon: SvgPicture.asset(
                  'asset/img/google_btn.svg', // 구글 아이콘 경로
                  height: 24,
                ),
                label: Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Text('구글 로그인', style:  TextStyle(fontFamily: 'PretendardVariable')),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // 구글 버튼 색상
                  foregroundColor: Colors.black, // 텍스트 색상
                  minimumSize: Size(double.infinity, 50), // 버튼 전체 너비
                  side: BorderSide(color: Colors.grey), // 버튼 테두리 색상
                ),
              ),
              SizedBox(height: 10),
              // 구글 로그인 버튼
              if (Platform.isIOS)
              ElevatedButton.icon(
                onPressed: () {

                },
                icon: SvgPicture.asset(
                  'asset/img/apple_btn.svg', // 구글 아이콘 경로
                  height: 24,
                ),
                label: Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Text('애플 로그인', style:  TextStyle(fontFamily: 'PretendardVariable')),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // 배경 색상 검정
                  foregroundColor: Colors.white, // 텍스트 색상 흰색
                  minimumSize: Size(double.infinity, 50), // 버튼 전체 너비
                  side: BorderSide(color: Colors.black), // 버튼 테두리 색상
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<Map<String, dynamic>> _sendAuthenticateRequest(String snsId, String name, String snsType) async {
    final url = ApiConstants.authenticate; // API URL

    final loginDto = {
      'email': snsId, // SNS ID를 이메일 필드로 사용
      'snsType': snsType,
      'name': name
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginDto),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['code'] == 'OK') {
          // 서버에서 성공 응답 ('OK')을 받으면 true와 페어링 상태 반환
          String accessToken = responseData['data']['accessToken'];
          String refreshToken = responseData['data']['refreshToken'];
          await _saveTokens(accessToken, refreshToken);
          print('인증 성공');
          return {'isAuthenticated': true, 'pairingYn': responseData['data']['pairingYn']};
        } else {
          print('인증 실패: ${responseData['message']}');
          return {'isAuthenticated': false, 'pairingYn': false};
        }
      } else {
        print('HTTP 요청 실패: ${response.statusCode}');
        return {'isAuthenticated': false, 'pairingYn': false};
      }
    } catch (e) {
      print('예외 발생: $e');
      return {'isAuthenticated': false, 'pairingYn': false};
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('저장된 토큰 정보 $refreshToken');
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }
}
