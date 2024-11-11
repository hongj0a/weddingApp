import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/document/contract_detail.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import '../../config/ApiConstants.dart';

class DocumentUploadPage extends StatefulWidget {
  @override
  _DocumentUploadPageState createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  final ImagePicker _picker = ImagePicker();
  String extractedText = ''; // 텍스트 인식 결과 저장 변수
  String parsedText = ''; // 추출된 텍스트를 저장할 String 변수
  String filepath = '';
  bool isLoading = false;

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
      body: Stack(
        children: [
          Center(
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
              ],
            ),
          ),

          // 로딩 인디케이터를 표시하는 조건부 위젯
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
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
                  Navigator.pop(context); // 모달 닫기
                  await _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo, color: Colors.black),
                title: Text('갤러리에서 가져오기', style: TextStyle(color: Colors.black)),
                onTap: () async {
                  Navigator.pop(context); // 모달 닫기
                  await _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /*ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.black),
                title: Text('PDF 문서 가져오기', style: TextStyle(color: Colors.black)),
                onTap: () async {
                  await _pickPDF();
                  //Navigator.pop(context);
                },
              ),*/

  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      print('pickedFile ... $pickedFile');
      setState(() {
        isLoading = true; // 로딩 시작
      });
      await _parseTheText(File(pickedFile.path));
      setState(() {
        isLoading = false; // 로딩 종료
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      isLoading = true;
    });
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      await _parseTheText(File(pickedFile.path));
    }
    setState(() {
      isLoading = false;
    });
  }

  /*Future<void> _pickPDF() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.single.path;
      if (filePath != null) {
        print('Picked PDF: $filePath');
        //await _extractTextFromPDF(File(filePath));  // PDF에서 텍스트 추출 메서드로 수정
      }
    }
  }*/


  Future<File> resizeImage(File imageFile) async {
    // 원본 이미지 파일을 읽어서 decode
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? originalImage = img.decodeImage(imageBytes);

    // 이미지 크기 조정 (예: 가로 800px로 설정)
    if (originalImage != null) {
      final img.Image resizedImage = img.copyResize(originalImage, width: 800);

      // 조정된 이미지를 새로운 파일로 저장
      final resizedImageFile = File(imageFile.path)..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 85));
      return resizedImageFile;
    } else {
      throw Exception("이미지 크기 조정 실패");
    }
  }

  Map<String, String?> _extractDetails(String inputText) {
    Map<String, String?> contractInfo = {
      "ContractName": null,
      "CompanyName": null,
      "EventDate": null,
      "ContractAmount": null,
      "TotalAmount": null,
    };

    List<String> extractedAmounts = [];

    List<int> amounts = [];

    // 1. 계약서 이름 추출: '계약서' 뒤에 나오는 텍스트를 모두 추출
    RegExp regExpContractName = RegExp(r"계약서[\w\s]*");
    var matchContractName = regExpContractName.firstMatch(inputText);
    if (matchContractName != null) {
      contractInfo["ContractName"] = matchContractName.group(0);
    }

    // 2. 회사 이름 추출: '부 서 장'과 같은 정보를 추출
    RegExp regExpCompanyName = RegExp(r"(회사명|사업자명|사업자 명[^0-9\s]+)\s*(\S.*?)(?=\s|$)");
    var matchCompanyName = regExpCompanyName.firstMatch(inputText);
    if (matchCompanyName != null) {
      contractInfo["CompanyName"] = matchCompanyName.group(2); // 두 번째 그룹이 실제 회사명
    }

    // 3. 행사 날짜 추출: 행사 날짜 형식 (YYYY년 MM월 DD일)
    RegExp regExpEventDate = RegExp(r"\d{4}년 \d{2}월 \d{2}일");
    var matchEventDate = regExpEventDate.firstMatch(inputText);
    if (matchEventDate != null) {
      contractInfo["EventDate"] = matchEventDate.group(0);
    }

// 계약금 추출
    RegExp regExpDeposit = RegExp(r"(계약금|계약금액|예약금)[\s:]*([\d,\.]+)\s*(만원|원)?");
    var matchDeposit = regExpDeposit.firstMatch(inputText);
    if (matchDeposit != null) {
      // 정규식에서 천 단위 구분자(,)와 소수점(.)을 포함한 숫자 추출 후 숫자만 남기기
      String amount = matchDeposit.group(2)?.replaceAll(RegExp(r'[^0-9\.]'), '') ?? ''; // ₩, % 등 제거
      String unit = matchDeposit.group(3)?.trim() ?? '원';
      contractInfo["ContractAmount"] = '$amount $unit';
      print("계약금 추출 성공: ${contractInfo["계약금"]}");
    } else {
      print("계약금 추출 실패");
    }

// 총금액 추출
    RegExp regExpTotalCost = RegExp(r"(총금액|총 금액|전체금액|합계)[\s:]*([\d,\.]+)\s*(만원|원)?");
    var matchTotalCost = regExpTotalCost.firstMatch(inputText);
    if (matchTotalCost != null) {
      String amount = matchTotalCost.group(2)?.replaceAll(RegExp(r'[^0-9\.]'), '') ?? ''; // ₩, % 등 제거
      String unit = matchTotalCost.group(3)?.trim() ?? '원';
      contractInfo["TotalAmount"] = '$amount $unit';
      print("총금액 추출 성공: ${contractInfo["총금액"]}");
    } else {
      print("총금액 추출 실패");
    }

// 모든 금액 패턴 추출
    if (contractInfo["총금액"] == null) {
      RegExp regExpAllAmounts = RegExp(r"(\d{1,3}(?:[.,]?\d{3})*)\s*(만원|원|₩)?");
      var matches = regExpAllAmounts.allMatches(inputText);
      for (var match in matches) {
        // 모든 금액에서 구분 기호와 불필요한 기호 제거
        String amount = match.group(1)?.replaceAll(RegExp(r'[^\d]'), '') ?? ''; // 천 단위 구분자와 다른 문자를 제거
        String unit = match.group(2)?.trim() ?? '원';
        String fullAmount = '$amount $unit';
        extractedAmounts.add(fullAmount);  // 금액을 extractedAmounts에 추가
        print('추출된 금액: $amount $unit');

        // 금액에 소수점이 포함된 경우 처리
        if (fullAmount.contains('만원')) {
          int value = int.parse(amount.replaceAll('만원', '').trim()) * 10000;
          amounts.add(value);
        } else if (fullAmount.contains('원')) {
          // 소수점을 제외하고 정수로 변환
          int value = int.parse(amount.replaceAll('원', '').trim());
          amounts.add(value);
        }
      }

      int maxAmount = amounts.isNotEmpty ? amounts.reduce((a, b) => a > b ? a : b) : 0;
      int totalAmount = maxAmount != 0 ? maxAmount : 0;
      contractInfo["TotalAmount"] = totalAmount.toString();
    }


// 디버깅 정보
    print("추출된 계약서 정보:");
    print('계약서 이름: ${contractInfo["ContractName"]}');
    print('계약금: ${contractInfo["ContractAmount"]}');
    print('총금액: ${contractInfo["TotalAmount"]}');
    print('회사명: ${contractInfo["CompanyName"]}');
    print('행사 날짜: ${contractInfo["EventDate"]}');


    return contractInfo;
  }

  _parseTheText(File image) async {
    // 이미지 크기를 먼저 줄이기
    File resizedImage = await resizeImage(image);
    var bytes = resizedImage.readAsBytesSync();
    String img64 = base64Encode(bytes);

    var url = 'https://api.ocr.space/parse/image';
    var payload = {"base64Image": "data:image/jpg;base64,${img64.toString()}", "language": "kor"};
    var header = {"apikey": "K84046334488957"};

    var post = await http.post(Uri.parse(url), body: payload, headers: header);
    var result = jsonDecode(post.body);
    print('OCR result: $result');

    if (result != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      var ocrCountUrl = ApiConstants.setOcrCount; // setOcrCount의 API URL을 설정

      // 헤더에 토큰 추가
      var authHeader = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      // GET 요청 보내기
      var ocrCountResponse = await http.get(Uri.parse(ocrCountUrl), headers: authHeader);
      if (ocrCountResponse.statusCode == 200) {
        print("OCR count incremented successfully.");
      } else {
        print("Failed to increment OCR count: ${ocrCountResponse.statusCode}");
      }
    }

    setState(() {
      if (result != null && result['ParsedResults'] != null && result['ParsedResults'].isNotEmpty) {
        parsedText = result['ParsedResults'][0]['ParsedText'];
      } else {
        parsedText = '';
      }
      filepath = image.path;
      print('parsedText... $parsedText');
    });

    if (parsedText.isNotEmpty) {
      Map<String, String?> contractInfo = _extractDetails(parsedText);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContractDetail(contractInfo: contractInfo, imageFile: image),
        ),
      );
    } else {
      print("No text found in the image.");
    }
  }
}
