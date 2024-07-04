import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            color: Colors.purple,
            padding: EdgeInsets.all(16.0),
            child: Row(
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
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            '{예시니} 님',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              // 편집 버튼을 눌렀을 때 실행될 코드
                            },
                          ),
                        ],
                      ),
                      Text(
                        '❤️ {예랑이}님과 페어링 중 or 페어링 등록하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Text('예산설정'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('D-day 설정'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.event),
            title: Text('진행 중인 이벤트'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('공지사항'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.policy),
            title: Text('약관 및 정책'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('자주 묻는 질문'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.mail),
            title: Text('문의하기'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
