import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/document/document_upload.dart';

class ContractPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildContractItem('웨딩홀 계약서', '로얄 파크 컨벤션'),
          _buildContractItem('신혼여행 계약서', '허니문 리조트'),
          _buildContractItem('혼주 한복 계약서', '예향 한복'),
          _buildContractItem('예복 계약서', '까사비토'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DocumentUploadPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildContractItem(String title, String subtitle) {
    return Card(
      elevation: 3.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Icon(Icons.description),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Icon(Icons.location_on, size: 16.0, color: Colors.red),
            SizedBox(width: 4.0),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}
