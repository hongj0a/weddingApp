import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mime/mime.dart'; // For MIME type lookup
import 'package:http_parser/http_parser.dart'; // For setting MediaType
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import 'my_page.dart';



class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  String imageUrl = '${ApiConstants.localImagePath}/';
  final TextEditingController _nicknameController = TextEditingController();
  String? _imagePath;
  String? _imageInfo;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchUserInfo(); // 사용자 정보를 가져옴
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('프로필 수정'),
        actions: [
          TextButton(
            onPressed: () async {
              // 완료 버튼을 눌렀을 때 실행될 코드
              await _updateUserInfo(context);
            },
            child: Text(
              '완료',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 50.0,
                    backgroundColor: Colors.grey[100],
                    backgroundImage: _imagePath != null
                        ? FileImage(File(_imagePath!)) // 새로 선택한 이미지가 있을 경우
                        : (_imageInfo != null && _imageInfo!.isNotEmpty
                        ? NetworkImage(_imageInfo!)
                        : null), // 서버에서 불러온 이미지가 있을 경우
                    child: _imagePath == null &&
                        (_imageInfo == null || _imageInfo!.isEmpty)
                        ? Icon(Icons.person, size: 50.0) // 이미지가 선택되지 않은 경우
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 140,
                    child: GestureDetector(
                      onTap: _selectImage, // 이미지 선택 함수 호출
                      child: CircleAvatar(
                        radius: 15.0,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt, size: 18.0, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '닉네임',
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: _nicknameController, // 닉네임 컨트롤러 설정
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _selectImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // 갤러리에서 이미지 선택

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path; // 선택한 이미지의 경로 저장
      });
    }
  }

  Future<void> _updateUserInfo(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      var url = Uri.parse(ApiConstants.setUserInfo);

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.fields['nickName'] = _nicknameController.text; // 닉네임 필드 추가

      print('imagePath: $_imagePath');
      // 이미지가 있는 경우에만 파일 추가
      if (_imagePath != null && _imagePath!.isNotEmpty) {
        String mimeType = lookupMimeType(_imagePath!) ?? 'image/jpeg';
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _imagePath!,
          contentType: MediaType.parse(mimeType),
        ));
      }

      var response = await request.send(); // 요청 전송

      if (response.statusCode == 200) {
        print('User info updated successfully');
        Navigator.pop(context, true);
      } else {
        print('Failed to update user info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating user info: $e');
    }
  }
  Future<void> _fetchUserInfo() async {
    var response = await apiService.get(
      ApiConstants.getUserInfo,
    );

    if (response.statusCode == 200) {
      var data = response.data['data'];
      setState(() {
        _nicknameController.text = data['nickName'];
        _imageInfo = data['image'];
        //_defaultImage = data['image'];
      });
    } else {
      throw Exception('Failed to load user info');
    }
  }
}
