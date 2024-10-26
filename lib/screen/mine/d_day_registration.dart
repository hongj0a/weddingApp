import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:intl/intl.dart'; // For date formatting
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For setting MediaType
import 'package:mime/mime.dart'; // For MIME type lookup
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/ApiConstants.dart'; // For accessing shared preferences

class DDayRegistrationPage extends StatefulWidget {
  @override
  _DDayRegistrationPageState createState() => _DDayRegistrationPageState();
}

class _DDayRegistrationPageState extends State<DDayRegistrationPage> {
  DateTime selectedDate = DateTime.now();
  TextEditingController eventController = TextEditingController();
  File? _image; // To store the picked image

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path); // Store the selected image
      }
    });
  }

  Future<void> _saveDday() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken'); // accessToken 가져오기

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      var url = Uri.parse(ApiConstants.setDDay); // ApiConstants.setDday URL 사용
      var request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $accessToken'; // Access token 헤더에 추가
      request.fields['title'] = eventController.text; // Event name 추가
      request.fields['date'] = DateFormat('yyyy-MM-dd').format(selectedDate); // 날짜 추가

      if (_image != null) {
        String mimeType = lookupMimeType(_image!.path) ?? 'image/jpeg';
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          contentType: MediaType.parse(mimeType),
        ));
      }

      // 요청 전송
      var response = await request.send();

      if (response.statusCode == 200) {
        print('D-day saved successfully');
        Navigator.pop(context); // 성공 시 페이지 뒤로 가기
      } else {
        print('Failed to save D-day: ${response.statusCode}');
        // 실패 처리
      }
    } catch (e) {
      print('Error saving D-day: $e');
      // 예외 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // DDayManagementPage로 돌아가기
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveDday, // 저장 기능 호출
            child: Text(
              'Save',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 이미지 섹션
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _image != null
                          ? FileImage(_image!) // 선택된 이미지 표시
                          : AssetImage('asset/img/wed_05.jpg') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton(
                    onPressed: _pickImage,
                    mini: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Icon(Icons.edit, color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // 이벤트 이름 입력
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: eventController,
                decoration: InputDecoration(
                  hintText: 'Enter Event Name',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  contentPadding: EdgeInsets.only(left: 8),
                ),
              ),
            ),
            // 날짜 선택
            ListTile(
              title: Text("Event Day"),
              trailing: Text(
                DateFormat.yMMMMd().format(selectedDate),
                style: TextStyle(fontFamily: 'PretendardVariable', fontSize: 13, fontWeight: FontWeight.bold),
              ),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
