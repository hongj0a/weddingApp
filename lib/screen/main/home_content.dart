import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/mine/d_day_card.dart';
import 'package:http/http.dart' as http;
import '../../config/ApiConstants.dart';

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

  @override
  void initState() {
    super.initState();
    _getTotalAmount();
    fetchDDay();
  }
  String _formatCurrency(String amount) {
    final number = int.tryParse(amount.replaceAll(',', '')) ?? 0; // 쉼표 제거 후 변환
    return NumberFormat('#,###').format(number); // 3자리마다 쉼표
  }

  Future<void> fetchDDay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    final response = await ApiConstants.getDDay(accessToken!); // API 호출

    print('Response status: ${response.statusCode}'); // 상태 코드 출력
    print('Response body: ${response.body}'); // 응답 본문 출력

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        ddayList = List<Map<String, dynamic>>.from(data['data']['days']);
      });
    } else {
      throw Exception('Failed to load D-Days');
    }
  }

  Future<void> _getTotalAmount() async{
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final response = await http.get(
        Uri.parse(ApiConstants.getBudget),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);
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
        print('실패 메시지 ${response.body}');
      }
    }catch (e) {
      print('요청 실패, $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // D-Day and Marriage Info
          Container(
            height: 300,
            child: Column(
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
                      return DDayCardWidget(
                        title: dday['dday'], // D-day 타이틀
                        subtitle: dday['title'], // D-day 서브 타이틀
                        date: dday['date'],// D-day 날짜
                        image: dday['image'],
                        onRefresh: fetchDDay,
                      );
                    }).toList()
                        : [
                      Center(child: CircularProgressIndicator()), // 로딩 중 표시
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
                        color: _currentPage == index ? Color.fromRGBO(250, 15, 156, 1.0) : Colors.grey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'asset/img/banner.png',
                  fit: BoxFit.fill,
                  height: 110,
                  width: 110,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // 더보기 버튼 추가, 그림자 제거 및 테두리 연하게 수정
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1), // 연한 테두리
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "계약서 종류",
                      style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: widget.onContractSelected,
                      child: Row(
                        children: [
                          Text('등록하기', style: TextStyle(fontFamily: 'PretendardVariable',color: Colors.black)),
                          Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // GridView에 2줄로 8개 아이템
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  physics: NeverScrollableScrollPhysics(),

                  children: [
                    Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1), // 테두리 연하게
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('asset/img/wedding-hall.png', height: 40),  // 이미지 아이콘
                          Text('본식', style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('asset/img/wedding-ring.png', height: 40),
                          Text('예물', style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('asset/img/wedding-teoksido.png', height: 40),
                          Text('예복', style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('asset/img/wedding-dress.png', height: 40),
                          Text('드레스', style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('asset/img/wedding-makeup.png', height: 40),
                          Text('메이크업', style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('asset/img/wedding-photo.png', height: 40),
                          Text('스냅', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('asset/img/wedding-trip.png', height: 40),
                          Text('신혼여행', style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('asset/img/wedding-house.png', height: 40),
                          Text('신혼집', style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 12)),
                        ],
                      ),
                    ),
                  ],

                ),
              ],
            ),
          ),

          SizedBox(height: 15),

          // Budget Info
          Container(
            margin: EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1), // 테두리 연하게
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총 예산',
                      style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_formatCurrency(totalBudget.toString())} 원',
                      style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총 지출',
                      style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${_formatCurrency(usedBudget.toString())} 원',
                      style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '남은 예산',
                      style: TextStyle(fontFamily: 'PretendardVariable',fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${_formatCurrency(balanceBudget.toString())} 원',
                      style: TextStyle(fontFamily: 'PretendardVariable', fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}