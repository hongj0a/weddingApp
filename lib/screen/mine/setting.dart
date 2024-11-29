import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:smart_wedding/screen/sign/login_page.dart';
import 'package:smart_wedding/screen/sign/pairing_page.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';

class Setting extends StatefulWidget {
  final String userId;

  // 생성자 추가
  Setting({required this.userId});

  @override
  _SettingState createState() => _SettingState();
}


class _SettingState extends State<Setting> {
  ApiService apiService = ApiService();
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
                        '앱 내 모든 데이터를 삭제해요.\n미리 내려받지 않았거나, 기기에 저장되지 않은 \n데이터는 저장기간이 만료된 이후 \n다시 불러올 수 없어요.',
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
              // 스토어 배포 후 코딩
            },
          ),
          ListTile(
            title: Text('페어링 끊기'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white, // 하얀색 배경 설정
                    title: Text(
                      '페어링 해제',
                      style: TextStyle(color: Colors.black), // 검은색 제목 텍스트
                    ),
                    content: Text(
                      '페어링을 해제하면 페어링 코드에 엮인 \n데이터가 모두 삭제돼요. \n정말로 페어링을 해제 하시겠어요?',
                      style: TextStyle(color: Colors.black), // 검은색 내용 텍스트
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 취소 버튼: 다이얼로그 닫기
                        },
                        child: Text(
                          '취소',
                          style: TextStyle(color: Colors.black), // 검은색 버튼 텍스트
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                          _setPairingDelete(context); // 페어링 해제 함수 호출
                        },
                        child: Text(
                          '확인',
                          style: TextStyle(color: Colors.black), // 검은색 버튼 텍스트
                        ),
                      ),
                    ],
                  );
                },
              );
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
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white, // 하얀색 배경
                    title: Text(
                      '탈퇴 확인',
                      style: TextStyle(color: Colors.black), // 검은색 제목 텍스트
                    ),
                    content: Text(
                      '탈퇴하시면 모든 데이터가 삭제되며, \n삭제된 데이터는 복구할 수 없어요. \n정말로 탈퇴하시겠어요?',
                      style: TextStyle(color: Colors.black), // 검은색 내용 텍스트
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                        },
                        child: Text(
                          '취소',
                          style: TextStyle(color: Colors.black), // 검은색 취소 버튼 텍스트
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                          _setUserDelete(context); // 탈퇴 함수 호출
                        },
                        child: Text(
                          '확인',
                          style: TextStyle(color: Colors.black), // 검은색 확인 버튼 텍스트
                        ),
                      ),
                    ],
                  );
                },
              );
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

      final response = await apiService.post(
        ApiConstants.delUser,
      );

      if (response.statusCode == 200) {

        print('회원 탈퇴 성공');// 토큰 삭제 및 로그인 페이지로 이동
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');

        // 로그인 페이지로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()), // 로그인 페이지로 이동
        );
      } else {
        print('회원 탈퇴 실패: ${response.statusCode}');
        print('실패 메시지 ${response.data}');
      }
    }catch (e) {
      print('요청 실패, $e');
    }
  }

  void _setPairingDelete(BuildContext context) async{
    try {
      final response = await apiService.post(
          ApiConstants.delPairing,
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => PairingCodePage(id: widget.userId)),
              (route) => false, // 이전 모든 화면을 제거하여 뒤로가기 버튼 표시 안 됨
        );
        print('페어링 끊기 성공');
      } else {
        print('페어링 끊기 실패: ${response.statusCode}');
        print('실패 메시지 ${response.data}');
      }
    }catch (e) {
      print('요청 실패, $e');
    }
  }
}
