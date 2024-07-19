import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/mine/d_day_card.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      DDayCardWidget(
                        title: 'D-66',
                        subtitle: 'Marriage',
                        date: '2024.09.01',
                        imagePath: 'asset/img/wed_01.jpg',
                      ),
                      DDayCardWidget(
                        title: 'D-66',
                        subtitle: 'Marriage',
                        date: '2024.09.01',
                        imagePath: 'asset/img/wed_01.jpg',
                      ),
                      DDayCardWidget(
                        title: 'D-66',
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
                        color: _currentPage == index ? Colors.purple : Colors.grey,
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
                  '흩어져 있는 결혼 준비, 한 곳에 모아서 관리하세요 😊',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("💍", style: TextStyle(fontSize: 30)),  // Ring
                    Text("💼", style: TextStyle(fontSize: 30)),  // Suit
                    Text("🤵", style: TextStyle(fontSize: 30)),  // Groom
                    Text("👰", style: TextStyle(fontSize: 30)),  // Bride
                    Text("👑", style: TextStyle(fontSize: 30)),  // Crown
                    Text("👗", style: TextStyle(fontSize: 30)),  // Dress
                    Text("✈️", style: TextStyle(fontSize: 30)),  // Honeymoon
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '이용금액',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '₩ {16,500,000}원',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '잔여한도',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '₩ {18,500,000}원',
                      style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),
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
