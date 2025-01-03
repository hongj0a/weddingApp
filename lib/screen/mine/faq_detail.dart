import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';

class FaqDetail extends StatefulWidget {
  final int seq;

  const FaqDetail({Key? key, required this.seq}) : super(key: key);

  @override
  _FaqDetailState createState() => _FaqDetailState();
}


class _FaqDetailState extends State<FaqDetail> {
  String content = '';
  String title= '';
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchFaqDetail();
  }

  Future<void> _fetchFaqDetail() async {
    try {

      final response = await apiService.get(
        ApiConstants.getFaqDetail,
        queryParameters: {'seq': widget.seq.toString()},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          title = data['data']['title'] ?? '';
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
                  AppBar().preferredSize.height,
            ),
            child: Html(data: content),
          ),
        )
            : Center(child: Text('로딩 중...')),
      ),
    );
  }
}
