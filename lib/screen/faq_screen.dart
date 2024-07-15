import 'package:flutter/material.dart';


class FAQScreen extends StatelessWidget {
  final List<String> faqTitles = [
    "자주 묻는 질문",
    "자주 묻는 질문",
    "자주 묻는 질문",
    "자주 묻는 질문",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              // Handle FAQ item tap here
            },
          );
        },
      ),
    );
  }
}
