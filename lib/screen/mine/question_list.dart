import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/mine/faq_detail.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';

class QuestionList extends StatefulWidget {
  final int seq;

  const QuestionList({Key? key, required this.seq}) : super(key: key);
  @override
  _QuestionListState createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  List<String> faqTitles = [];
  List<int> faqSeqs = [];
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FaqDetail(seq: faqSeqs[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
