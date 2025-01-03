import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import '../../themes/theme.dart';

class InquiryScreen extends StatefulWidget {
  @override
  _InquiryScreenState createState() => _InquiryScreenState();
}

class _InquiryScreenState extends State<InquiryScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  ApiService apiService = ApiService();

  void _submitInquiry() async {
    String content = _controller.text.trim();

    if (content.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            backgroundColor: Colors.white,
            content: Text(
              '내용을 입력해 주세요.',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            actions: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppColors.primaryColor),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
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
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      final response = await apiService.post(
        ApiConstants.inquiryMailSend,
        data: {'content': content},
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                '알림',
                style: TextStyle(color: Colors.black),
              ),
              content: Text(
                '문의하기가 완료되었습니다.',
                style: TextStyle(color: Colors.black),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        _showErrorDialog('문의하기에 실패했습니다. 다시 시도해 주세요.');
      }
    } catch (e) {
      _showErrorDialog('서버와의 연결에 실패했습니다. 다시 시도해 주세요.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            '오류',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '확인',
                style: TextStyle(color: Colors.black),
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
              /*RichText(
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
              SizedBox(height: 20),*/
              TextField(
                controller: _controller,
                maxLines: 12,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: '여기에 내용을 적어주세요 :)',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor, width: 1),
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
                    onPressed: _submitInquiry,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey),
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
