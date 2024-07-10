import 'package:flutter/material.dart';

class DDayManagementPage extends StatefulWidget {
  @override
  _DDayManagementPageState createState() => _DDayManagementPageState();
}

class _DDayManagementPageState extends State<DDayManagementPage> {
  List<DDayCard> ddayCards = [
    DDayCard(
      days: 'D-113',
      description: '본식',
      date: '2024.09.01',
      imagePath: 'asset/img/wed_01.jpg',
      cardColor: Color.fromRGBO(255, 222, 246, 1.0),
    ),
    DDayCard(
      days: 'D+446',
      description: '처음 만난날',
      date: '2024.09.01',
      imagePath: 'asset/img/wed_01.jpg',
      cardColor: Color.fromRGBO(192, 249, 252, 1.0),
    ),
    DDayCard(
      days: 'D-23',
      description: '촬영',
      date: '2024.09.01',
      imagePath: 'asset/img/wed_01.jpg',
      cardColor: Color.fromRGBO(255, 242, 166, 1.0),
    ),
  ];

  void _addNewDDayCard() {
    setState(() {
      ddayCards.add(
        DDayCard(
          days: 'D-23',
          description: '촬영',
          date: '2024.09.01',
          imagePath: 'asset/img/wed_01.jpg',
          cardColor: Color.fromRGBO(255, 242, 166, 1.0),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
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
          ...ddayCards,
          SizedBox(height: 20),
          Center(
            child: Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text(
                  '추가하기',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _addNewDDayCard,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
          ),
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
          radius: 50.0,
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
