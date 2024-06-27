import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/contract_page.dart';
import 'package:smart_wedding/screen/budget_page.dart';
import 'package:smart_wedding/screen/my_page.dart';
import 'package:smart_wedding/screen/schedule_page.dart';
import 'package:smart_wedding/screen/home_content.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeddingHomePage(),
    );
  }
}

class WeddingHomePage extends StatefulWidget {
  @override
  _WeddingHomePageState createState() => _WeddingHomePageState();
}

class _WeddingHomePageState extends State<WeddingHomePage> {
  int currentIndex = 2;
  final screens = [
    BudgetPage(),
    ContractPage(),
    HomeContent(),
    SchedulePage(),
    MyPage(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'asset/img/ring.png',  // 이미지 파일 경로
              height: 30,  // 이미지 높이 조정
              width: 30,   // 이미지 너비 조정
            ),
            SizedBox(width: 15),  // 이미지와 텍스트 사이의 간격 조정
            Text('스마트웨딩', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),  // 기존 title 텍스트
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            iconSize: 40,
            onPressed: () {},
          ),
        ],
      ),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.shifting,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.green,
        iconSize: 35,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: '예산',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: '계약서',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '메인',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '일정',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}