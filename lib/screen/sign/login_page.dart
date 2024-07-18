import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/main/home_screen.dart';
import 'package:smart_wedding/screen/sign/find_account_screen.dart';


class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 로고 가운데 정렬
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'asset/img/ring.png', // 로고 이미지 경로를 여기에 넣으세요
                    height: 30,
                    width: 30,
                  ),
                  SizedBox(width: 15),
                  Text(
                    '스마트웨딩',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 50),
              // 카카오 로그인 버튼
              ElevatedButton.icon(
                onPressed: () {
                  // 카카오 로그인 처리
                },
                icon: Image.asset(
                  'asset/img/kakao.png', // 카카오톡 아이콘 경로
                  height: 24,
                ),
                label: Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Text('카카오로 로그인'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFE812), // 카카오 노란색
                  foregroundColor: Colors.black, // 텍스트 색상
                  minimumSize: Size(double.infinity, 50), // 버튼 전체 너비
                ),
              ),
              SizedBox(height: 10),
              // 구글 로그인 버튼
              ElevatedButton.icon(
                onPressed: () {
                  // 구글 로그인 처리
                },
                icon: Image.asset(
                  'asset/img/google.jpeg', // 구글 아이콘 경로
                  height: 24,
                ),
                label: Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Text('구글로 로그인'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // 구글 버튼 색상
                  foregroundColor: Colors.black, // 텍스트 색상
                  minimumSize: Size(double.infinity, 50), // 버튼 전체 너비
                  side: BorderSide(color: Colors.grey), // 버튼 테두리 색상
                ),
              ),
              SizedBox(height: 20),
              // 아이디/비밀번호 찾기
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FindAccountScreen()),
                  );
                },
                child: Text('아이디/비밀번호 찾기'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WeddingHomePage()),
                  );
                },
                child: Text('메인으로'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}