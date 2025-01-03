import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/mine/question_list.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  List<String> faqTitles = [];
  List<int> faqSeqs = [];
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchFAQList();
  }

  Future<void> _fetchFAQList() async {
    try {
      final response = await apiService.get(
        ApiConstants.getFaqCategoryList
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null && data['data']['faqCategories'] != null) {
          setState(() {
            faqTitles = List<String>.from(data['data']['faqCategories'].map((item) => item['title']));
            faqSeqs = List<int>.from(data['data']['faqCategories'].map((item) => item['seq']));
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
        title: Text('자주 묻는 질문'),
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
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionList(seq: faqSeqs[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
