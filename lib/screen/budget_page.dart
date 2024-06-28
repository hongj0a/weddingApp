import 'package:flutter/material.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final List<Map<String, String>> _items = [
    {'title': '로얄파크', 'price': '16,500,000원'},
    {'title': '본식 스냅', 'price': '0원'},
    {'title': '서브 스냅', 'price': '0원'},
    {'title': '본식 영상', 'price': '0원'},
    {'title': '신랑 예복', 'price': '0원'},
    {'title': '신랑 구두', 'price': '0원'},
    {'title': '본식 드레스', 'price': '0원'},
    {'title': '2부 의상', 'price': '0원'},
    {'title': '부케, 코사지', 'price': '0원'},
    {'title': '본식 메이크업', 'price': '0원'},
    {'title': '본식 기타', 'price': '0원'},
  ];

  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     TextButton(
      //       onPressed: () {},
      //       child: Text('추가', style: TextStyle(color: Colors.black, fontSize: 18)),
      //     ),
      //   ],
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(_isExpanded ? 10.0 : 0.0),
          //   border: _isExpanded ? Border.all(color: Colors.grey.shade300, width: 1.0) : null,
          // ),
          child: Column(
            children: [
            Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 첫 번째 줄의 두 개의 Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '총예산',
                            style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₩ {16,500,000}원',
                            style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16), // 간격 추가
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '총지출',
                            style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₩ {16,500,000}원',
                            style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
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
                    // 두 번째 줄의 두 개의 Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '남은예산',
                            style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₩ {18,500,000}원',
                            style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16), // 간격 추가
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '반쪽',
                            style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '♥️{예랑이}님',
                            style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.info),
                    Text(
                      '본식 16,500,000원',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              SizedBox(height: 8.0),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _isExpanded ? null : 0,
                child: _isExpanded
                    ? Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return _buildListTile(
                        _items[index]['title'] ?? 'Unknown title',
                        _items[index]['price'] ?? 'Unknown price',
                      );
                    },
                  ),
                )
                    : SizedBox.shrink(), //
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(String title, String price) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.0),
          ),
          Row(
            children: [
              Text(
                price,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 15.0),
              GestureDetector(
                onTap: () {},
                child: Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BudgetPage(),
  ));
}
