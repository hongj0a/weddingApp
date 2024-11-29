import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/mine/faq_detail.dart';

import '../../config/ApiConstants.dart';
import 'package:http/http.dart' as http;

import '../../interceptor/api_service.dart';

class QuestionList extends StatefulWidget {
  final int seq; // seq 변수를 선언

  const QuestionList({Key? key, required this.seq}) : super(key: key); // 생성자에서 seq를 받아옴

  @override
  _QuestionListState createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  List<String> faqTitles = [];
  List<int> faqSeqs = []; // seq를 저장할 리스트
  ApiService apiService = ApiService();


  @override
  void initState() {
    super.initState();
    _fetchFAQDetailList();
  }

  Future<void> _fetchFAQDetailList() async {
    try {
      final response = await apiService.get(
        ApiConstants.getFaqList,
        queryParameters: {'seq': widget.seq.toString()}
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null && data['data']['terms'] != null) {
          setState(() {
            // data['terms']에서 title과 seq를 가져옵니다.
            faqTitles = List<String>.from(data['data']['terms'].map((item) => item['title']));
            faqSeqs = List<int>.from(data['data']['terms'].map((item) => item['seq']));
          });
        } else {
          throw Exception('FAQ categories data is null');
        }
      } else {
        throw Exception('Failed to load FAQ list');
      }
    } catch (e) {
      print('Error fetching FAQ list: $e');
      // 에러 처리 (예: 사용자에게 알림)
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('운영 정책'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: faqTitles.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(faqTitles[index]),
            onTap: () {
              // seq를 인자로 넘겨주기
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FaqDetail(seq: faqSeqs[index]), // seq 전달
                ),
              );
            },
          );
        },
      ),
    );
  }
}
