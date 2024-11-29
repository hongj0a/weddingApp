import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:smart_wedding/interceptor/api_service.dart';
import '../../config/ApiConstants.dart';

class TermsOfServicePage extends StatefulWidget {
  final String seq;

  TermsOfServicePage({required this.seq});

  @override
  _TermsOfServicePageState createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  String htmlContent = ''; // HTML content directly from API response
  String subTitle = '';
  bool isLoading = true;
  String accessToken = '';
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchTermsDetail();
  }

  Future<void> _fetchTermsDetail() async {

    try {
      final response = await apiService.get(
        ApiConstants.getTermsDetail,
        queryParameters: {'seq': widget.seq},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['data']['content'] == null) {
          print('Error: content is null in response');
          return;
        }

        setState(() {
          htmlContent = data['data']['content']; // Load HTML content directly
          subTitle = data['data']['title'];
          isLoading = false;
        });
      } else {
        print('Response error: ${response.data}');
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
        title: Text(subTitle, style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // Enable scrolling
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Optional padding
          child: Html(data: htmlContent), // Display parsed HTML content
        ),
      ),
    );
  }
}
