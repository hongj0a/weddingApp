import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/ApiConstants.dart';
import 'package:flutter_html/flutter_html.dart';

class NoticeDetail extends StatefulWidget {
  final String title;
  final String date;
  final String seq;

  const NoticeDetail({
    Key? key,
    required this.title,
    required this.date,
    required this.seq,
  }) : super(key: key);

  @override
  _NoticeDetailState createState() => _NoticeDetailState();
}

class _NoticeDetailState extends State<NoticeDetail> {
  String content = ''; // 공지 내용을 저장할 변수

  @override
  void initState() {
    super.initState();
    _fetchNoticeDetail(); // 페이지가 열리면 API를 통해 세부 정보를 가져옴
  }

  Future<void> _fetchNoticeDetail() async {
    var url = Uri.parse(ApiConstants.getNoticeDetail);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final response = await http.get(
        url.replace(queryParameters: {'seq': widget.seq}), // seq를 요청 파라미터로 전달
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          content = data['data']['content'] ?? ''; // 데이터에서 내용 가져오기
        });
      } else {
        throw Exception('Failed to load notice detail');
      }
    } catch (e) {
      print('Failed to fetch notice detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('공지사항', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 1.0,
      ),
      body: SingleChildScrollView( // Enable scrolling for long content
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title, // 전달받은 제목 사용
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                widget.date, // 전달받은 날짜 사용
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 20.0),
              // 공지 내용을 표시
              content.isNotEmpty
                  ? Html(data: content) // HTML 콘텐츠를 파싱하여 표시
                  : Text('로딩 중...'),
            ],
          ),
        ),
      ),
    );
  }
}
