import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/contract_page.dart';
import 'package:smart_wedding/screen/budget_page.dart';
import 'package:smart_wedding/screen/my_page.dart';
import 'package:smart_wedding/screen/schedule_page.dart';
import 'package:smart_wedding/screen/home_content.dart';
import 'package:smart_wedding/screen/alarm_list_page.dart';

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
  //
  final screens = [
    BudgetPage(),
    ContractPage(),
    HomeContent(),
    SchedulePage(),
    MyPage(),
  ];

  void navigateToMainPage() {
    setState(() {
      currentIndex = 2;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: navigateToMainPage,
          child: Row(
            children: [
              Image.asset(
                'asset/img/ring.png',
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
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            iconSize: 40,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlarmListPage()),
              );
            },
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