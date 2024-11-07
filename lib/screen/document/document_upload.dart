import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:smart_wedding/screen/document/contract_detail.dart';

class DocumentUploadPage extends StatefulWidget {
  @override
  _DocumentUploadPageState createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  final ImagePicker _picker = ImagePicker();
  String extractedText = ''; // 텍스트 인식 결과 저장 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('계약서 등록'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '계약서를 등록해 주세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40.0),
            Icon(
              Icons.insert_drive_file,
              size: 100.0,
              color: Color.fromRGBO(250, 15, 156, 1.0),
            ),
            SizedBox(height: 40.0),
            Container(
              width: 160,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add, color: Colors.black),
                label: Text('계약서 등록하기', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  _showBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 4.0,
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            extractedText.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '인식된 텍스트:\n$extractedText',
                textAlign: TextAlign.center,
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '계약서 등록하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.black),
                title: Text('직접 촬영하기', style: TextStyle(color: Colors.black)),
                onTap: () async {
                  await _pickImageFromCamera();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo, color: Colors.black),
                title: Text('갤러리에서 가져오기', style: TextStyle(color: Colors.black)),
                onTap: () async {
                  await _pickImageFromGallery();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.black),
                title: Text('PDF 문서 가져오기', style: TextStyle(color: Colors.black)),
                onTap: () async {
                  await _pickPDF();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      await _extractTextFromImage(File(pickedFile.path));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _extractTextFromImage(File(pickedFile.path));
    }
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      print('Picked PDF: ${result.files.single.path}');
    }
  }

  // 이미지에서 텍스트 인식하는 함수
  Future<void> _extractTextFromImage(File image) async {
    final inputImage = InputImage.fromFile(image);

    // TextRecognizer 인스턴스를 생성하면서 언어 모델 설정
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);  // 기본적으로 영어(라틴 알파벳) 지원

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      // 전체 인식된 텍스트 출력
      print('전체 텍스트: ${recognizedText.text}');

      // 특정 패턴 찾기 (예: "금액" 또는 "총액"이 포함된 문장만 필터링)
      final amountPattern = RegExp(r'(\d{1,3}(?:,\d{3})*|\d+원)');
      String filteredText = '';

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          if (amountPattern.hasMatch(line.text)) {
            filteredText += line.text + '\n';
          }
        }
      }

      // 필터링된 텍스트 출력
      print('필터링된 텍스트: $filteredText');

      setState(() {
        extractedText = filteredText;
      });

      // 텍스트 인식 후 편집 화면으로 이동
      if (extractedText.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContractDetail(extractedText: extractedText, imageFile: image),
          ),
        );

      }

    } catch (e) {
      print('텍스트 인식 실패: $e');
    } finally {
      textRecognizer.close(); // 사용 후 인스턴스 닫기
    }
  }
}
