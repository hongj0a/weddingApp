import 'package:flutter/material.dart';

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
  late TextEditingController _groomExpenseController;
  late TextEditingController _brideExpenseController;
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values from detailData
    _titleController = TextEditingController(text: widget.detailData['name'] ?? '');
    _totalCostController = TextEditingController(text: widget.detailData['totalCost']?.toString() ?? '');
    _depositController = TextEditingController(text: widget.detailData['contractCost']?.toString() ?? '');
    _additionalCostsController = TextEditingController(text: widget.detailData['detailCost']?.toString() ?? '');
    _groomExpenseController = TextEditingController(text: widget.detailData['groomCost']?.toString() ?? '');
    _brideExpenseController = TextEditingController(text: widget.detailData['brideCost']?.toString() ?? '');
    _memoController = TextEditingController(text: widget.detailData['memo'] ?? '');
  }

  @override
  void dispose() {
    // Dispose controllers
    _titleController.dispose();
    _totalCostController.dispose();
    _depositController.dispose();
    _additionalCostsController.dispose();
    _groomExpenseController.dispose();
    _brideExpenseController.dispose();
    _memoController.dispose();
    super.dispose();
  }
// 뒤로가기 버튼을 눌렀을 때 저장하는 메서드
  Future<void> _saveData() async {
    // 여기에 API 호출 코드를 추가하여 데이터를 저장하세요.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('세부 사항'),
        actions: [
          TextButton(
            onPressed: _saveData,
            child: Text(
              '삭제',
              style: TextStyle(color: Colors.red), // 삭제 버튼을 빨간색으로 설정
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
              buildTextField('신랑 지출', _groomExpenseController, true),
              SizedBox(height: 16.0),
              buildTextField('신부 지출', _brideExpenseController, true),
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
          borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5), // 연한 회색으로 아주 얇게 설정
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(250, 15, 156, 1.0), width: 1), // 포커스 시 테두리 색상
        ),
      ),
      keyboardType: isCost ? TextInputType.number : TextInputType.text,
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
          ),
          maxLength: 100,
          maxLines: 4, // 최대 줄 수를 4줄로 설정
        ),
      ],
    );
  }
}

// 메인 함수는 다른 부분에서 관리되므로 생략합니다.
