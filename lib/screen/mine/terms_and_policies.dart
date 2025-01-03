import 'package:flutter/material.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import 'terms_of_service_page.dart';

class TermsAndPoliciesScreen extends StatefulWidget {
  @override
  _TermsAndPoliciesScreenState createState() => _TermsAndPoliciesScreenState();
}

class _TermsAndPoliciesScreenState extends State<TermsAndPoliciesScreen> {
  List<Map<String, dynamic>> terms = [];
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchTerms();
  }

  Future<void> _fetchTerms() async {
    try {
      final response = await apiService.get(
        ApiConstants.getTerms,
      );

      if (response.statusCode == 200) {
        final data = response.data['data']['terms'];

        setState(() {
          terms = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load terms');
      }
    } catch (e) {
      print('Failed to fetch terms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('약관 및 정책'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: terms.length,
        itemBuilder: (context, index) {
          final term = terms[index];
          return ListTile(
            title: Text(term['title'] ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TermsOfServicePage(seq: term['seq'].toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
