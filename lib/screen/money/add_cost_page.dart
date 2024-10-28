import 'package:flutter/material.dart';

class AddCostPage extends StatefulWidget {
  final int? categorySeq; // 카테고리 시퀀스를 추가

  AddCostPage({Key? key, this.categorySeq}) : super(key: key);


  @override
  _AddCostPageState createState() => _AddCostPageState();
}

class _AddCostPageState extends State<AddCostPage> {
  @override
  Widget build(BuildContext context) {
    print('카테고리 시퀀스: ${widget.categorySeq}'); // 여기서 출력
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('항목 추가'),
        actions: [
          TextButton(
            onPressed: () {
              // Implement save functionality if needed
            },
            child: Text(
              '저장',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildTextField('항목', false),
              SizedBox(height: 16.0),
              buildTextField('총 비용', true),
              SizedBox(height: 16.0),
              buildTextField('계약금', true),
              SizedBox(height: 16.0),
              buildTextField('세부비용, 추가금 등', true),
              SizedBox(height: 16.0),
              buildTextField('신랑 지출', true),
              SizedBox(height: 16.0),
              buildTextField('신부 지출', true),
              SizedBox(height: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '메모',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: '메모를 남겨보세요(최대 100자)',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    maxLines: 4, // 최대 줄 수를 4줄로 설정
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, bool isCost) {
    return TextField(
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        suffixText: isCost ? '원' : null,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5), // 연한 회색으로 아주 얇게 설정
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(250, 15, 156, 1.0), width: 1), // 포커스 시 테두리 색상
        ),
      ),
      keyboardType: isCost ? TextInputType.number : TextInputType.text,
    );
  }
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.blue,
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.black, fontSize: 16.0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
        labelStyle: TextStyle(color: Colors.black),
        hintStyle: TextStyle(color: Colors.grey),
      ),
      appBarTheme: AppBarTheme(
        color: Colors.blue,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20.0),
        iconTheme: IconThemeData(color: Colors.white),
      ),
    ),
    home: AddCostPage(),
  ));
}
