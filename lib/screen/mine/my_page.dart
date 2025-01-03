import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/mine/event_screen.dart';
import 'package:smart_wedding/screen/mine/setting.dart';
import 'package:smart_wedding/screen/money/budget_setting.dart';
import 'package:smart_wedding/screen/mine/d_day_management.dart';
import 'package:smart_wedding/screen/mine/faq_screen.dart';
import 'package:smart_wedding/screen/mine/inquiry_screen.dart';
import 'package:smart_wedding/screen/mine/notice_list.dart';
import 'package:smart_wedding/screen/mine/profile_edit.dart';
import 'package:smart_wedding/screen/mine/terms_and_policies.dart';

import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';



class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  Future<Map<String, dynamic>>? _userInfoFuture;
  Map<String, dynamic>? _userData;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _userInfoFuture = fetchUserInfo();
  }

  Future<Map<String, dynamic>> fetchUserInfo() async {


    var response = await apiService.get(
      ApiConstants.getUserInfo,

    );

    if (response.statusCode == 200) {
      return response.data['data'];
    } else {
      throw Exception('Failed to load user info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 2,
            child: FutureBuilder<Map<String, dynamic>>(
              future: _userInfoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
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
                                    '${_userData?['nickName'] ?? "사용자"} 님',
                                    style: TextStyle(
                                      
                                      color: Colors.black,
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Pretendard'
                                    ),
                                  ),
                                  SizedBox(width: 20.0),
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
                                          _userInfoFuture = fetchUserInfo();
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
                                '${_userData?['pairing'] ?? "페어링 정보 없음"}님과 페어링 중',
                                style: TextStyle(
                                   
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Pretendard'
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 50.0,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: _userData?['image'] != null && _userData!['image'].isNotEmpty
                              ? NetworkImage(_userData!['image'])
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
            height: 0.5,
            color: Colors.grey,
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
                    style: TextStyle(fontFamily: 'Pretendard' )),
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
                      style: TextStyle(fontFamily: 'Pretendard'  )),
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
                      style: TextStyle(fontFamily: 'Pretendard'  )),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('공지사항',
                      style: TextStyle(fontFamily: 'Pretendard'  )),
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
                      style: TextStyle(fontFamily: 'Pretendard'  )),
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
                      style: TextStyle(fontFamily: 'Pretendard'  )),
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
                      style: TextStyle(fontFamily: 'Pretendard'  )),
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
                      style: TextStyle(fontFamily: 'Pretendard'  )),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          print('user... ${_userData}');
                          print('userId.... ${_userData?['id']}');
                          return Setting(userId: _userData?['id']);
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
