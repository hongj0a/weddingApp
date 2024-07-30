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
                '{총예산}',
                style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.grey,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: budgetItems.length,
                        itemBuilder: (context, index) {
                          final item = budgetItems[index];
                          return Dismissible(
                            key: Key(item['label']!),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("삭제 확인"),
                                    content: Text("${item['label']}을 삭제하시겠습니까?"),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text("취소"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text("삭제"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onDismissed: (direction) {
                              setState(() {
                                _controllers.remove(item['label']);
                                _focusNodes.remove(item['label']);
                                budgetItems.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${item['label']} 삭제됨')),
                              );
                            },
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Card(
                              child: ListTile(
                                title: Text(item['label'] ?? ''),
                                trailing: SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                    controller: _controllers[item['label']!],
                                    focusNode: _focusNodes[item['label']!],
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.end,
                                    onTap: () {
                                      _focusNodes[item['label']!]!.requestFocus();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity, // ListTile의 너비에 맞게 설정
                        child: ElevatedButton(
                          onPressed: _showAddItemDialog,
                          child: Text('추가하기'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('예산 항목 추가'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: '항목명을 입력하세요'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('추가'),
              onPressed: () {
                setState(() {
                  String newItemLabel = controller.text.trim();
                  budgetItems.add({'label': newItemLabel, 'amount': ''});
                  _controllers[newItemLabel] = TextEditingController(text: '원');
                  _focusNodes[newItemLabel] = FocusNode();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
