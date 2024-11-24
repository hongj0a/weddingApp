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
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/ApiConstants.dart';
import '../../themes/theme.dart';

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
    String? refreshToken = prefs.getString('refreshToken');

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
    return WillPopScope(
      onWillPop: () async => false, // 뒤로가기 비활성화
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false, // 기본 왼쪽 아이콘 제거
          title: GestureDetector(
            onTap: navigateToMainPage,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
              crossAxisAlignment: CrossAxisAlignment.center, // 수직 중앙 정렬
              children: [
                // 로고 이미지 (왼쪽에 배치)
                Image.asset(
                  'asset/img/mini_logo.png', // 로고 이미지 경로
                  width: 26, // Figma에서 설정된 Width
                  height: 31, // Figma에서 설정된 Height
                ),
                // 로고와 텍스트 사이 간격을 줄이기 위해 SizedBox 추가
                SizedBox(width: 8), // 간격 조정
                // 텍스트 로고 이미지
                SvgPicture.asset(
                  'asset/img/mini_logo_text.svg', // 텍스트 로고 이미지 경로
                  width: 39, // Figma에서 설정된 Width
                  height: 20, // Figma에서 설정된 Height
                  fit: BoxFit.contain, // 비율 유지
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0), // 오른쪽 여백 추가
              child: FutureBuilder<bool>(
                future: getNewFlag(),
                builder: (context, snapshot) {
                  bool newFlag = snapshot.data ?? false;
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AlarmListPage()),
                          );
                          refreshNewFlag(); // 알림 리스트 페이지 닫힌 후 새로고침
                        },
                        child: SvgPicture.asset(
                          'asset/img/unt.svg', // SVG 아이콘 경로
                          width: 20,  // 아이콘 크기 조정
                          height: 18, // 아이콘 크기 조정
                        ),
                      ),
                      if (newFlag) // newFlag가 true일 때만 표시
                        Positioned(
                          right: 0,
                          top: 0,
                          child: SvgPicture.asset(
                            'asset/img/unt_red.svg', // 새로운 빨간색 SVG 이미지 경로
                            width: 5,  // 원하는 크기로 조정
                            height: 5, // 원하는 크기로 조정
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
          // AppBar 크기 조정
          toolbarHeight: 56,  // 높이를 56으로 맞춤
          elevation: 0,  // 그림자 제거
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
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
          //bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            unselectedItemColor: Colors.black,
            selectedItemColor: AppColors.primaryColor,
            iconSize: 28,
            onTap: (index) {
              setState(() {
                currentIndex = index; // currentIndex 업데이트
              });
              _pageController.jumpToPage(index); // 페이지를 직접 이동
            },
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  currentIndex == 0
                      ? 'asset/img/money_on.svg' // 선택된 상태에서 on 이미지
                      : 'asset/img/money_off.svg', // 비선택 상태에서 off 이미지
                  width: 19, // 아이콘 크기 설정
                  height: 20,
                ),
                label: '예산',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  currentIndex == 1
                      ? 'asset/img/note_on.svg' // 선택된 상태에서 on 이미지
                      : 'asset/img/note_off.svg', // 비선택 상태에서 off 이미지
                  width: 19, // 아이콘 크기 설정
                  height: 20,
                ),
                label: '계약서',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  currentIndex == 2
                      ? 'asset/img/home_on.svg' // 선택된 상태에서 on 이미지
                      : 'asset/img/home_off.svg', // 비선택 상태에서 off 이미지
                  width: 19, // 아이콘 크기 설정
                  height: 20,
                ),
                label: '메인',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  currentIndex == 3
                      ? 'asset/img/calendar_on.svg' // 선택된 상태에서 on 이미지
                      : 'asset/img/calendar_off.svg', // 비선택 상태에서 off 이미지
                  width: 19, // 아이콘 크기 설정
                  height: 20,
                ),
                label: '일정',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  currentIndex == 4
                      ? 'asset/img/mypage_on.svg' // 선택된 상태에서 on 이미지
                      : 'asset/img/mypage_off.svg', // 비선택 상태에서 off 이미지
                  width: 19, // 아이콘 크기 설정
                  height: 20,
                ),
                label: '마이페이지',
              ),
            ],
          ),
        ),
      ),
    );
  }
}