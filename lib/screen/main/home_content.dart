import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/mine/d_day_card.dart';
import 'package:http/http.dart' as http;
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import '../../themes/theme.dart';
import '../mine/d_day_management.dart';
import '../mine/event_screen.dart';
import '../money/budget_setting.dart';

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

  List<Map<String, dynamic>> ddayList = [];
  int totalBudget = 0;
  int usedBudget = 0;
  int balanceBudget =0;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _getTotalAmount();
    fetchDDay();
    _checkIfFirstTimeUser();
  }

  Future<void> _checkIfFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstYn') ?? true;

    if (isFirstTime) {
      // 최초 실행이라면 알림 동의 팝업을 순차적으로 띄운다.
      _showMarketingConsentDialog();
    }
  }

  // 마케팅 알림 동의 팝업
  // 마케팅 알림 동의 팝업
  Future<void> _showMarketingConsentDialog() async {
    final isConsented = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // 약간 각진 모서리
          ),
          backgroundColor: Colors.white, // 하얀 배경
          title: Text(
            '마케팅 알림',
            style: TextStyle(color: Colors.black), // 검정색 글씨
          ),
          content: Text(
            '우월에서 광고성 정보 알림을 보내고자 합니다. \n해당 기기로 이벤트, 혜택 등을 \n푸시알림으로 보내드리겠습니다. \n'
                '앱 푸시알림에 수신 동의하시겠습니까? \n알림설정은 알림 > 설정 > 알림설정 화면에서 재설정 가능합니다.',
            style: TextStyle(color: Colors.black), // 검정색 글씨
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('허용 안 함'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // 검정색 글씨
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('허용'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor, // 보라색 배경
                foregroundColor: Colors.white,

              ),
            ),
          ],
        );
      },
    );
    if (isConsented != null) {
      // 서버에 동의 상태 저장
      await _sendConsentToServer('marketingYn', isConsented);
    }
    // 일정 알림 동의 팝업
    await _showScheduleNotificationDialog();
  }

// 일정 알림 동의 팝업
  Future<void> _showScheduleNotificationDialog() async {
    final isConsented = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // 약간 각진 모서리
          ),
          backgroundColor: Colors.white, // 하얀 배경
          title: Text(
            '일정 알림',
            style: TextStyle(color: Colors.black), // 검정색 글씨
          ),
          content: Text(
            '우월에서 고객님의 향후 일정에 대해 \n푸시알림으로 보내드리겠습니다. \n'
                '앱 푸시알림에 수신 동의하시겠습니까?\n알림설정은 알림 > 설정 > 알림설정 화면에서 재설정 가능합니다.',
            style: TextStyle(color: Colors.black), // 검정색 글씨
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('허용 안 함'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // 검정색 글씨
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('허용'),
              style: TextButton.styleFrom(
                backgroundColor:  AppColors.primaryColor, // 보라색 배경
                foregroundColor: Colors.white,

              ),
            ),
          ],
        );
      },
    );
    if (isConsented != null) {
      // 서버에 동의 상태 저장
      await _sendConsentToServer('scheduleYn', isConsented);
    }
    // 예산 알림 동의 팝업
    await _showBudgetNotificationDialog();
  }

// 예산 알림 동의 팝업
  Future<void> _showBudgetNotificationDialog() async {
    final isConsented = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // 약간 각진 모서리
          ),
          backgroundColor: Colors.white, // 하얀 배경
          title: Text(
            '예산 알림 동의',
            style: TextStyle(color: Colors.black), // 검정색 글씨
          ),
          content: Text(
            '우월에서 고객님이 설정한 예산 초과 시 \n푸시알림으로 보내드리겠습니다. \n'
                '앱 푸시알림에 수신 동의하시겠습니까?\n알림설정은 알림 > 설정 > 알림설정 화면에서 재설정 가능합니다.',
            style: TextStyle(color: Colors.black), // 검정색 글씨
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('허용 안 함'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // 검정색 글씨
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('허용'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryColor, // 보라색 배경
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
    if (isConsented != null) {
      // 서버에 동의 상태 저장
      await _sendConsentToServer('budgetYn', isConsented);
    }
    // 시스템 알림 동의 팝업
    await _showSystemNotificationDialog();
  }

// 시스템 알림 동의 팝업
  Future<void> _showSystemNotificationDialog() async {
    final isConsented = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // 약간 각진 모서리
          ),
          backgroundColor: Colors.white, // 하얀 배경
          title: Text(
            '시스템 알림 동의',
            style: TextStyle(color: Colors.black), // 검정색 글씨
          ),
          content: Text(
            '우월에서 새로운 소식이 있을 때 \n푸시알림으로 보내드리겠습니다. \n'
                '앱 푸시알림에 수신 동의하시겠습니까?\n알림설정은 알림 > 설정 > 알림설정 화면에서 재설정 가능합니다.',
            style: TextStyle(color: Colors.black), // 검정색 글씨
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('허용 안 함'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // 검정색 글씨
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('허용'),
              style: TextButton.styleFrom(
                backgroundColor:  AppColors.primaryColor, // 보라색 배경
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
    if (isConsented != null) {
      // 서버에 동의 상태 저장
      await _sendConsentToServer('systemYn', isConsented);
    }
    // 동의 여부를 SharedPreferences에 저장
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstYn', false);  // 알림 동의 후 첫 실행 상태를 false로 변경
  }

  Future<void> _sendConsentToServer(String key, bool value) async {
    var response = await apiService.post(
      ApiConstants.updateYnSetting,
      data: {
        "key": key, // 문자열 "key"로 수정
        "value": value.toString(), // boolean 값을 문자열로 변환
      },
    );

    if (response.statusCode == 200) {
      print('설정이 성공적으로 업데이트되었습니다.');
    } else {
      print('설정 업데이트 실패: ${response.statusCode}');
      print('reason... : ${response.data}');
    }
  }

  String _formatCurrency(String amount) {
    final number = int.tryParse(amount.replaceAll(',', '')) ?? 0; // 쉼표 제거 후 변환
    return NumberFormat('#,###').format(number); // 3자리마다 쉼표
  }
  Future<void> fetchDDay() async {
    final response = await apiService.get(
      ApiConstants.getDDay
    );

    print('Response status: ${response.statusCode}'); // 상태 코드 출력
    print('Response body: ${response.data}'); // 응답 본문 출력

    if (response.statusCode == 200) {
      final data = response.data;
      setState(() {
        ddayList = List<Map<String, dynamic>>.from(data['data']['days']);
      });
    } else {
      throw Exception('Failed to load D-Days');
    }
  }

  Future<void> _getTotalAmount() async{
    try {
      final response = await apiService.get(
        ApiConstants.getBudget,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = response.data;
        totalBudget = decodedData['data']['totalAmount'] ?? 0;
        usedBudget = decodedData['data']['usedBudget'] ?? 0;
        balanceBudget = totalBudget - usedBudget;

        setState(() {
          totalBudget = decodedData['data']['totalAmount'] ?? 0;
          usedBudget = decodedData['data']['usedBudget'] ?? 0;
          balanceBudget = totalBudget - usedBudget;
        });
      } else {
        print('총금액 가져오기 실패: ${response.statusCode}');
        print('실패 메시지 ${response.data}');
      }
    }catch (e) {
      print('요청 실패, $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
        child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
            height: 260,
            child: Stack(
                children: [
                  // 배너 이미지 (Stack의 맨 아래)
                  GestureDetector(
                    onTap: () {
                      // 배너 이미지가 탭되면 EventScreen으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EventScreen()),
                      );
                    },
                    child: SvgPicture.asset(
                      'asset/img/banner_main.svg',
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    ),
                  ),
                  // 디데이 카드 (배너 위에 반쯤 겹치도록 배치)
                  Positioned(
                    top: 140,  // 배너의 하단 부분에 카드가 반쯤 겹치도록 설정
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(0.0),
                      child: Stack(
                        children: [
                          // 텍스트 콘텐츠
                          Container(
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center, // 세로 방향으로 중앙 정렬
                              crossAxisAlignment: CrossAxisAlignment.center, // 가로 방향으로 중앙 정렬
                              children: [
                                Expanded(
                                  child: PageView(
                                    controller: _pageController,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentPage = index;
                                      });
                                    },
                                    children: ddayList.isNotEmpty
                                        ? ddayList.map((dday) {
                                      return
                                        Container(
                                          padding: const EdgeInsets.all(20.0),

                                          child: Stack(
                                            children: [
                                              // 배경 이미지
                                              Positioned.fill(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.1), // 그림자 색 (살짝 투명하게)
                                                        offset: Offset(2,2), // 오른쪽, 아래 방향으로 그림자를 이동 (수평 4, 수직 4)
                                                        blurRadius: 4, // 흐림 정도
                                                        spreadRadius: 0, // 그림자가 퍼지지 않도록 설정
                                                      ),
                                                    ],
                                                  ),
                                                  child: DDayCardWidget(
                                                    title: dday['dday'], // D-day 타이틀
                                                    subtitle: dday['title'], // D-day 날짜
                                                    image: dday['image'],
                                                    afterFlag: dday['afterFlag'],
                                                    day: dday['day'],
                                                    onRefresh: fetchDDay,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      );
                                    }).toList()
                                        : [
                                      // 텍스트가 나타나는 경우
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => DDayManagementPage()),
                                          ).then((_) {
                                            fetchDDay(); // 돌아왔을 때 onRefresh 호출
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Stack(
                                            children: [
                                              // 배경 이미지
                                              Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.1), // 그림자 색 (살짝 투명하게)
                                                          offset: Offset(2,2), // 오른쪽, 아래 방향으로 그림자를 이동 (수평 4, 수직 4)
                                                          blurRadius: 4, // 흐림 정도
                                                          spreadRadius: 0, // 그림자가 퍼지지 않도록 설정
                                                        ),
                                                      ],
                                                    ),
                                                    child: SvgPicture.asset(
                                                      'asset/img/empty_dday.svg', // SVG 이미지 경로
                                                      fit: BoxFit.cover,           // 컨테이너를 덮도록 설정
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // 더보기 버튼 추가, 그림자 제거 및 테두리 연하게 수정
            Container(
              padding: const EdgeInsets.all(0.0),
              margin: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: SingleChildScrollView( // 스크롤 가능하게 추가
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 21.0), // "계약서 종류" 왼쪽에 여백 추가
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
                              Text('등록하기 ', style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold, fontFamily: 'Pretendard')),
                              Padding(
                                padding: EdgeInsets.only(right: 20.0), // 아이콘 오른쪽 여백 추가
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
                    // GridView를 Column 내부에 넣되, 높이를 명확히 지정하여 크기 초과를 방지
                    SizedBox(
                      height: 200,  // GridView의 최대 높이를 설정
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 4,
                        childAspectRatio: 1,
                        physics: NeverScrollableScrollPhysics(),
                        children: List.generate(8, (index) {
                          return Container(
                            margin: EdgeInsets.all(0.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // 그림자 레이어
                                      Transform.translate(
                                        offset: Offset(2, 2), // 그림자를 약간 오른쪽 아래로 이동
                                        child: SvgPicture.asset(
                                          'asset/img/icon_${index + 1}.svg',
                                          width: 64,
                                          height: 92,
                                          color: Colors.black.withOpacity(0.2), // 그림자 색상
                                        ),
                                      ),
                                      // 실제 이미지 레이어
                                      SvgPicture.asset(
                                        'asset/img/icon_${index + 1}.svg',
                                        width: 64,
                                        height: 92,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Budget Info
            GestureDetector(
              onTap: () {
                // BudgetSetting 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BudgetSetting()),
                );
              },
              child: Container(
                margin: EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(12.0),
                child: Stack(
                  children: [
                    // 배경 이미지 크기 설정 (모서리가 둥글게 유지됨)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12), // 모서리 둥글게 설정
                      child: SizedBox(
                        width: 395, // 가로 크기 늘림
                        height: 200, // 세로 크기는 그대로 유지
                        child: SvgPicture.asset(
                          'asset/img/budget_card_no_line.svg', // 배경 이미지 경로
                          fit: BoxFit.cover, // 이미지를 컨테이너에 맞게 조정
                        ),
                      ),
                    ),
                    // 내용 부분 (글자 등)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0), // 이미지 위에 텍스트가 보이도록 여백 추가
                        child: SingleChildScrollView( // 여기서 SingleChildScrollView를 추가
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '예산',
                                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '총 예산',
                                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                  Text(
                                    '${_formatCurrency(totalBudget.toString())} 원',
                                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '총 지출',
                                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                  Text(
                                    '${_formatCurrency(usedBudget.toString())} 원',
                                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 0.5, // 선 두께
                                color: Colors.white, // 선 색상
                                margin: EdgeInsets.symmetric(horizontal: 1), // 좌우 여백
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '남은 예산',
                                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                  Text(
                                    '${_formatCurrency(balanceBudget.toString())} 원',
                                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )


          ],
        ),
      ),
    );
  }
}