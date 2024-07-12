import 'package:flutter/material.dart';

class BudgetSetting extends StatefulWidget {
  @override
  _BudgetSettingState createState() => _BudgetSettingState();
}

class _BudgetSettingState extends State<BudgetSetting> {
  final List<Map<String, String>> budgetItems = [
    {'label': '상견례', 'amount': '475,918'},
    {'label': '예식장', 'amount': ''},
    {'label': '허니문', 'amount': ''},
    {'label': '스드메', 'amount': ''},
    {'label': '예단', 'amount': ''},
    {'label': '예물', 'amount': ''},
    {'label': '한복/예복', 'amount': ''},
    {'label': '헬스케어', 'amount': ''},
    {'label': '인테리어', 'amount': ''},
    {'label': '혼수', 'amount': ''},
    {'label': '청첩장', 'amount': ''},
    {'label': '막바지준비', 'amount': ''},
  ];

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    for (var item in budgetItems) {
      final amount = item['amount'] ?? ''; // null 체크
      _controllers[item['label']!] = TextEditingController(text: '$amount원');
      _focusNodes[item['label']!] = FocusNode();
    }
  }


  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _unfocusAllFields() {
    for (var focusNode in _focusNodes.values) {
      focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('예산 설정'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          _unfocusAllFields();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '총예산',
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: budgetItems.length,
                  itemBuilder: (context, index) {
                    final item = budgetItems[index];
                    return Card(
                      child: ListTile(
                        title: Text(item['label'] ?? ''),
                        trailing: SizedBox(
                          width: 100,
                          child: TextFormField(
                            controller: _controllers[item['label']],
                            focusNode: _focusNodes[item['label']],
                            decoration: InputDecoration(
                                border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.end,
                            onTap: () {
                              _focusNodes[item['label']]!.requestFocus();
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}