import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/money/add_cost_page.dart';
import 'package:http/http.dart' as http;
import 'package:smart_wedding/screen/money/budget_setting.dart';
import '../../config/ApiConstants.dart';
import 'package:intl/intl.dart';

import 'detail_page.dart';

class CostPage extends StatefulWidget {
  @override
  _CostPageState createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> categories = [];
  //Map<int, List<Map<String, String>>> _items = {}; // seq별 데이터를 저장할 Map
  Map<int, bool> _isExpandedMap = {};
  int totalBudget = 0;
  int usedBudget = 0;
  int balanceBudget =0;
  String pairMan = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Observer 등록
    _fetchCategories();
    _getTotalAmount();
  }

  String _formatCurrency(String amount) {
    final number = int.tryParse(amount.replaceAll(',', '')) ?? 0; // 쉼표 제거 후 변환
    return NumberFormat('#,###').format(number); // 3자리마다 쉼표
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Observer 해제
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshData(); // 앱이 다시 활성화되면 데이터 새로 고침
    }
  }

  void refreshData() {
    _fetchCategories().then((_) {
      print('Categories refreshed: $categories');
    });
    _getTotalAmount().then((_) {
    });
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
        pairMan = decodedData['data']['isPairMan'];

        setState(() {
          totalBudget = decodedData['data']['totalAmount'] ?? 0;
          usedBudget = decodedData['data']['usedBudget'] ?? 0;
          balanceBudget = totalBudget - usedBudget;
          pairMan = decodedData['data']['pairMan'];
        });
      } else {
        print('총금액 가져오기 실패: ${response.statusCode}');
        print('실패 메시지 ${response.body}');
      }
    }catch (e) {
      print('요청 실패, $e');
    }
  }

  Future<void> _fetchCategories() async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      var url = Uri.parse(ApiConstants.getCategories);

      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json'
        },
      );  // GET 호출
      if(response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final categoryList = jsonResponse['data']['categoryList'];

        print('categoryList...####  $categoryList');
        setState(() {
          categories = categoryList.map<Map<String, dynamic>>((category) {
            final seq = category['seq'];
            _isExpandedMap[seq] = false;

            // 각 카테고리의 `items`를 초기화
            /*_items[seq] = [
            {'title': 'Sample Item 1', 'price': '5000원'},
            {'title': 'Sample Item 2', 'price': '10000원'}
          ];*/

            return {
              'seq': seq,
              'name': category['name'],
              'totalCost': category['totalCost'],
              'avgCost': category['avgCost']
            };
          }).toList();
        });
      } else {
        print('response....msg ... ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 실패: ${response.statusCode}")));
      }
    }catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("에러 발생: $e")));
    }

  }

  Future<List<Map<String, dynamic>>> _fetchCheckList(int seq) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    var url = Uri.parse('${ApiConstants.getCheckLists}?seq=$seq');
    var response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final checkList = jsonResponse['data']['checkList'];

      return checkList.map<Map<String, dynamic>>((checklist) {
        return {
          'seq': checklist['seq'],
          'title': checklist['item'] as String,
          'price': '${NumberFormat('#,###').format(checklist['totalCost'])}원', // 세 자리마다 콤마 추가
        };
      }).toList();
    } else {
      throw Exception('Failed to load checklist');
    }
  }

  Future<Map<String, dynamic>> _fetchCheckListDetail(int seq) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    var url = Uri.parse('${ApiConstants.getCheckListDetail}?seq=$seq');

    var response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      }
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      print('jsonResponse... $jsonResponse');
      print('jsonResponseData...  ${jsonResponse['data']}');

      return jsonResponse['data']; // 필요한 데이터를 반환
    } else {
      print('response code ... ${response.statusCode}');
      print('respons.. message ... ${response.body}');
      throw Exception('Failed to load checklist detail');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '총 예산',
                                style: TextStyle( fontSize: 20),
                              ),
                              Text(
                                '${_formatCurrency(totalBudget.toString())} 원',
                                style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '총 지출',
                                style: TextStyle( fontSize: 20),
                              ),
                              Text(
                                '${_formatCurrency(usedBudget.toString())} 원',
                                style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey.shade300),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '남은 예산',
                                style: TextStyle( fontSize: 20),
                              ),
                              Text(
                                '${_formatCurrency(balanceBudget.toString())} 원',
                                style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '반쪽',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '${pairMan}',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final seq = category['seq'];

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Tooltip(
                                message: '${category['name']} 평균 : ${NumberFormat('#,###').format(category['avgCost'])} 원',
                                child: Icon(Icons.info),
                              ),
                              Text(
                                '${category['name']} ${NumberFormat('#,###').format(category['totalCost'])}원',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isExpandedMap[seq] = !_isExpandedMap[seq]!;
                                  });
                                },
                                child: Icon(_isExpandedMap[seq]! ? Icons.expand_less : Icons.expand_more),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey.shade300),
                        if (_isExpandedMap[seq]!) // 카테고리가 확장된 경우
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _fetchCheckList(seq), // Future 반환
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData && snapshot.data != null) {
                                // 데이터가 있는 경우
                                return AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.length + 1,
                                    itemBuilder: (context, itemIndex) {
                                      if (itemIndex == snapshot.data!.length) {
                                        return Container(
                                          padding: const EdgeInsets.all(16.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => AddCostPage(categorySeq: seq),
                                                ),
                                              ).then((value) {
                                                if (value == true) {
                                                  refreshData(); // 추가 후 데이터 새로 고침
                                                }
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.black,
                                            ),
                                            child: Text('추가하기'),
                                          ),
                                        );
                                      }
                                      final item = snapshot.data![itemIndex];
                                      return _buildListTile(item['title']!, item['price']!, item['seq']);
                                    },
                                  ),
                                );
                              }
                              return Container(); // 기본적으로 빈 컨테이너
                            },
                          ),
                      ],
                    );

                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String price, int seq) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 19)),
          Row(
            children: [
              Text(price, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              SizedBox(width: 18.0),
              GestureDetector(
                onTap: () {
                  // 아이콘 클릭 시 seq를 사용하여 세부 정보를 가져옴
                  _fetchCheckListDetail(seq).then((detailData) {
                    print('detailData... $detailData');
                    // 세부 정보를 처리하는 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(detailData: detailData), // DetailPage로 데이터를 넘김
                      ),
                    ).then((result) {
                      print('Result from DetailPage: $result'); // 로그 추가
                      if (result == true) {
                        refreshData();
                      }
                    });
                  });
                },
                child: Icon(Icons.chevron_right),
              ),

            ],
          ),
        ],
      ),
    );
  }

}
