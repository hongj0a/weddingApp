import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/mine/terms_of_service_page.dart';


class Setting extends StatelessWidget {
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
            onTap: () {

            },
          ),
          ListTile(
            title: Text('최신 버전 업데이트'),
            onTap: () {
              // '개인정보 처리방침' 클릭 시 동작
            },
          ),
          ListTile(
            title: Text('패어링 끊기'),
            onTap: () {
              // '개인정보 처리방침' 클릭 시 동작
            },
          ),
          ListTile(
            title: Text('로그아웃'),
            onTap: () {
              // '운영정책' 클릭 시 동작
            },
          ),
          ListTile(
            title: Text('탈퇴하기'),
            onTap: () {
              // '회사정보' 클릭 시 동작
            },
          ),
        ],
      ),
    );
  }
}
