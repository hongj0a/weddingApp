import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/mine/setting.dart';
import 'package:smart_wedding/screen/money/budget_setting.dart';
import 'package:smart_wedding/screen/mine/d_day_management.dart';
import 'package:smart_wedding/screen/mine/faq_screen.dart';
import 'package:smart_wedding/screen/mine/inquiry_screen.dart';
import 'package:smart_wedding/screen/mine/notice_list.dart';
import 'package:smart_wedding/screen/mine/profile_edit.dart';
import 'package:smart_wedding/screen/mine/terms_and_policies.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/ApiConstants.dart';

Future<Map<String, dynamic>> fetchUserInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken');

  var url = Uri.parse(ApiConstants.getUserInfo);

  var response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json', // JSON 형식의 데이터 전송
    },
  );

  if (response.statusCode == 200) {
    return json.decode(response.body)['data']; // 'data' 부분에서 필요한 정보를 가져옴
  } else {
    throw Exception('Failed to load user info');
  }
}

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  Future<Map<String, dynamic>>? _userInfoFuture;
  Map<String, dynamic>? _userData; // userData를 상태 변수로 추가

  @override
  void initState() {
    super.initState();
    _userInfoFuture = fetchUserInfo(); // API 호출
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = '${ApiConstants.localImagePath}/';
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 2,
            child: FutureBuilder<Map<String, dynamic>>(
              future: _userInfoFuture, // API 호출
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // 로딩 중
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}')); // 에러 발생 시
                } else if (snapshot.hasData) {
                  // 성공적으로 데이터를 받아왔을 때
                  _userData = snapshot.data!;
                  return Container(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: 5.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                children: [
                                  Text(
                                    '${_userData?['nickName'] ?? "사용자"} 님', // null 체크 및 기본값 설정
                                    // API에서 받은 닉네임 사용
                                    style: TextStyle(
                                      
                                      color: Colors.black,
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 20.0), // 아이콘과 텍스트 사이 여백
                                  GestureDetector(
                                    onTap: ()  async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProfileEditPage(),
                                        ),
                                      );
                                      if (result == true) {
                                        setState(() {
                                          _userInfoFuture = fetchUserInfo(); // 새로 고침
                                        });
                                      }
                                    },
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 13.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                '${_userData?['pairing'] ?? "페어링 정보 없음"}님과 페어링 중', // null 체크 및 기본값 설정
                                // API에서 받은 페어링 정보 사용
                                style: TextStyle(
                                   
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 50.0,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: _userData?['image'] != null && _userData!['image'].isNotEmpty
                              ? NetworkImage('$imageUrl${_userData!['image']}')
                              : null,
                          child: _userData?['image'] == null || _userData!['image'].isEmpty
                              ? Icon(Icons.person, size: 50.0)
                              : null,
                        ),
                        SizedBox(height: 5.0),
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            ),
          ),
          Container(
            height: 0.5, // 선의 두께
            color: Colors.grey, // 선의 색상
          ),
          SizedBox(height: 10.0),
          Flexible(
            flex: 5,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text('예산설정',
                    style: TextStyle( )),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BudgetSetting(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.calendar_month),
                  title: Text('D-day 설정',
                      style: TextStyle( )),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DDayManagementPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.event),
                  title: Text('진행 중인 이벤트',
                      style: TextStyle( )),
                  onTap: () { // 디자이너 고용후, 간단한 이벤트 페이지 추가
                    },
                ),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('공지사항',
                      style: TextStyle( )),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoticeList(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.policy),
                  title: Text('약관 및 정책',
                      style: TextStyle( )),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TermsAndPoliciesScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help),
                  title: Text('자주 묻는 질문',
                      style: TextStyle( )),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FAQScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.mail),
                  title: Text('문의하기',
                      style: TextStyle( )),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InquiryScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('설정',
                      style: TextStyle( )),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          // 이 곳에서 print를 찍습니다.
                          print('user... ${_userData}');
                          print('userId.... ${_userData?['id']}'); // ID 출력
                          return Setting(userId: _userData?['id']); // ID 전달
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
