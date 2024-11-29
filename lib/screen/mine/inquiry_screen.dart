import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // HTTP 패키지 추가
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON 인코딩을 위해 추가
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import '../../themes/theme.dart';

class InquiryScreen extends StatefulWidget {
  @override
  _InquiryScreenState createState() => _InquiryScreenState();
}

class _InquiryScreenState extends State<InquiryScreen> {
  final TextEditingController _controller = TextEditingController(); // TextField의 값을 제어하기 위한 컨트롤러 추가
  bool _isLoading = false; // 로딩 상태를 나타내는 변수 추가
  ApiService apiService = ApiService();

  void _submitInquiry() async {
    String content = _controller.text.trim(); // TextField의 값을 가져오기

    if (content.isEmpty) {
      // TextField가 빈 경우 AlertDialog 띄우기
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // 약간 직각 모양
            ),
            backgroundColor: Colors.white,
            content: Text(
              '내용을 입력해 주세요.',
              style: TextStyle(color: Colors.black, fontSize: 16), // 내용 글씨 검정색
            ),
            actions: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppColors.primaryColor), // 보라색 배경
                  foregroundColor: MaterialStateProperty.all(Colors.white), // 흰색 텍스트
                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 20, vertical: 10)), // 버튼 크기 조정
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0), // 약간의 둥근 테두리
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                child: Text(
                  '확인',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );

        },
      );
      return; // 빈 값인 경우 함수 종료
    }

    setState(() {
      _isLoading = true; // 로딩 시작
    });

    // POST 요청
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      var url = Uri.parse(ApiConstants.inquiryMailSend);

      final response = await apiService.post(
        ApiConstants.inquiryMailSend, // ApiConstants의 inquiryMailSend URL // 요청 헤더 설정
        data: {'content': content}, // body에 content 추가
      );

      setState(() {
        _isLoading = false; // 로딩 끝
      });

      if (response.statusCode == 200) {
        // 성공 시 알림을 표시하고 뒤로 가기
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white, // 배경색을 흰색으로 설정
              title: Text(
                '알림',
                style: TextStyle(color: Colors.black), // 제목 글씨 색을 검은색으로 설정
              ),
              content: Text(
                '문의하기가 완료되었습니다.',
                style: TextStyle(color: Colors.black), // 내용 글씨 색을 검은색으로 설정
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 다이얼로그 닫기
                    Navigator.pop(context); // 페이지 뒤로 가기
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(color: Colors.black), // 버튼 글씨 색을 검은색으로 설정
                  ),
                ),
              ],
            );
          },
        );
      } else {
        // 실패 시 에러 메시지 출력
        _showErrorDialog('문의하기에 실패했습니다. 다시 시도해 주세요.');
      }
    } catch (e) {
      // 요청 중 에러 발생 시 에러 메시지 출력
      _showErrorDialog('서버와의 연결에 실패했습니다. 다시 시도해 주세요.');
      setState(() {
        _isLoading = false; // 로딩 끝
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // 배경색을 흰색으로 설정
          title: Text(
            '오류',
            style: TextStyle(color: Colors.black), // 제목 글씨 색상을 검정색으로 설정
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.black), // 내용 글씨 색상을 검정색으로 설정
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text(
                '확인',
                style: TextStyle(color: Colors.black), // 버튼 글씨 색상을 검정색으로 설정
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("문의하기"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '우월 고객센터 전화번호 ',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: '010-2236-2622',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _controller, // TextField에 컨트롤러 연결
                maxLines: 12,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: '여기에 내용을 적어주세요 :)',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 1), // 활성화 시 색상 변경
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                '- 고객센터 운영시간은 10:00 ~ 19:00 예요.\n'
                    '- 답변에는 시간이 소요됩니다. 조금만 기다려주세요 :)\n'
                    '- 문의 내용을 자세하게 남겨주시면 빠른 답변에 도움이 됩니다.\n'
                    '- 산업안전보건법에 따라 고객님의 근로자 보호조치를 하고 있으며 모든 문의는 기록으로 남습니다.\n'
                    '- 문의하기 버튼을 누르시면 개인정보 수집 이용동의서에 동의하신 것으로 간주합니다.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _submitInquiry, // 버튼 클릭 시 _submitInquiry 호출
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black, // 글씨 색상
                      side: BorderSide(color: Colors.grey), // 테두리 색상
                    ),
                    child: Text('문의하기'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
