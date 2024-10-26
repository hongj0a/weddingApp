import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/mine/question_list.dart';


class FAQScreen extends StatelessWidget {
  final List<String> faqTitles = [
    "운영정책",
    "계정/인증/로그인",
    "광고",
    "자주 묻는 질문",
  ];

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
                MaterialPageRoute(builder: (context) => QuestionList()),
              );
            },
          );
        },
      ),
    );
  }
}
