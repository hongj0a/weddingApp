import 'package:flutter/material.dart';

class DDayManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                // 메인 페이지로 이동
                Navigator.pop(context);
              },
              child: Text('디데이 관리'),
            ),
            //Icon(Icons.favorite, color: Colors.pink),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          DDayCard(
            days: 'D-113',
            description: '본식',
            date: '2024.09.01',
            imagePath: 'asset/img/wed_01.jpg',
            cardColor: Colors.orange,
          ),
          DDayCard(
            days: 'D+446',
            description: '처음 만난날',
            date: '2024.09.01',
            imagePath: 'asset/img/wed_01.jpg',
            cardColor: Colors.pink,
          ),
          DDayCard(
            days: 'D-23',
            description: '촬영',
            date: '2024.09.01',
            imagePath: 'asset/img/wed_01.jpg',
            cardColor: Colors.grey,
          ),
          SizedBox(height: 20),
          Center(
            child: Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('추가하기'),
                onPressed: () {
                  // 추가하기 버튼 클릭 시 처리할 코드
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.0), // 버튼의 세로 패딩 조정
                ),
              ),
            ),
          ),

          SizedBox(height: 20),
          Text('...', textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class DDayCard extends StatelessWidget {
  final String days;
  final String description;
  final String date;
  final String imagePath;
  final Color cardColor;

  DDayCard({
    required this.days,
    required this.description,
    required this.date,
    required this.imagePath,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(imagePath),
        ),
        title: Text(days, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(date),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.edit, color: Colors.black),
          onPressed: () {
            // 수정 버튼 클릭 시 처리할 코드
          },
        ),
      ),
    );
  }
}
