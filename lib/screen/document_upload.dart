import 'package:flutter/material.dart';

class DocumentUploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                label: Text('계약서 등록하기', style: TextStyle (color: Colors.black)),
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
        return Container(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(  // SingleChildScrollView로 변경
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
                  onTap: () {
                    // 직접 촬영하기 클릭 시 처리할 코드
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo),
                  title: Text('갤러리에서 가져오기'),
                  onTap: () {
                    // 갤러리에서 가져오기 클릭 시 처리할 코드
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text('PDF 문서 가져오기'),
                  onTap: () {
                    // PDF 문서 가져오기 클릭 시 처리할 코드
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
