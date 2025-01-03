import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import '../../config/ApiConstants.dart';
import '../../themes/theme.dart';

class DDayRegistrationPage extends StatefulWidget {
  @override
  _DDayRegistrationPageState createState() => _DDayRegistrationPageState();
}

class _DDayRegistrationPageState extends State<DDayRegistrationPage> {
  DateTime selectedDate = DateTime.now();
  TextEditingController eventController = TextEditingController();
  File? _image;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: Colors.black),
              bodyLarge: TextStyle(color: Colors.black),
              labelLarge: TextStyle(color: Colors.black),
            ),
          ),
          child: child ?? Container(),
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String formatDate(DateTime date) {
    return intl.DateFormat('y년 M월 d일', 'ko_KR').format(date);
  }


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _saveDday() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      var url = Uri.parse(ApiConstants.setDDay);
      var request = http.MultipartRequest('POST', url);

      request.headers['Authorization'] = 'Bearer $accessToken';
      request.fields['title'] = eventController.text;
      request.fields['date'] = DateFormat('yyyy-MM-dd').format(selectedDate);

      if (_image != null) {
        String mimeType = lookupMimeType(_image!.path) ?? 'image/jpeg';
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          contentType: MediaType.parse(mimeType),
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        print('D-day saved successfully');
        Navigator.pop(context);
      } else {
        print('Failed to save D-day: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving D-day: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveDday,
            child: Text(
              '저장',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                ClipOval(
                  child: Container(
                    width: 120,
                    height: 120,
                    child: _image != null
                        ? Image.file(
                      _image!,
                      fit: BoxFit.cover,
                    )
                        : SvgPicture.asset(
                      'asset/img/dday_icon.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.edit, color: Colors.grey[700]),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: eventController,
                decoration: InputDecoration(
                  hintText: '이벤트 이름',
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
            ListTile(
              title: Text("이벤트 날짜"),
              trailing: Text(
                DateFormat('y년 M월 d일').format(selectedDate),
                style: TextStyle(  fontSize: 13, fontWeight: FontWeight.bold),
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
