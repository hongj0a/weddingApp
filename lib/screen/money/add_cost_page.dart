import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../config/ApiConstants.dart';
import 'cost_page.dart';

class AddCostPage extends StatefulWidget {
  final int? categorySeq; // 카테고리 시퀀스를 추가

  AddCostPage({Key? key, this.categorySeq}) : super(key: key);


  @override
  _AddCostPageState createState() => _AddCostPageState();
}

class _AddCostPageState extends State<AddCostPage> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController totalCostController = TextEditingController();
  final TextEditingController contractCostController = TextEditingController();
  final TextEditingController additionalCostController = TextEditingController();
  final TextEditingController middleCostController = TextEditingController();
  final TextEditingController groomCostController = TextEditingController();
  final TextEditingController brideCostController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
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
            onPressed: saveCostItem,
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
              buildTextField('항목', itemController, false),
              SizedBox(height: 16.0),
              buildTextField('총 비용', totalCostController, true),
              SizedBox(height: 16.0),
              buildTextField('계약금', contractCostController, true),
              SizedBox(height: 16.0),
              buildTextField('세부비용, 추가금 등', additionalCostController, true),
              SizedBox(height: 16.0),
              buildTextField('중도금', middleCostController, true),
              SizedBox(height: 16.0),
              buildTextField('신랑 지출', groomCostController, true),
              SizedBox(height: 16.0),
              buildTextField('신부 지출', brideCostController, true),
              SizedBox(height: 16.0),
              buildMemoField(),
            ],
          ),
        ),
      ),
    );
  }




  Widget buildTextField(String label, TextEditingController controller, bool isCost) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        suffixText: isCost ? '원' : null,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(250, 15, 156, 1.0), width: 1),
        ),
      ),
      keyboardType: isCost ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      textInputAction: TextInputAction.done, // 완료 버튼 추가
      onEditingComplete: () {
        FocusScope.of(context).unfocus(); // 완료 버튼 클릭 시 키보드 닫기
      },
      inputFormatters: isCost ? [CurrencyInputFormatter()] : [],
    );
  }

  Widget buildMemoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '메모',
          style: TextStyle(fontSize: 16.0),
        ),
        SizedBox(height: 8.0),
        TextField(
          controller: memoController,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            hintText: '메모를 남겨보세요(최대 100자)',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(250, 15, 156, 1.0), width: 1), // 활성화 시 색상 변경
            ),
          ),
          maxLength: 100,
          maxLines: 4, // 최대 줄 수를 4줄로 설정
        ),
      ],
    );
  }

  void saveCostItem() async {
    // 빈 값 체크
    if (itemController.text.isEmpty || totalCostController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("항목과 총 비용을 모두 입력해 주세요.")),
      );
      return;
    }
    final data = {
      "seq": widget.categorySeq,
      "item": itemController.text,
      "totalCost": int.tryParse(totalCostController.text.replaceAll(',', '')) ?? 0,
      "contractCost": int.tryParse(contractCostController.text.replaceAll(',', '')) ?? 0,
      "detailCost": int.tryParse(additionalCostController.text.replaceAll(',', '')) ?? 0,
      "middleCost": int.tryParse(middleCostController.text.replaceAll(',', '')) ?? 0,
      "groomCost": int.tryParse(groomCostController.text.replaceAll(',', '')) ?? 0,
      "brideCost": int.tryParse(brideCostController.text.replaceAll(',', '')) ?? 0,
      "memo": memoController.text,
    };

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      var url = Uri.parse(ApiConstants.setChecklist);

      print('data... $data');

      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json', // JSON 형식의 데이터 전송
        },
        body: jsonEncode(data),
      );
      print('response....msg ... ${response.body}');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장되었습니다.")));
        Navigator.pop(context, true);  // 뒤로 가면서 true 반환
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장 실패: ${response.statusCode}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("에러 발생: $e")));
    }
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // 콤마 없이 숫자만 남기기
    String newText = newValue.text.replaceAll(',', '');

    if (newText.isEmpty) return newValue;

    // 형식화된 문자열 만들기 (콤마 추가)
    String formattedText = _formatWithComma(newText);

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _formatWithComma(String value) {
    final number = int.tryParse(value);
    return number != null ? NumberFormat('#,###').format(number) : value;
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
}