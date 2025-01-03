import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import 'd_day_registration.dart';

class DDayCardModel {
  final String dday;
  final String title;
  final String date;
  final String image;
  final int seq;

  DDayCardModel({
    required this.dday,
    required this.title,
    required this.date,
    required this.image,
    required this.seq,
  });

  factory DDayCardModel.fromJson(Map<String, dynamic> json) {
    return DDayCardModel(
      dday: json['dday'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      image: json['image'] ?? '',
      seq: json['seq'] ?? '',
    );
  }
}

class DDayManagementPage extends StatefulWidget {
  @override
  _DDayManagementPageState createState() => _DDayManagementPageState();
}

class _DDayManagementPageState extends State<DDayManagementPage> {
  List<DDayCardModel> ddayCards = [];
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchDDays();
  }

  Future<void> fetchDDays() async {
    final response = await apiService.get(
      ApiConstants.getDDay,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${ response.data}');

    if (response.statusCode == 200) {
      final jsonResponse = response.data;

      List<dynamic> days = jsonResponse['data']['days'];

      setState(() {
        ddayCards = days.map((data) => DDayCardModel.fromJson(data)).toList();
      });
    } else {
      throw Exception('Failed to load DDays');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Text('디데이 관리'),
            ),
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
          ...ddayCards.map((card) {
            return DDayCard(
              dday: card.dday,
              title: card.title,
              date: card.date,
              image: card.image,
              seq: card.seq,
              onDelete: () {
                setState(() {
                  ddayCards.remove(card);
                });
              },
              key: UniqueKey(),
            );
          }).toList(),
          SizedBox(height: 15),
          Center(
            child: Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add, color: Colors.black),
                label: Text(
                  '추가하기',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  side: BorderSide(color: Colors.grey, width: 1),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DDayRegistrationPage()),
                  ).then((_) {
                    fetchDDays();
                  });
                },
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class DDayCard extends StatelessWidget {
  ApiService apiService = ApiService();
  final String dday;
  final String title;
  final String date;
  final String image;
  final int seq;
  final Function onDelete;

  DDayCard({
    required this.dday,
    required this.title,
    required this.date,
    required this.image,
    required this.seq,
    required this.onDelete,
    Key? key,
  }) : super(key: key);

  Future<void> deleteDDay() async {
    final response = await apiService.get(
      ApiConstants.delDDay,
      queryParameters: {'seq': seq},
    );

    if (response.statusCode == 200) {
      onDelete();
    } else {
      throw Exception('Failed to delete DDay');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(dday),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        await deleteDDay();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title 삭제 되었습니다.')),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: image.startsWith('http')
                  ? Image.network(
                image,
                fit: BoxFit.cover,
                height: 80,
                width: 80,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey[300],
                    child: Center(child: Icon(Icons.error, color: Colors.red)),
                  );
                },
              )
                  : Image.file(
                File(image),
                fit: BoxFit.cover,
                height: 80,
                width: 80,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 80,
                    width: 80,
                    color: Colors.grey[300],
                    child: Center(child: Icon(Icons.error, color: Colors.red)),
                  );
                },
              ),
            ),
            const SizedBox(width: 23),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dday,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black38,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
            ),
            // 삭제 버튼
            /*IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await deleteDDay();
              },
            ),*/
          ],
        ),
      ),
    );
  }

}
