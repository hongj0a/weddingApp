import 'package:flutter/material.dart';
import '../../config/ApiConstants.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../interceptor/api_service.dart';

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
  String content = '';
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchNoticeDetail();
  }

  Future<void> _fetchNoticeDetail() async {
    try {

      final response = await apiService.get(
        ApiConstants.getNoticeDetail,
        queryParameters: {'seq': widget.seq},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          content = data['data']['content'] ?? '';
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                widget.date,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 20.0),
              content.isNotEmpty
                  ? Html(data: content)
                  : Text('로딩 중...'),
            ],
          ),
        ),
      ),
    );
  }
}
