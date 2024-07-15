import 'package:flutter/material.dart';


class TermsAndPoliciesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('약관 및 정책'),
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
            title: Text('서비스 이용약관'),
            onTap: () {
              // '서비스 이용약관' 클릭 시 동작
            },
          ),
          ListTile(
            title: Text('개인정보 처리방침'),
            onTap: () {
              // '개인정보 처리방침' 클릭 시 동작
            },
          ),
          ListTile(
            title: Text('운영정책'),
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
