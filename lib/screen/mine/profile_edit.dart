import 'package:flutter/material.dart';

class ProfileEditPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 수정'),
        actions: [
          TextButton(
            onPressed: () {
              // 완료 버튼을 눌렀을 때 실행될 코드
            },
            child: Text(
              '완료',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView( // SingleChildScrollView로 감싸서 스크롤 가능하도록 만듦
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Colors.grey[200],
                    child: Icon(Icons.person, size: 50.0),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 140,
                    child: CircleAvatar(
                      radius: 15.0,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, size: 18.0, color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '닉네임',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 5.0),
              TextField(
                //controller: _nicknameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '페어링코드',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 5.0),
              TextField(
                //controller: _nicknameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '페어링상대',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 5.0),
              TextField(
                //controller: _nicknameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
