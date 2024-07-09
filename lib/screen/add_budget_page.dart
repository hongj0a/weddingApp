import 'package:flutter/material.dart';

class AddBudgetPage extends StatefulWidget {
  @override
  _AddBudgetPageState createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              buildTextField('세부비용', true),
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
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: '메모를 남겨보세요(최대 100자)',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
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
        border: OutlineInputBorder(),
      ),
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
    home: AddBudgetPage(),
  ));
}
