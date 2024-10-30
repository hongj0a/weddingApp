import 'package:flutter/material.dart';

class InquiryScreen extends StatelessWidget {
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
                      text: '엘리트웨딩 고객센터 전화번호 ',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: '1234-2356',
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
                maxLines: 10,
                maxLength: 1000,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '여기에 내용을 적어주세요 :)',
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: () {
                      // Handle camera action
                    },
                  ),
                  Text('0/10'),
                ],
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
                child: ElevatedButton(
                  onPressed: () {
                    // Handle inquiry submission
                  },
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
