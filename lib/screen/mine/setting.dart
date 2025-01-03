import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/sign/login_page.dart';
import 'package:smart_wedding/screen/sign/pairing_page.dart';
import 'package:smart_wedding/themes/theme.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';

class Setting extends StatefulWidget {
  final String userId;

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
                      title: Text('캐시 데이터 삭제', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold, fontFamily: 'Pretendard'),),
                      content: Text(
                        '앱 내 모든 데이터를 삭제해요.\n미리 내려받지 않았거나, 기기에 저장되지 않은 \n데이터는 저장기간이 만료된 이후 \n다시 불러올 수 없어요.',
                        style: TextStyle(color: Colors.black, fontFamily: 'Pretendard'),
                        textAlign: TextAlign.justify,
                        softWrap: true,
                      ),actions: <Widget> [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(
                          '취소',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Pretendard'
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            '확인',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Pretendard'
                            ),
                          ),
                        ),
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
                    backgroundColor: Colors.white,
                    title: Text(
                      '페어링 해제',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Pretendard'), // 검은색 제목 텍스트
                    ),
                    content: Text(
                      '페어링을 해제하면 페어링 코드에 엮인 \n데이터가 모두 삭제돼요. \n정말로 페어링을 해제 하시겠어요?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontFamily: 'Pretendard'
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          '취소',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Pretendard'
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _setPairingDelete(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            '확인',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Pretendard'
                            ),
                          ),
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
                    backgroundColor: Colors.white,
                    title: Text(
                      '탈퇴 확인',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Pretendard'
                      ),
                    ),
                    content: Text(
                      '탈퇴하시면 모든 데이터가 삭제되며, \n삭제된 데이터는 복구할 수 없어요. \n정말로 탈퇴하시겠어요?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontFamily: 'Pretendard'
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          '취소',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Pretendard'
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _setUserDelete(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            '확인',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Pretendard'
                            ),
                          ),
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

    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen()),
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

        print('회원 탈퇴 성공');
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
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
              (route) => false,
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
