import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/money/budget_setting.dart';
import 'package:smart_wedding/screen/mine/d_day_management.dart';
import 'package:smart_wedding/screen/mine/faq_screen.dart';
import 'package:smart_wedding/screen/mine/inquiryScreen.dart';
import 'package:smart_wedding/screen/mine/notice_list.dart';
import 'package:smart_wedding/screen/mine/profile_edit.dart';
import 'package:smart_wedding/screen/mine/terms_and_policies.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 2,
            child: Container(
              color: Color.fromRGBO(250, 222, 242, 1.0),
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30.0,
                    child: Icon(Icons.person, size: 50.0),
                  ),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '  {예시니} 님',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          '❤️ {예랑이}님과 페어링 중',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileEditPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 5,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text('예산설정'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BudgetSetting()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('D-day 설정'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DDayManagementPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.event),
                  title: Text('진행 중인 이벤트'),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('공지사항'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NoticeList()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.policy),
                  title: Text('약관 및 정책'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TermsAndPoliciesScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.help),
                  title: Text('자주 묻는 질문'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FAQScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.mail),
                  title: Text('문의하기'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InquiryScreen()),
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