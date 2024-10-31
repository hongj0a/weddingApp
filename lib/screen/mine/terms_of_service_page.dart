import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/ApiConstants.dart';
import 'package:http/http.dart' as http;

class TermsOfServicePage extends StatefulWidget {
  final String seq;
  final String imageUrl = '${ApiConstants.localImagePath}/';

  TermsOfServicePage({required this.seq});

  @override
  _TermsOfServicePageState createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  String htmlFileName = '';
  bool isLoading = true;
  String accessToken='';

  @override
  void initState() {
    super.initState();
    // WebView 초기화
    _fetchTermsDetail();
  }

  Future<void> _fetchTermsDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('accessToken')!;
    var url = Uri.parse(ApiConstants.getTermsDetail);

    try {
      final response = await http.get(
        url.replace(queryParameters: {'seq': widget.seq}),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data']['content'] == null) {
          print('Error: content is null in response');
          // 여기에 적절한 에러 처리 로직 추가
          return; // 함수를 종료하여 아래 코드가 실행되지 않도록 함
        }


        setState(() {
          htmlFileName = data['data']['content']; // HTML 파일 이름을 가져옴
          print('htmlFileName... ???  ${htmlFileName}');
          isLoading = false; // 로딩 상태를 false로 설정
        });
      } else {
        print('response... ${response.body}');
        throw Exception('Failed to load terms detail');
      }
    } catch (e) {
      print('Failed to fetch terms detail: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('서비스 이용약관'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중일 때 로딩 인디케이터 표시
          : InAppWebView(
            initialUrlRequest: URLRequest(
            url: Uri.parse('${widget.imageUrl}$htmlFileName'),
              headers: {
                'Authorization': 'Bearer $accessToken', // 여기에 토큰을 추가
                'Content-Type': 'application/json',
                'Accept-Charset': 'utf-8', // 인코딩 지정
              },
            ),initialOptions: InAppWebViewGroupOptions(
                  android: AndroidInAppWebViewOptions(useHybridComposition: true)),
              ),

    );
  }
}
