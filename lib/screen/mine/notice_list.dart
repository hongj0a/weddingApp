import 'package:flutter/material.dart';
import 'notice_detail.dart'; // Ensure this import is correct

class NoticeList extends StatelessWidget {
  final List<Map<String, String>> notices = [
    {'title': '더 좋은 서비스 제공을 위해 개인정보처리방침이 변경될 예정이에요', 'date': '2024.04.30'},
    {'title': '계약서 등록 시 유의사항', 'date': '2024.04.23'},
    {'title': '서버, 엘리트웨딩 서비스 점검 일정 안내드려요. (05월 12일 일요일 02:00 ~ 14:00)', 'date': '2024.04.18'},
    {'title': '서버, 엘리트웨딩 서비스 점검 일정 안내드려요. (05월 12일 일요일 01:00 ~ 08:00)', 'date': '2024.04.18'},
    {'title': '이벤트 신청 시 유의사항', 'date': '2024.04.11'},
    {'title': '[공지] 이벤트 신청 시 유의사항', 'date': '2024.04.11'},
    {'title': '이벤트 신청 시 유의사항', 'date': '2024.04.11'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('공지사항'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final notice = notices[index];
          return Column(
            children: [
              ListTile(
                title: Text(notice['title'] ?? ''),
                subtitle: Text(notice['date'] ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoticeDetail(
                        title: notice['title'] ?? '',
                        date: notice['date'] ?? '',
                      ),
                    ),
                  );
                },
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}
