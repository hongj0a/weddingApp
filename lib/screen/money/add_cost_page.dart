import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import '../../themes/theme.dart';

class AddCostPage extends StatefulWidget {
  final int? categorySeq;
  final ApiService apiService = ApiService();
  AddCostPage({Key? key, this.categorySeq}) : super(key: key);

  @override
  _AddCostPageState createState() => _AddCostPageState();
}

class _AddCostPageState extends State<AddCostPage> {
  final ApiService apiServer = ApiService();
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
    print('카테고리 시퀀스: ${widget.categorySeq}');
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
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1),
        ),
      ),
      keyboardType: isCost ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      textInputAction: TextInputAction.done,
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
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
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1),
            ),
          ),
          maxLength: 100,
          maxLines: 4,
        ),
      ],
    );
  }

  void saveCostItem() async {
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
      print('data... $data');
      var response = await apiServer.post(
        ApiConstants.setChecklist,
        data: data,
      );
      print('response....msg ... ${response.data}');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("저장되었습니다.")));
        Navigator.pop(context, true);
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
    String newText = newValue.text.replaceAll(',', '');

    if (newText.isEmpty) return newValue;

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