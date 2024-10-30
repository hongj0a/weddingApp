import 'package:flutter/material.dart';

class NoticeDetail extends StatelessWidget {
  final String title;
  final String date;

  NoticeDetail({required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('공지사항', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 1.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오류로 인하여 서비스 이용에 불편을 드려 죄송합니다.',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              '2022.02.18',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20.0),
            Text(
              '금일 02/18(금) 오전 11시 50분 ~ 1시 15분까지 약 1시간 25분 동안 데이터베이스 문제로 앱 전체의 접속 오류가 발생하였습니다.',
              style: TextStyle(fontSize: 16.0, height: 1.5),
            ),
            SizedBox(height: 20.0),
            Text(
              '갑작스러운 오류로 인해 많은 사용자분들의 서비스 이용에 불편을 끼쳐드린 점 깊은 사과의 말씀을 드립니다.',
              style: TextStyle(fontSize: 16.0, height: 1.5),
            ),
            SizedBox(height: 20.0),
            Text(
              '현재는 정상적으로 서비스 이용이 가능하도록 개선되었습니다.',
              style: TextStyle(fontSize: 16.0, height: 1.5),
            ),
            SizedBox(height: 20.0),
            Text(
              '추후에는 동일한 문제가 발생되지 않도록 노력하겠습니다.',
              style: TextStyle(fontSize: 16.0, height: 1.5),
            ),
            SizedBox(height: 20.0),
            Text(
              '다시 한 번 서비스 이용에 불편을 드려 진심으로 죄송합니다.',
              style: TextStyle(fontSize: 16.0, height: 1.5),
            ),
            SizedBox(height: 20.0),
            Text(
              '엘리트웨딩 팀 드림',
              style: TextStyle(fontSize: 16.0, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
