import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/ApiConstants.dart';
import 'package:http/http.dart' as http;

class FaqDetail extends StatefulWidget {
  final int seq; // seq 변수를 선언

  const FaqDetail({Key? key, required this.seq}) : super(key: key);

  @override
  _FaqDetailState createState() => _FaqDetailState();
}


class _FaqDetailState extends State<FaqDetail> {
  String content = '';
  String title= '';

  @override
  void initState() {
    super.initState();
    _fetchFaqDetail(); // 페이지가 열리면 API를 통해 세부 정보를 가져옴
  }

  Future<void> _fetchFaqDetail() async {
    var url = Uri.parse(ApiConstants.getFaqDetail);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final response = await http.get(
        url.replace(queryParameters: {'seq': widget.seq.toString()}), // seq를 요청 파라미터로 전달
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          title = data['data']['title'] ?? '';
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
        title: Text(title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: content.isNotEmpty
            ? SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height, // AppBar 높이를 제외한 높이로 설정
            ),
            child: Html(data: content), // HTML 콘텐츠 표시
          ),
        )
            : Center(child: Text('로딩 중...')),
      ),
    );
  }
}
