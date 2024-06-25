import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/contract_page.dart';
import 'package:smart_wedding/screen/d_day_card.dart';
import 'package:smart_wedding/screen/budget_page.dart';
import 'package:smart_wedding/screen/my_page.dart';
import 'package:smart_wedding/screen/schedule_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeddingHomePage(),
    );
  }
}

class WeddingHomePage extends StatefulWidget {
  @override
  _WeddingHomePageState createState() => _WeddingHomePageState();
}

class _WeddingHomePageState extends State<WeddingHomePage> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'asset/img/ring.png',  // 이미지 파일 경로
              height: 30,  // 이미지 높이 조정
              width: 30,   // 이미지 너비 조정
            ),
            SizedBox(width: 15),  // 이미지와 텍스트 사이의 간격 조정
            Text('스마트웨딩', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),),  // 기존 title 텍스트
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            iconSize: 40,
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            // D-Day and Marriage Info
            Container(
              height: 200,
              child: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      children: [
                        DDayCardWidget(
                          title: 'D-68',
                          subtitle: 'Marriage',
                          date: '2024.09.01',
                          imagePath: 'asset/img/wed_01.jpg',
                        ),
                        DDayCardWidget(
                          title: 'D-68',
                          subtitle: 'Marriage',
                          date: '2024.09.01',
                          imagePath: 'asset/img/wed_01.jpg',
                        ),
                        DDayCardWidget(
                          title: 'D-68',
                          subtitle: 'Marriage',
                          date: '2024.09.01',
                          imagePath: 'asset/img/wed_01.jpg',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        height: 10.0,
                        width: _currentPage == index ? 24.0 : 16.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? Colors.amber : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Wedding Preparation Icons
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
                  Text(
                    '흩어져 있는 결혼 준비... 한 곳에 모아서 관리하세요 😊',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("💍", style: TextStyle(fontSize: 20)),  // Ring
                      Text("💼", style: TextStyle(fontSize: 20)),  // Suit
                      Text("🤵", style: TextStyle(fontSize: 20)),  // Groom
                      Text("👰", style: TextStyle(fontSize: 20)),  // Bride
                      Text("👑", style: TextStyle(fontSize: 20)),  // Crown
                      Text("👗", style: TextStyle(fontSize: 20)),  // Dress
                      Text("✈️", style: TextStyle(fontSize: 20)),  // Honeymoon
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Budget Info
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
                  Text(
                    '{예시니}님의 총예산 ₩ {35,000,000}원',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '이용금액',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '₩ {16,500,000}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '잔여한도',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '₩ {18,500,000}원',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.black,
        iconSize: 35,
        items: [
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BudgetPage()),
                );
              },
              child: Icon(Icons.attach_money),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContractPage()),
                );
              },
              child: Icon(Icons.document_scanner),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WeddingHomePage()),
                );
              },
              child: Icon(Icons.home),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SchedulePage()),
                );
              },
              child: Icon(Icons.calendar_month),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPage()),
                );
              },
              child: Icon(Icons.person),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}