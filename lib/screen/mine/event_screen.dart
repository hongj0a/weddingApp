import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import '../../themes/theme.dart';

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  ApiService apiService = ApiService();

  void _showInputDialog(BuildContext context) {
    final TextEditingController inputController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
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
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.purple, width: 2.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("취소", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              onPressed: () async {
                String userInput = inputController.text.trim();
                if (userInput.isNotEmpty) {
                  bool isPostUnique = await _checkPostDuplication(userInput);
                  print('isbool.... $isPostUnique');
                  if (isPostUnique) {
                    bool isEventRegistered = await _registerEvent(userInput);
                    print('isEventRegistered... $isEventRegistered');
                    if (isEventRegistered) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("응모가 완료되었습니다."),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("응모에 실패했습니다. 다시 시도해주세요."),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("이미 응모하셨습니다. 다른 URL로 응모해주세요."),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                } else {
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

  Future<bool> _checkPostDuplication(String postUrl) async {
    try {
      final response = await apiService.get(
        ApiConstants.checkPost,
        queryParameters: {'link': postUrl},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if(data['data']['newPost']) {
          return true;
        } else {
          return false;
        }
      } else {
        print("중복 검사 실패: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("중복 검사 에러: $e");
      return false;
    }
  }

  Future<bool> _registerEvent(String postUrl) async {
    try {
      final response = await apiService.get(
        ApiConstants.setEvent,
        queryParameters: {'link': postUrl},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("이벤트 등록 에러: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "진행 중인 이벤트",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SvgPicture.asset(
            'asset/img/event_page.svg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
          ),
          Positioned(
            bottom: 30.0,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                onPressed: () {
                  print("응모하기 버튼 눌림!");
                  _showInputDialog(context);
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

