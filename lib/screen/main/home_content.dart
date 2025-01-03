import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/mine/d_day_card.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import '../../themes/theme.dart';
import '../mine/d_day_management.dart';
import '../mine/event_screen.dart';
import 'budget_card.dart';

class HomeContent extends StatefulWidget {
  final VoidCallback onContractSelected;

  HomeContent({
  required this.onContractSelected});

  @override
  _HomeContentState createState() => _HomeContentState();
}


class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  late Future<List<Map<String, dynamic>>> futureDDays;
  List<Map<String, dynamic>> ddayList = [];
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    //fetchDDay();
    futureDDays = fetchDDay();
    _checkIfFirstTimeUser();
  }

  Future<void> refreshDDay() async {
    try {
      final newDDays = await fetchDDay();
      setState(() {
        futureDDays = Future.value(newDDays);
      });
    } catch (e) {
      print('Error fetching DDays: $e');
    }
  }


  Future<void> _checkIfFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstYn') ?? true;

    if (isFirstTime) {
      _showMarketingConsentDialog();
    }
  }

  Future<void> _showMarketingConsentDialog() async {
    final isConsented = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            '마케팅 알림',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            '우월에서 광고성 정보 알림을 보내고자 합니다. \n해당 기기로 이벤트, 혜택 등을 \n푸시알림으로 보내드리겠습니다. \n'
                '앱 푸시알림에 수신 동의하시겠습니까? \n알림설정은 알림 > 설정 > 알림설정 화면에서 재설정 가능합니다.',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('허용 안 함'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('허용'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
    if (isConsented != null) {
      await _sendConsentToServer('marketingYn', isConsented);
    }
    await _showScheduleNotificationDialog();
  }

  Future<void> _showScheduleNotificationDialog() async {
    final isConsented = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            '일정 알림',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            '우월에서 고객님의 향후 일정에 대해 \n푸시알림으로 보내드리겠습니다. \n'
                '앱 푸시알림에 수신 동의하시겠습니까?\n알림설정은 알림 > 설정 > 알림설정 화면에서 재설정 가능합니다.',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('허용 안 함'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('허용'),
              style: TextButton.styleFrom(
                backgroundColor:  AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
    if (isConsented != null) {
      await _sendConsentToServer('scheduleYn', isConsented);
    }
    await _showBudgetNotificationDialog();
  }

  Future<void> _showBudgetNotificationDialog() async {
    final isConsented = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            '예산 알림 동의',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            '우월에서 고객님이 설정한 예산 초과 시 \n푸시알림으로 보내드리겠습니다. \n'
                '앱 푸시알림에 수신 동의하시겠습니까?\n알림설정은 알림 > 설정 > 알림설정 화면에서 재설정 가능합니다.',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('허용 안 함'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('허용'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
    if (isConsented != null) {
      await _sendConsentToServer('budgetYn', isConsented);
    }
    await _showSystemNotificationDialog();
  }

  Future<void> _showSystemNotificationDialog() async {
    final isConsented = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            '시스템 알림 동의',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            '우월에서 새로운 소식이 있을 때 \n푸시알림으로 보내드리겠습니다. \n'
                '앱 푸시알림에 수신 동의하시겠습니까?\n알림설정은 알림 > 설정 > 알림설정 화면에서 재설정 가능합니다.',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('허용 안 함'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('허용'),
              style: TextButton.styleFrom(
                backgroundColor:  AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
    if (isConsented != null) {
      await _sendConsentToServer('systemYn', isConsented);
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstYn', false);
  }

  Future<void> _sendConsentToServer(String key, bool value) async {
    var response = await apiService.post(
      ApiConstants.updateYnSetting,
      data: {
        "key": key,
        "value": value.toString(),
      },
    );

    if (response.statusCode == 200) {
      print('설정이 성공적으로 업데이트되었습니다.');
    } else {
      print('설정 업데이트 실패: ${response.statusCode}');
      print('reason... : ${response.data}');
    }
  }


  Future<List<Map<String, dynamic>>> fetchDDay() async {
    try {
      final response = await apiService.get(ApiConstants.getDDay);
      if (response.statusCode == 200) {
        final data = response.data;
        return List<Map<String, dynamic>>.from(data['data']['days']);
      } else {
        throw Exception('Failed to load D-Days');
      }
    } catch (e) {
      print('error fetchDDay: $e');
      throw Exception('Failed to fetch DDay data');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureDDays,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Container());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> ddayList = snapshot.data!;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventScreen()),
                      );
                    },
                    child: SvgPicture.asset(
                      'asset/img/event_banner.svg',
                      fit: BoxFit.cover,
                      height: 215,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 60,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: -70,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 160,
                            child: Column(
                              children: [
                                Flexible(
                                  child: PageView(
                                    controller: _pageController,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentPage = index;
                                      });
                                    },
                                    children: ddayList.isNotEmpty
                                        ? ddayList.map((dday) {
                                      return Container(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                                child: Container(
                                                decoration: BoxDecoration(
                                                boxShadow: [
                                                    BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    offset: Offset(2,2),
                                                    blurRadius: 4,
                                                    spreadRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              child: DDayCardWidget(
                                                title: dday['dday'],
                                                subtitle: dday['title'],
                                                image: dday['image'],
                                                afterFlag: dday['afterFlag'],
                                                day: dday['day'],
                                                onRefresh: () {
                                                  fetchDDay().then((newDdays) {
                                                    setState(() {
                                                      futureDDays =
                                                          Future.value(newDdays);
                                                    });
                                                  });
                                                },
                                              ),
                                            ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(): [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => DDayManagementPage()),
                                          ).then((_) {
                                            refreshDDay();
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.1),
                                                        offset: Offset(2,2),
                                                        blurRadius: 4,
                                                        spreadRadius: 0,
                                                      ),
                                                    ],
                                                  ),
                                                  child: SvgPicture.asset(
                                                    'asset/img/empty_dday.svg',
                                                    fit: BoxFit.cover,
                                                    alignment: Alignment.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(ddayList.length, (index) {
                                    return AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                                      height: 11.0,
                                      width: _currentPage == index ? 11.0 : 11.0,
                                      decoration: BoxDecoration(
                                        color: _currentPage == index ? AppColors.primaryColor : Colors.black,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(1.0),
                    margin: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 21.0),
                                child: Text(
                                  "계약서 종류",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Pretendard',
                                  ),
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: widget.onContractSelected,
                                child: Row(
                                  children: [
                                    Text('등록하기 ', style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Pretendard')),
                                    Padding(
                                      padding: EdgeInsets.only(right: 20.0),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                              bool isIPad = MediaQuery.of(context).size.width > 600;

                              int crossAxisCount = isIPad && !isLandscape ? 6 : (isLandscape ? 8 : 4);
                              double aspectRatio = 1.0;

                              double height = isIPad && !isLandscape
                                  ? 125
                                  : 200;

                              int maxItems = crossAxisCount;
                              return SizedBox(
                                  height: height,
                                  child: GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  childAspectRatio: aspectRatio,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: List.generate(8, (index) {
                                    return Container(
                                      margin: EdgeInsets.all(0.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Positioned(
                                                  child: SvgPicture.asset(
                                                    'asset/img/icon_${index + 1}.svg',
                                                    fit: BoxFit.contain,
                                                    width: 64,
                                                    height: 92,
                                                    color: Colors.black.withOpacity(0.2),
                                                  ),
                                                ),
                                                Positioned(
                                                  child: SvgPicture.asset(
                                                    'asset/img/icon_${index + 1}.svg',
                                                    fit: BoxFit.contain,
                                                    width: 64,
                                                    height: 92,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Budget Info
                  BudgetCard(),
                ],
              ),
            );
          }
        },
      ),
    );
    }
}