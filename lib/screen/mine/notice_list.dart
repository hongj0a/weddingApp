import 'package:flutter/material.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import 'notice_detail.dart';

class NoticeList extends StatefulWidget {
@override
_NoticeListState createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> {
  List<Map<String, dynamic>> notices = [];
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    try {

      final response = await apiService.get(
        ApiConstants.getNotice,
      );
      if (response.statusCode == 200) {
        final data = response.data['data']['notices'];

        setState(() {
          notices = List<Map<String, dynamic>>.from(
            data.map((item) => {
              'title': item['title'] ?? '',
              'date': item['date'] ?? '',
              'seq': item['seq'].toString(),
            }),
          );
        });
      } else {
        throw Exception('Failed to load notice info');
      }
    } catch (e) {
      print('Failed to fetch notices: $e');
    }
  }

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
                        seq: notice['seq'] ?? '',
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
