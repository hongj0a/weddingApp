import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/mine/faq_detail.dart';


class QuestionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('운영 정책'),
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
            title: Text('올바른 앱 사용 방법'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FaqDetail()),
              );
            },
          ),
          ListTile(
            title: Text('불법, 유해 콘텐츠'),
            onTap: () {
              // '개인정보 처리방침' 클릭 시 동작
            },
          ),
          ListTile(
            title: Text('범죄 및 유해 행위'),
            onTap: () {
              // '운영정책' 클릭 시 동작
            },
          ),
          ListTile(
            title: Text('회사정보'),
            onTap: () {
              // '회사정보' 클릭 시 동작
            },
          ),
        ],
      ),
    );
  }
}
