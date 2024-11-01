import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/document/contract_page.dart';
import 'package:smart_wedding/screen/money/cost_page.dart';
import 'package:smart_wedding/screen/mine/my_page.dart';
import 'package:smart_wedding/screen/diary/schedule_page.dart';
import 'package:smart_wedding/screen/main/home_content.dart';
import 'package:smart_wedding/screen/main/alarm_list_page.dart';
import 'package:http/http.dart' as http;
import '../../config/ApiConstants.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', ''), // 한국어
        const Locale('en', ''), // 영어
      ],
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
  late PageController _pageController;
  final List<Widget> screens = [];
  late Future<bool> newFlagFuture;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex); // 페이지 컨트롤러 초기화
    newFlagFuture = getNewFlag();
    screens.addAll([
      CostPage(),
      ContractPage(),
      HomeContent(onContractSelected: () {
        onContractSelected(); // 인스턴스 메서드 호출 가능
      }),
      SchedulePage(),
      MyPage(),
    ]);
  }
  @override
  void dispose() {
    _pageController.dispose(); // 페이지 컨트롤러 메모리 해제
    super.dispose();
  }

  void onContractSelected() {
    setState(() {
      currentIndex = 1; // 계약서 페이지로 전환
    });
    _pageController.jumpToPage(1); // PageView도 계약서 페이지로 전환
  }

  void navigateToMainPage() {
    setState(() {
      currentIndex = 2;
    });
    _pageController.jumpToPage(2);
  }

  Future<void> refreshNewFlag() async {
    setState(() {
      newFlagFuture = getNewFlag(); // 새로고침 시 getNewFlag 다시 할당
    });
  }

  Future<bool> getNewFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    var url = Uri.parse(ApiConstants.alarmNewFlag);

    var response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json', // JSON 형식의 데이터 전송
      },
    );

    if (response.statusCode == 200) {
      print('response body: ${response.body}'); // JSON 응답 본문을 출력
      var responseData = json.decode(response.body)['data']['newFlag'];

      if (responseData == "true") { // 문자열 비교 시 == 사용
        return true;
      } else {
        return false;
      }

    } else {
      throw Exception('Failed to load user info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: navigateToMainPage,
          child: Row(
            children: [
              Image.asset(
                'asset/img/heart_logo.png',
                height: 35,
                width: 35,
              ),
              SizedBox(width: 10),
              Text(
                '우월',
                style: TextStyle(fontFamily: 'PretendardVariable', fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          FutureBuilder<bool>(
            future: getNewFlag(),
            builder: (context, snapshot) {
              bool newFlag = snapshot.data ?? false;
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_none_outlined),
                    iconSize: 28,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AlarmListPage()),
                      );
                      refreshNewFlag(); // 알림 리스트 페이지 닫힌 후 새로고침
                    },
                  ),
                  if (newFlag) // newFlag가 true일 때만 표시
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(250, 15, 156, 1.0),
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 4,
                          minHeight: 4,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],

      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index; // 페이지가 변경되면 인덱스 업데이트
          });
        },
        children: [
          CostPage(),
          ContractPage(),
          HomeContent(onContractSelected: () {
            onContractSelected();
          }),
          SchedulePage(),
          MyPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Color.fromRGBO(250, 15, 156, 1.0),
        iconSize: 28,
        onTap: (index) {
          setState(() {
            currentIndex = index; // currentIndex 업데이트
          });
          _pageController.jumpToPage(index); // 페이지를 직접 이동
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: '예산',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_add),
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