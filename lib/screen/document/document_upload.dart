import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/document/contract_detail.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import '../../themes/theme.dart';

class DocumentUploadPage extends StatefulWidget {

  @override
  _DocumentUploadPageState createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  final ImagePicker _picker = ImagePicker();
  String extractedText = '';
  String parsedText = '';
  String filepath = '';
  bool isLoading = false;
  ApiService apiService = ApiService();

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
          child: Padding(
            padding: EdgeInsets.only(bottom: 50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '계약서를 등록해 주세요',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 50.0),
                Icon(
                  Icons.insert_drive_file,
                  size: 100.0,
                  color: AppColors.primaryColor,
                ),
                SizedBox(height: 50.0),
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
          ),

          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }


  void _showBottomSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: Container(
            width: MediaQuery.of(context).size.width * 2.0,
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '계약서 등록 시 주의사항',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• 수기로 작성된 계약서는 글자인식이 되지 않아요.', style: TextStyle(color: Colors.black)),
                    Text('• 수기로 작성됐어도 수정해서 등록할 수 있어요.', style: TextStyle(color: Colors.black)),
                    Text('• 빛반사가 없는 환경에서 정확하게 촬영해주세요.', style: TextStyle(color: Colors.black)),
                    Text('• 글자가 정확한 사진일수록 인식률이 올라가요.', style: TextStyle(color: Colors.black)),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        '취소',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showImageSelectionBottomSheet(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        '확인',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }


  void _showImageSelectionBottomSheet(BuildContext context) {
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
                '    계약서 등록하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.black),
                title: Text('직접 촬영하기', style: TextStyle(color: Colors.black)),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo, color: Colors.black),
                title: Text('갤러리에서 가져오기', style: TextStyle(color: Colors.black)),
                onTap: () async {
                  Navigator.pop(context);
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
        isLoading = true;
      });
      await _parseTheText(File(pickedFile.path));
      setState(() {
        isLoading = false;
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
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage != null) {
      final img.Image resizedImage = img.copyResize(originalImage, width: 800);

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
      "EventTime": null,
      "ContractAmount": null,
      "TotalAmount": null,
    };

    List<String> extractedAmounts = [];

    List<int> amounts = [];

    RegExp regExpContractName = RegExp(r"계약서[\w\s]*");
    var matchContractName = regExpContractName.firstMatch(inputText);
    if (matchContractName != null) {
      contractInfo["ContractName"] = matchContractName.group(0);
    }

    RegExp regExpCompanyName = RegExp(r"(회사명|사업자명|사업자 명[^0-9\s]+)\s*(\S.*?)(?=\s|$)");
    var matchCompanyName = regExpCompanyName.firstMatch(inputText);
    if (matchCompanyName != null) {
      contractInfo["CompanyName"] = matchCompanyName.group(2);
    }

    //RegExp regExpEventDate = RegExp(r"\d{4}년 \d{2}월 \d{2}일");
    RegExp regExpEventDate = RegExp(r'(\d{4}[-.]\d{2}[-.]\d{2})|(\d{4}년 \s*\d{2}월 \s*\d{2}일)');

    Iterable<Match> matches = regExpEventDate.allMatches(inputText);

    for (var match in matches) {
      print('@@@@@@@@@@@@@@@@@@@@@@@, ${match.group(0)}');
    }

    var matchEventDate = regExpEventDate.firstMatch(inputText);
    if (matchEventDate != null) {
      var eventDate = matchEventDate.group(1);
      var eventDate2 = matchEventDate.group(2);

      String formattedDate = '';

      if (eventDate != null) {
        try {
          DateTime date = DateTime.parse(eventDate.replaceAll(RegExp(r'[.-]'), '-'));
          formattedDate = DateFormat('yyyy-MM-dd').format(date);
        } catch (e) {
          print("Error parsing eventDate: $e");
        }
      } else if (eventDate2 != null) {
        try {
          DateTime date = DateFormat('yyyy년 MM월 dd일').parse(eventDate2);
          formattedDate = DateFormat('yyyy-MM-dd').format(date);
        } catch (e) {
          print("Error parsing eventDate2: $e");
        }
      }

      if (formattedDate.isNotEmpty) {
        contractInfo["EventDate"] = formattedDate;
      }
    }

    RegExp regExpEventTime = RegExp(r'(\d{2}):(\d{2})');
    var matchEventTime = regExpEventTime.firstMatch(inputText);
    if (matchEventTime != null) {
      String hour = matchEventTime.group(1) ?? '';
      String minute = matchEventTime.group(2) ?? '';
      String formattedTime = '$hour:$minute';

      contractInfo["EventTime"] = formattedTime;
      print("행사 시간 추출 성공: $formattedTime");
    } else {
      print("행사 시간 추출 실패");
    }


    RegExp regExpDeposit = RegExp(r"(계약금|계약금액|예약금)[\s:]*([\d,\.]+)\s*(만원|원)?");
    var matchDeposit = regExpDeposit.firstMatch(inputText);
    if (matchDeposit != null) {
      String amount = matchDeposit.group(2)?.replaceAll(RegExp(r'[^0-9\.]'), '') ?? '';
      String unit = matchDeposit.group(3)?.trim() ?? '원';
      contractInfo["ContractAmount"] = '$amount $unit';
      print("계약금 추출 성공: ${contractInfo["계약금"]}");
    } else {
      print("계약금 추출 실패");
    }

    RegExp regExpTotalCost = RegExp(r"(총금액|총 금액|전체금액|합계)[\s:]*([\d,\.]+)\s*(만원|원)?");
    var matchTotalCost = regExpTotalCost.firstMatch(inputText);
    if (matchTotalCost != null) {
      String amount = matchTotalCost.group(2)?.replaceAll(RegExp(r'[^0-9\.]'), '') ?? '';
      String unit = matchTotalCost.group(3)?.trim() ?? '원';
      contractInfo["TotalAmount"] = '$amount $unit';
      print("총금액 추출 성공: ${contractInfo["총금액"]}");
    } else {
      print("총금액 추출 실패");
    }

    if (contractInfo["총금액"] == null) {
      RegExp regExpAllAmounts = RegExp(r"(\d{1,3}(?:[.,]?\d{3})*)\s*(만원|원|₩)?");
      var matches = regExpAllAmounts.allMatches(inputText);
      for (var match in matches) {
        String amount = match.group(1)?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
        String unit = match.group(2)?.trim() ?? '원';
        String fullAmount = '$amount $unit';
        extractedAmounts.add(fullAmount);
        print('추출된 금액: $amount $unit');

        if (fullAmount.contains('만원')) {
          int value = int.parse(amount.replaceAll('만원', '').trim()) * 10000;
          amounts.add(value);
        } else if (fullAmount.contains('원')) {
          int value = int.parse(amount.replaceAll('원', '').trim());
          amounts.add(value);
        }
      }

      int maxAmount = amounts.isNotEmpty ? amounts.reduce((a, b) => a > b ? a : b) : 0;
      int totalAmount = maxAmount != 0 ? maxAmount : 0;
      contractInfo["TotalAmount"] = totalAmount.toString();
    }


    print("추출된 계약서 정보:");
    print('계약서 이름: ${contractInfo["ContractName"]}');
    print('계약금: ${contractInfo["ContractAmount"]}');
    print('총금액: ${contractInfo["TotalAmount"]}');
    print('회사명: ${contractInfo["CompanyName"]}');
    print('행사 날짜: ${contractInfo["EventDate"]}');
    print('행사 시간: ${contractInfo["EventTime"]}');


    return contractInfo;
  }

  _parseTheText(File image) async {
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

      var ocrCountUrl = ApiConstants.setOcrCount;

      var authHeader = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      var ocrCountResponse = await apiService.get(ocrCountUrl);
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
