import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/ApiConstants.dart';
import '../../themes/theme.dart';

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

void _showInputDialog(BuildContext context) {
  final TextEditingController inputController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // 다이얼로그의 둥근 모서리
        ),
        title: Text(
          "응모하기",
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        content: TextField(
          controller: inputController,
          decoration: InputDecoration(
            hintText: "응모하실 포스트 URL을 입력해 주세요.",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey), // 비활성 상태의 밑줄
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.purple, width: 2.0), // 포커스 상태의 밑줄
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 입력창 닫기
            },
            child: Text("취소", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor, // 보라색 배경
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0), // 버튼의 직각 모양
              ),
            ),
            onPressed: () async {
              String userInput = inputController.text.trim(); // 입력값 공백 제거
              if (userInput.isNotEmpty) {
                // 중복 검사 API 호출
                bool isPostUnique = await _checkPostDuplication(userInput);
                print('isbool.... $isPostUnique');
                if (isPostUnique) {
                  // 새로운 포스트라면 이벤트 등록 API 호출
                  bool isEventRegistered = await _registerEvent(userInput);
                  print('isEventRegistered... $isEventRegistered');
                  if (isEventRegistered) {
                    // 성공 시
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("응모가 완료되었습니다."),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  } else {
                    // 실패 시
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("응모에 실패했습니다. 다시 시도해주세요."),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                } else {
                  // 중복된 응모 URL
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("이미 응모하셨습니다. 다른 URL로 응모해주세요."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              } else {
                // 빈 값 처리
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("응모하실 포스트 URL을 입력해 주세요."),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(
              "확인",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}

// 중복 검사 API 호출 함수
Future<bool> _checkPostDuplication(String postUrl) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse('${ApiConstants.checkPost}?link=$postUrl'), // 중복 검사 API
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if(data['data']['newPost']) {
        return true;
      } else {
        return false;
      }
    } else {
      print("중복 검사 실패: ${response.statusCode}");
      return false; // 실패 시 중복으로 처리
    }
  } catch (e) {
    print("중복 검사 에러: $e");
    return false;
  }
}

// 이벤트 등록 API 호출 함수
Future<bool> _registerEvent(String postUrl) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');
    final url = Uri.parse('${ApiConstants.setEvent}?link=$postUrl');
    final response = await http.post(
      url, // 이벤트 등록 API
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json'
      },
    );
    return response.statusCode == 200; // 200 응답이면 성공
  } catch (e) {
    print("이벤트 등록 에러: $e");
    return false;
  }
}

class _EventScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "진행 중인 이벤트",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상 설정
        elevation: 0, // AppBar 그림자 제거
      ),
      body: Stack(
        children: [
          // 배경 이미지
          SvgPicture.asset(
            'asset/img/event_page.svg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain, // 이미지가 화면에 꽉 차도록 조정
          ),
          // 응모하기 버튼
          Positioned(
            bottom: 15.0, // 하단에서 20px 위에 위치
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor, // 버튼 배경색
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0), // 버튼 모서리를 둥글게
                  ),
                ),
                onPressed: () {
                  // 응모하기 버튼을 눌렀을 때의 동작
                  print("응모하기 버튼 눌림!");
                  _showInputDialog(context);
                  // API 호출이나 이벤트 추가 로직 등을 여기에 작성
                },
                child: Text(
                  "응모하기",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
