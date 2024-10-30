import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/mine/terms_of_service_page.dart';
import 'package:http/http.dart' as http;
import 'package:smart_wedding/screen/sign/login_page.dart';
import 'package:smart_wedding/screen/sign/pairing_page.dart';
import '../../config/ApiConstants.dart';

class Setting extends StatefulWidget {
  final String userId;

  // 생성자 추가
  Setting({required this.userId});

  @override
  _SettingState createState() => _SettingState();
}


class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('설정'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('캐시 데이터 삭제'),
              onTap: () async {
                bool? confirm = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text('캐시 데이터 삭제', style: TextStyle(color: Colors.black),),
                      content: Text(
                        '앱 내 모든 데이터를 삭제해요.\n미리 내려받지 않았거나, 기기에 저장되지 않은 \n데이터는 저장기간이 만료된 이후 \n 다시 불러올 수 없어요.',
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.justify, // 텍스트 정렬 설정
                        softWrap: true,
                      ),actions: <Widget>[
                        TextButton(
                          child: Text('취소', style: TextStyle(color: Colors.black),),
                          onPressed: () {
                            Navigator.of(context).pop(false);  // false 반환
                          },
                        ),
                        TextButton(
                          child: Text('확인', style: TextStyle(color: Colors.black),),
                          onPressed: () {
                            Navigator.of(context).pop(true);  // true 반환
                          },
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? accessToken = prefs.getString('accessToken');
                  String? refreshToken = prefs.getString('refreshToken');

                  await prefs.clear();

                  if (accessToken != null) {
                    await prefs.setString('accessToken', accessToken);
                  }
                  if (refreshToken != null) {
                    await prefs.setString('refreshToken', refreshToken);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('캐시 데이터가 삭제되었습니다.')),
                  );
                }
              }
          ),
          ListTile(
            title: Text('최신 버전 업데이트'),
            onTap: () {

            },
          ),
          ListTile(
            title: Text('패어링 끊기'),
            onTap: () {
              _setPairingDelete(context);
            },
          ),
          ListTile(
            title: Text('로그아웃'),
            onTap: () async {
              await _logout(context);
            },
          ),
          ListTile(
            title: Text('탈퇴하기'),
            onTap: () {
              _setUserDelete(context);
            },
          ),
        ],
      ),
    );
  }
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 토큰 삭제
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');

    // 로그인 페이지로 이동
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 페이지로 이동
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('로그아웃 되었습니다.')),
    );
  }

  void _setUserDelete(BuildContext context) async{
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final response = await http.post(
        Uri.parse(ApiConstants.delUser),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {

        print('회원탈퇴성공');// 토큰 삭제 및 로그인 페이지로 이동
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');

        // 로그인 페이지로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 페이지로 이동
        );
      } else {
        print('회원 탈퇴 실패: ${response.statusCode}');
        print('실패 메시지 ${response.body}');
      }
    }catch (e) {
      print('요청 실패, $e');
    }
  }

  void _setPairingDelete(BuildContext context) async{
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final response = await http.post(
        Uri.parse(ApiConstants.delPairing),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => PairingCodePage(id: widget.userId)), // 로그인 페이지로 이동
        );
        print('페어링 끊기 성공');
      } else {
        print('페어링 끊기 실패: ${response.statusCode}');
        print('실패 메시지 ${response.body}');
      }
    }catch (e) {
      print('요청 실패, $e');
    }
  }
}
