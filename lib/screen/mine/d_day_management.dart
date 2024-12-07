import 'dart:convert'; // JSON 파싱을 위한 import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP 요청을 위한 import
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
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
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchDDays(); // API 호출
  }

  Future<void> fetchDDays() async {
    final response = await apiService.get(
      ApiConstants.getDDay,
    );

    print('Response status: ${response.statusCode}'); // 상태 코드 출력
    print('Response body: ${ response.data}'); // 응답 본문 출력

    if (response.statusCode == 200) {
      // 응답을 JSON으로 디코드
      final jsonResponse = response.data;

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
              image: card.image,
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
                icon: Icon(Icons.add, color: Colors.black), // 아이콘 색상 변경
                label: Text(
                  '추가하기',
                  style: TextStyle(
                    color: Colors.black, // 글자 색상 변경
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // 배경 색상 변경
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  side: BorderSide(color: Colors.grey, width: 1), // 얇은 회색선 테두리 추가
                  elevation: 0, // 그림자 제거
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
  ApiService apiService = ApiService();
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
    // API 호출
    final response = await apiService.get(
      ApiConstants.delDDay,
      queryParameters: {'seq': seq},// 삭제 API URL
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
    return Dismissible(
      key: ValueKey(dday), // 각 항목을 고유하게 식별하기 위한 키
      direction: DismissDirection.endToStart, // 오른쪽 -> 왼쪽 스와이프
      onDismissed: (direction) async {
        // 삭제 동작
        await deleteDDay();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title 삭제 되었습니다.')),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        color: Colors.red, // 스와이프 시 배경색
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
              offset: Offset(0, 3), // 그림자 위치
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 동그란 이미지
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
            const SizedBox(width: 23), // 이미지와 텍스트 사이 간격
            // 텍스트들
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
