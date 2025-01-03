import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';


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
    _fetchUserInfo();
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
                        ? FileImage(File(_imagePath!))
                        : (_imageInfo != null && _imageInfo!.isNotEmpty
                        ? NetworkImage(_imageInfo!)
                        : null),
                    child: _imagePath == null &&
                        (_imageInfo == null || _imageInfo!.isEmpty)
                        ? Icon(Icons.person, size: 50.0)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 140,
                    child: GestureDetector(
                      onTap: _selectImage,
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
                controller: _nicknameController,
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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
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
      request.fields['nickName'] = _nicknameController.text;

      print('imagePath: $_imagePath');
      if (_imagePath != null && _imagePath!.isNotEmpty) {
        String mimeType = lookupMimeType(_imagePath!) ?? 'image/jpeg';
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _imagePath!,
          contentType: MediaType.parse(mimeType),
        ));
      }

      var response = await request.send();

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
      });
    } else {
      throw Exception('Failed to load user info');
    }
  }
}
