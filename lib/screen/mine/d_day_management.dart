import 'dart:convert'; // JSON 파싱을 위한 import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP 요청을 위한 import
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/ApiConstants.dart';
import 'd_day_registration.dart';

// 디데이 카드 모델
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

// 디데이 관리 페이지
class DDayManagementPage extends StatefulWidget {
  @override
  _DDayManagementPageState createState() => _DDayManagementPageState();
}

class _DDayManagementPageState extends State<DDayManagementPage> {
  List<DDayCardModel> ddayCards = []; // 리스트 타입 수정

  @override
  void initState() {
    super.initState();
    fetchDDays(); // API 호출
  }

  Future<void> fetchDDays() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse(ApiConstants.getDDay),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('Response status: ${response.statusCode}'); // 상태 코드 출력
    print('Response body: ${response.body}'); // 응답 본문 출력

    if (response.statusCode == 200) {
      // 응답을 JSON으로 디코드
      final jsonResponse = json.decode(response.body);

      // 'data'에서 'days' 배열을 가져오기
      List<dynamic> days = jsonResponse['data']['days'];

      // 상태 업데이트
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
              image: '${ApiConstants.localImagePath}/${card.image}',
              seq: card.seq,// 이미지 경로
              onDelete: () {
                setState(() {
                  ddayCards.remove(card); // 삭제된 카드 제거
                });
              },
              key: UniqueKey(), // 유니크 키 추가
            );
          }).toList(),
          SizedBox(height: 15),
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
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DDayRegistrationPage()),
                  ).then((_) {
                    // 페이지에서 돌아왔을 때 리스트 갱신
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

// 디데이 카드 위젯
class DDayCard extends StatelessWidget {
  final String dday;
  final String title;
  final String date;
  final String image;
  final int seq;
  final Function onDelete; // 삭제 기능을 위한 콜백 추가

  DDayCard({
    required this.dday,
    required this.title,
    required this.date,
    required this.image,
    required this.seq,
    required this.onDelete, // 콜백 받기
    Key? key,
  }) : super(key: key);

  Future<void> deleteDDay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    // API 호출
    final response = await http.post(
      Uri.parse('${ApiConstants.delDDay}?seq=$seq'),  // 삭제 API URL
      headers: {
        'Authorization': 'Bearer $accessToken', // 헤더에 Access Token 추가
      },
    );

    if (response.statusCode == 200) {
      onDelete(); // 성공적으로 삭제된 경우 콜백 호출
    } else {
      // 에러 처리
      throw Exception('Failed to delete DDay');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 클릭 시 아무 동작도 하지 않음
      },
      child: Container(
        padding: const EdgeInsets.all(5.0),
        margin: EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(File(image)), // 로컬 이미지
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(10), // 카드 모서리 둥글게
        ),
        child: Stack(
          children: [
            // 이미지 먼저 배치
            image.startsWith('http')
                ? Image.network(
              image,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Text('Error loading image')); // 에러 처리
              },
            )
                : Image.file(
              File(image),
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Text('Error loading image')); // 에러 처리
              },
            ),

            // 텍스트 위에 배치
            Positioned(
              top: 16, // 적절한 위치로 조정
              left: 16, // 적절한 위치로 조정
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dday,
                    style: TextStyle(
                      fontFamily: 'PretendardVariable',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // 배경에 잘 보이도록 색상 변경
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'PretendardVariable',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // 배경에 잘 보이도록 색상 변경
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontFamily: 'PretendardVariable',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // 배경에 잘 보이도록 색상 변경
                    ),
                  ),
                ],
              ),
            ),

            // 삭제 버튼
            Positioned(
              top: 2,
              right: 2,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  // 삭제 API 호출
                  await deleteDDay();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
