import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/ApiConstants.dart';


class DetailPage extends StatefulWidget {
  final Map<String, dynamic> detailData; // detailData를 Map으로 받음

  DetailPage({Key? key, required this.detailData}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late TextEditingController _titleController;
  late TextEditingController _totalCostController;
  late TextEditingController _depositController;
  late TextEditingController _additionalCostsController;
  late TextEditingController _middleCostController;
  late TextEditingController _groomExpenseController;
  late TextEditingController _brideExpenseController;
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values from detailData
    _titleController = TextEditingController(text: widget.detailData['name'] ?? '');
    _totalCostController = TextEditingController(text: _formatWithComma(widget.detailData['totalCost']?.toString() ?? ''));
    _depositController = TextEditingController(text: _formatWithComma(widget.detailData['contractCost']?.toString() ?? ''));
    _additionalCostsController = TextEditingController(text: _formatWithComma(widget.detailData['detailCost']?.toString() ?? ''));
    _middleCostController = TextEditingController(text: _formatWithComma(widget.detailData['middleCost']?.toString() ?? ''));
    _groomExpenseController = TextEditingController(text: _formatWithComma(widget.detailData['groomCost']?.toString() ?? ''));
    _brideExpenseController = TextEditingController(text: _formatWithComma(widget.detailData['brideCost']?.toString() ?? ''));
    _memoController = TextEditingController(text: widget.detailData['memo'] ?? '');
  }
  String _formatWithComma(String value) {
    final number = int.tryParse(value);
    return number != null ? NumberFormat('#,###').format(number) : value;
  }

  Future<void> _saveData() async {
    final url = Uri.parse(ApiConstants.updateChecklist);

    // 서버로 보낼 데이터를 Map으로 준비합니다.
    final data = {
      'seq': widget.detailData['seq'],
      'item': _titleController.text,
      'totalCost': int.tryParse(_totalCostController.text.replaceAll(',', '')) ?? 0,
      'contractCost': int.tryParse(_depositController.text.replaceAll(',', '')) ?? 0,
      'detailCost': int.tryParse(_additionalCostsController.text.replaceAll(',', '')) ?? 0,
      'middleCost': int.tryParse(_middleCostController.text.replaceAll(',', '')) ?? 0,
      'groomCost': int.tryParse(_groomExpenseController.text.replaceAll(',', '')) ?? 0,
      'brideCost': int.tryParse(_brideExpenseController.text.replaceAll(',', '')) ?? 0,
      'memo': _memoController.text,
    };

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      // POST 요청을 통해 서버로 데이터를 전송합니다.
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          print('데이터 저장 성공');
          Navigator.pop(context, true);
        }
      } else {
        print('데이터 저장 실패: ${response.body}');
      }
    } catch (e) {
      print('서버 요청 오류: $e');
    }
  }
  Future<void> _deleteData() async {
    final seq = widget.detailData['seq'];
    final url = Uri.parse('${ApiConstants.deleteChecklist}?seq=$seq');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          print('데이터 삭제 성공');
          Navigator.pop(context, true); // 삭제 후 이전 화면으로 돌아감
        }
      } else {
        print('데이터 삭제 실패: ${response.body}');
      }
    } catch (e) {
      print('서버 요청 오류: $e');
    }
  }


  @override
  void dispose() {
    // Dispose controllers
    _titleController.dispose();
    _totalCostController.dispose();
    _depositController.dispose();
    _additionalCostsController.dispose();
    _middleCostController.dispose();
    _groomExpenseController.dispose();
    _brideExpenseController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _saveData(); // 데이터 저장
        return true; // 데이터 저장 후 팝 허용
      },
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('세부 사항'),
        actions: [
          TextButton(
            onPressed: _deleteData,
            child: Text(
              '삭제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildTextField('항목', _titleController, false),
              SizedBox(height: 16.0),
              buildTextField('총 비용', _totalCostController, true),
              SizedBox(height: 16.0),
              buildTextField('계약금', _depositController, true),
              SizedBox(height: 16.0),
              buildTextField('세부비용, 추가금 등', _additionalCostsController, true),
              SizedBox(height: 16.0),
              buildTextField('중도금', _middleCostController, true),
              SizedBox(height: 16.0),
              buildTextField('신랑 지출', _groomExpenseController, true),
              SizedBox(height: 16.0),
              buildTextField('신부 지출', _brideExpenseController, true),
              SizedBox(height: 16.0),
              buildMemoField(),
            ],
          ),
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
          borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5), // 연한 회색으로 아주 얇게 설정
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(250, 15, 156, 1.0), width: 1), // 포커스 시 테두리 색상
        ),
      ),
      keyboardType: isCost ? TextInputType.number : TextInputType.text,
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
          controller: _memoController,
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
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,
      TextEditingValue newValue) {
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
}
