import 'dart:io';

import 'package:flutter/material.dart';

class ContractDetail extends StatelessWidget {
  final String extractedText;
  final File imageFile;

  ContractDetail({required this.extractedText, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    print('이미지 파일 경로: ${imageFile.path}');
    print('이미지 파일 존재 여부: ${imageFile.existsSync()}');
    return Scaffold(
      appBar: AppBar(title: Text('계약서 상세')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지 경로 확인
            imageFile.existsSync()
                ? Image.file(imageFile)
                : Icon(Icons.error, color: Colors.red), // 이미지 로드 실패 시 오류 아이콘 표시
            SizedBox(height: 20),
            Text('인식된 텍스트:\n$extractedText', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
