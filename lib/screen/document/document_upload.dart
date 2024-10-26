import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentUploadPage extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

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
            SizedBox(height: 50.0),
            Icon(
              Icons.insert_drive_file,
              size: 100.0,
              color: Colors.blue,
            ),
            SizedBox(height: 50.0),
            Container(
              width: 160, // 원하는 너비를 설정
              child: ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('계약서 등록하기', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  _showBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Builder(
          builder: (BuildContext newContext) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '계약서 등록하기',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      leading: Icon(Icons.camera_alt),
                      title: Text('직접 촬영하기'),
                      onTap: () async {
                        await _pickImageFromCamera(newContext);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.photo),
                      title: Text('갤러리에서 가져오기'),
                      onTap: () async {
                        await _pickImageFromGallery(newContext);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.picture_as_pdf),
                      title: Text('PDF 문서 가져오기'),
                      onTap: () async {
                        await _pickPDF(newContext);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Future<void> _pickImageFromCamera(BuildContext context) async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        // Handle the picked image
        print('Picked image: ${pickedFile.path}');
      }
    } else {
      _showPermissionDeniedDialog(context, '카메라');
    }
    Navigator.pop(context);
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      print('DocumentUploadPage._pickImageFromGallery@@@');
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Handle the picked image
        print('Picked image: ${pickedFile.path}');
      }
    } else {
      print('DocumentUploadPage._pickImageFromGallery###');
      _showPermissionDeniedDialog(context, '갤러리');
    }
    Navigator.pop(context);
  }

  Future<void> _pickPDF(BuildContext context) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
      if (result != null) {
        // Handle the picked PDF file
        print('Picked PDF: ${result.files.single.path}');
      } else {
        // User canceled the picker
        print('User canceled PDF picking');
      }
    } else {
      _showPermissionDeniedDialog(context, '저장소');
    }
    Navigator.pop(context);
  }

  void _showPermissionDeniedDialog(BuildContext context, String permissionName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$permissionName 권한이 필요합니다. 설정으로 이동하여 권한을 허용해주세요.'),
        action: SnackBarAction(
          label: '설정으로 이동',
          onPressed: () async {
            await openAppSettings();
          },
        ),
      ),
    );
  }

}
