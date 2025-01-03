import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/money/add_cost_page.dart';
import 'package:http/http.dart' as http;
import '../../config/ApiConstants.dart';
import 'package:intl/intl.dart';
import '../../interceptor/api_service.dart';
import 'detail_page.dart';

class CostPage extends StatefulWidget {
  @override
  _CostPageState createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> categories = [];
  Map<int, bool> _isExpandedMap = {};
  int totalBudget = 0;
  int usedBudget = 0;
  int balanceBudget =0;
  String pairMan = "";
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchCategories();
    _getTotalAmount();
    //refreshData();
  }

  String _formatCurrency(String amount) {
    final number = int.tryParse(amount.replaceAll(',', '')) ?? 0;
    return NumberFormat('#,###').format(number);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('didChangeAppLifecycleState called with state: $state');
    if (state == AppLifecycleState.resumed) {
      refreshData();
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

      final response = await apiService.get(
        ApiConstants.getBudget
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = response.data;
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
        print('실패 메시지 ${response.data}');
      }
    }catch (e) {
      print('요청 실패, $e');
    }
  }

  Future<void> _fetchCategories() async {
    try{
      var response = await apiService.get(
        ApiConstants.getCategories,
      );
      if(response.statusCode == 200) {
        final jsonResponse = response.data;
        final categoryList = jsonResponse['data']['categoryList'];

        print('categoryList...####  $categoryList');
        setState(() {
          categories = categoryList.map<Map<String, dynamic>>((category) {
            final seq = category['seq'];
            _isExpandedMap[seq] = false;

            return {
              'seq': seq,
              'name': category['name'],
              'totalCost': category['totalCost'],
              'avgCost': category['avgCost']
            };
          }).toList();
        });
      } else {
        print('response....msg ... ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 실패: ${response.statusCode}")));
      }
    }catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("에러 발생: $e")));
    }

  }

  Future<List<Map<String, dynamic>>> _fetchCheckList(int seq) async {
    var response = await apiService.get(
      ApiConstants.getCheckLists,
      queryParameters: {'seq':seq},
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
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

      return jsonResponse['data'];
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
                  image: DecorationImage(
                    image: Image.asset(
                      'asset/img/budget_card_no_line.png',
                      fit: BoxFit.cover,
                    ).image,
                    fit: BoxFit.cover,
                  ),
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
                                style: TextStyle( fontSize: 20, color: Colors.white, fontFamily: 'Pretendard'),
                              ),
                              Text(
                                '${_formatCurrency(totalBudget.toString())} 원',
                                style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Pretendard'),
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
                                style: TextStyle( fontSize: 20, color: Colors.white, fontFamily: 'Pretendard'),
                              ),
                              Text(
                                '${_formatCurrency(usedBudget.toString())} 원',
                                style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Pretendard'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Divider(height: 0.1, color: Colors.white),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '남은 예산',
                                style: TextStyle( fontSize: 20, color: Colors.white, fontFamily: 'Pretendard'),
                              ),
                              Text(
                                '${_formatCurrency(balanceBudget.toString())} 원',
                                style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Pretendard'),
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
                                style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Pretendard'),
                              ),
                              Text(
                                '${pairMan}',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Pretendard'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 35),
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
                        if (_isExpandedMap[seq]!)
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _fetchCheckList(seq),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData && snapshot.data != null) {
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
                                                  refreshData();
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
                              return Container();
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
                  _fetchCheckListDetail(seq).then((detailData) {
                    print('detailData... $detailData');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(detailData: detailData),
                      ),
                    ).then((result) {
                      print('Result from DetailPage: $result');
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
