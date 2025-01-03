import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/document/contract_page.dart';
import 'package:smart_wedding/screen/money/cost_page.dart';
import 'package:smart_wedding/screen/mine/my_page.dart';
import 'package:smart_wedding/screen/diary/schedule_page.dart';
import 'package:smart_wedding/screen/main/home_content.dart';
import 'package:smart_wedding/screen/main/alarm_list_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
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
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex);
    newFlagFuture = getNewFlag();
    screens.addAll([
      CostPage(),
      ContractPage(),
      HomeContent(onContractSelected: () {
        onContractSelected();
      }),
      SchedulePage(),
      MyPage(),
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onContractSelected() {
    setState(() {
      currentIndex = 1;
    });
    _pageController.jumpToPage(1);
  }

  void navigateToMainPage() {
    setState(() {
      currentIndex = 2;
    });
    _pageController.jumpToPage(2);
  }

  Future<void> refreshNewFlag() async {
    setState(() {
      newFlagFuture = getNewFlag();
    });
  }

  Future<bool> getNewFlag() async {

    var response = await apiService.get(
      ApiConstants.alarmNewFlag,
    );

    if (response.statusCode == 200) {
      print('response body: ${response.data}');
      var responseData = response.data['data']['newFlag'];

      if (responseData == "true") {
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
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: GestureDetector(
            onTap: navigateToMainPage,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'asset/img/mini_logo.png',
                  width: 26,
                  height: 31,
                ),
                SizedBox(width: 8),
                SvgPicture.asset(
                  'asset/img/mini_logo_text.svg',
                  width: 39,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
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
                            MaterialPageRoute(
                                builder: (context) => AlarmListPage()),
                          );
                          refreshNewFlag();
                        },
                        child: SvgPicture.asset(
                          'asset/img/unt.svg',
                          width: 20,
                          height: 18,
                        ),
                      ),
                      if (newFlag)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: SvgPicture.asset(
                            'asset/img/unt_red.svg',
                            width: 5,
                            height: 5,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
          toolbarHeight: 56,
          elevation: 0,
        ),
        body: currentIndex == 0
            ? Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => CostPage(),
          ),
        )
            : IndexedStack(
          index: currentIndex - 1,
          children: screens.sublist(1), // CostPage 제외
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          unselectedItemColor: Colors.black,
          selectedItemColor: AppColors.primaryColor,
          iconSize: 28,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                currentIndex == 0
                    ? 'asset/img/money_on.svg'
                    : 'asset/img/money_off.svg',
                width: 19,
                height: 20,
              ),
              label: '예산',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                currentIndex == 1
                    ? 'asset/img/note_on.svg'
                    : 'asset/img/note_off.svg',
                width: 19,
                height: 20,
              ),
              label: '계약서',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                currentIndex == 2
                    ? 'asset/img/home_on.svg'
                    : 'asset/img/home_off.svg',
                width: 19,
                height: 20,
              ),
              label: '메인',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                currentIndex == 3
                    ? 'asset/img/calendar_on.svg'
                    : 'asset/img/calendar_off.svg',
                width: 19,
                height: 20,
              ),
              label: '일정',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                currentIndex == 4
                    ? 'asset/img/mypage_on.svg'
                    : 'asset/img/mypage_off.svg',
                width: 19,
                height: 20,
              ),
              label: '마이페이지',
            ),
          ],
        ),
      ),
    );
  }

}