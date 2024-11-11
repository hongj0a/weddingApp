import 'dart:io';
import 'package:flutter/material.dart';

class ContractDetail extends StatelessWidget {
  //final String extractedText;
  final Map<String, String?> contractInfo;
  final File imageFile;

  ContractDetail({required this.contractInfo, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('계약서 상세'),
        automaticallyImplyLeading: true, // 기본 뒤로가기 버튼 사용
      ),
      body: WillPopScope(
        onWillPop: () async {
          // 뒤로가기 버튼을 눌렀을 때 처음 화면(DocumentUploadPage)으로 돌아감
          Navigator.popUntil(context, ModalRoute.withName('/'));
          return false; // 기본 뒤로가기 동작을 차단
        },
        child: SingleChildScrollView(  // 스크롤 가능하게 함
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지를 위로 배치
              Center(
                child: imageFile.existsSync()
                    ? Image.file(imageFile)
                    : Icon(Icons.error, color: Colors.red),
              ),
              SizedBox(height: 20),  // 이미지와 텍스트 사이의 간격을 조절
              Text(
                '계약서 정보 :',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text("계약서 이름 : ${contractInfo["ContractName"] ?? "없음"}",
                style: TextStyle(fontSize: 16),
              ),
              Text("계약금 : ${contractInfo["ContractAmount"] ?? "없음"}",
                style: TextStyle(fontSize: 16),
              ),
              Text("총 금액 : ${contractInfo["TotalAmount"] ?? "없음"}",
                style: TextStyle(fontSize: 16),
              ),
              Text("회사명 : ${contractInfo["CompanyName"] ?? "없음"}",
                style: TextStyle(fontSize: 16),
              ),
              Text("행사 날짜 : ${contractInfo["EventDate"] ?? "없음"}",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
