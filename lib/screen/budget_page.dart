import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/add_item_page.dart';

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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '총예산',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '₩ {16,500,000}원',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                                '총지출',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '₩ {16,500,000}원',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                                '남은예산',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '₩ {18,500,000}원',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '♥️{예랑이}님',
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
              Expanded(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: _isExpanded ? null : 0,
                  child: _isExpanded
                      ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: _items.length + 1, // +1 for the Add button
                    itemBuilder: (context, index) {
                      if (index == _items.length) {
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddItemPage(),
                                ),
                              );
                            },
                            child: Text('추가하기'),
                          ),
                        );
                      }
                      return _buildListTile(
                        _items[index]['title'] ?? 'Unknown title',
                        _items[index]['price'] ?? 'Unknown price',
                      );
                    },
                  )
                      : SizedBox.shrink(),
                ),
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
            style: TextStyle(fontSize: 19),
          ),
          Row(
            children: [
              Text(
                price,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 18.0),
              GestureDetector(
                onTap: () {},
                child: Text(
                  '>',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
