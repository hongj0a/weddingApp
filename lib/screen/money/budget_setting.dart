import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/ApiConstants.dart';
import 'dart:async';

import '../../interceptor/api_service.dart';

class BudgetSetting extends StatefulWidget {
  @override
  _BudgetSettingState createState() => _BudgetSettingState();
}

class BudgetDto {
  String label;
  String amount;

  BudgetDto({required this.label, required this.amount});

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'amount': amount,
    };
  }
}

String totalAmount = '0';
Timer? _debounce;

class _BudgetSettingState extends State<BudgetSetting> {
  final List<Map<String, String>> budgetItems = [
    {'label': '상견례', 'amount': '0'},
    {'label': '예식장', 'amount': '0'},
    {'label': '허니문', 'amount': '0'},
    {'label': '스드메', 'amount': '0'},
    {'label': '예단', 'amount': '0'},
    {'label': '예물', 'amount': '0'},
    {'label': '한복/예복', 'amount': '0'},
    {'label': '헬스케어', 'amount': '0'},
    {'label': '인테리어', 'amount': '0'},
    {'label': '혼수', 'amount': '0'},
    {'label': '청첩장', 'amount': '0'},
    {'label': '막바지준비', 'amount': '0'},
  ];

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, TextEditingController> _labelControllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeBudgetData();
    for (var item in budgetItems) {
      final amount = item['amount'] ?? '0';
      _controllers[item['label']!] = TextEditingController(text: amount != '0' ? _formatCurrency(amount) : ''); // 기본값을 빈 문자열로 설정
      _labelControllers[item['label']!] = TextEditingController(text: item['label']!);
      _focusNodes[item['label']!] = FocusNode();
    }
  }


  Future<void> _initializeBudgetData() async {
    try {
      final response = await apiService.get(
          ApiConstants.getBudget,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = response.data;

        if (decodedData.containsKey('data') &&
            decodedData['data']['budgets'] != null) {
          final budgets = decodedData['data']['budgets'] as List<dynamic>;

          totalAmount = decodedData['data']['totalAmount']?.toString() ?? '0';

          if (budgets.isEmpty) {
            setState(() {
              budgetItems.clear();
              budgetItems.addAll([
                {'label': '상견례', 'amount': '0'},
                {'label': '예식장', 'amount': '0'},
                {'label': '허니문', 'amount': '0'},
                {'label': '스드메', 'amount': '0'},
                {'label': '예단', 'amount': '0'},
                {'label': '예물', 'amount': '0'},
                {'label': '한복/예복', 'amount': '0'},
                {'label': '헬스케어', 'amount': '0'},
                {'label': '인테리어', 'amount': '0'},
                {'label': '혼수', 'amount': '0'},
                {'label': '청첩장', 'amount': '0'},
                {'label': '막바지준비', 'amount': '0'},
              ]);
            });
            await _initBudgetOnServer();
            _initializeBudgetData();
          } else {
            setState(() {
              print("Before clear: $budgetItems");
              budgetItems.clear();
              print("After clear: $budgetItems");
              budgetItems.addAll(budgets.map((item) {
                return {
                  'seq': item['seq']?.toString() ?? '',
                  'label': item['title'] as String,
                  'amount': item['budget']?.toString() ?? '0',
                };
              }));
            });
          }
        }
      }

      for (var item in budgetItems) {
        final amount = item['amount'] ?? '0';
        _controllers[item['label']!] =
            TextEditingController(text: amount != '0' ? _formatCurrency(amount) : ''); // 기본값을 빈 문자열로 설정
        _labelControllers[item['label']!] =
            TextEditingController(text: item['label']!);
        _focusNodes[item['label']!] = FocusNode();
      }
    } catch (e) {
      print("Error loading budget data: $e");
    }
  }

  String _formatCurrency(String amount) {
    final number = int.tryParse(amount.replaceAll(',', '')) ?? 0;
    return NumberFormat('#,###').format(number);
  }

  Future<void> _initBudgetOnServer() async {
    try {
      final List<BudgetDto> budgetData = budgetItems.map((item) {
        return BudgetDto(
          label: item['label'] as String,
          amount: item['amount'] as String,
        );
      }).toList();

      final List<Map<String, dynamic>> jsonData = budgetData.map((item) => item.toJson()).toList();

      print('budgetdata... $jsonData');

      final response = await apiService.post(
        ApiConstants.initBudgets,
        data: jsonData,
      );

      if (response.statusCode == 200) {
        print("Initial budget saved successfully.");
      } else {
        print("Failed to save initial budget: ${response.statusCode}");
        print("Failed message ... : ${response.data}");
      }
    } catch (e) {
      print("Error initializing budget on server: $e");
    }
  }

  Future<void> _saveBudgetToServer(String label) async {
    try {
      final response = await apiService.post(
        ApiConstants.setBudget,
        data: {'label': label, 'amount': '0'},
      );

      if (response.statusCode == 200) {
        print("Budget item saved successfully.");

        final jsonResponse = json.decode(response.data);
        var data = jsonResponse['data'];
        var seq = data['seq'];

        return seq;

      } else {
        print("Failed to save budget item: ${response.statusCode}");
        print("Failed message ... : ${response.data}");
        return null;
      }
    } catch (e) {
      print("Error saving budget item to server: $e");
    }
  }

  Future<void> _updateBudgetOnServer(String seq, String label, String amount) async {
    try {
      final response = await apiService.post(
        ApiConstants.updateBudget,
        data: {
          'seq': seq,
          'label': label,
          'amount': amount,
        },
      );

      if (response.statusCode == 200) {
        print("Budget item updated successfully.");
      } else {
        print("Failed to update budget item: ${response.statusCode}");
        print("Failed message ... : ${response.data}");
      }
    } catch (e) {
      print("Error updating budget item on server: $e");
    }
  }

  void _onDismissed(int seq) async {
    try {
      final response = await apiService.get(
        ApiConstants.delBudget,
        queryParameters: {'seq': seq},
      );

      if (response.statusCode == 200) {
        print("Budget item removed successfully.");
      } else {
        print('Failed to delete budget item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while deleting budget item: $e');
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var labelController in _labelControllers.values) {
      labelController.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    _debounce?.cancel();
    super.dispose();
  }

  void _unfocusAllFields() {
    for (var focusNode in _focusNodes.values) {
      focusNode.unfocus();
    }
  }

  void _onAmountChanged(String value, String seq, String label, Map<String, String> item) {
    String formattedValue = _formatCurrency(value);

    setState(() {
      if (_controllers[item['label'] ?? ''] != null) {
        if (value.isEmpty) {
          _controllers[item['label'] ?? '']?.text = '';
        } else {
          _controllers[item['label'] ?? '']?.text = formattedValue;
          _controllers[item['label'] ?? '']?.selection = TextSelection.fromPosition(
            TextPosition(offset: formattedValue.length),
          );
        }
        item['amount'] = value.isNotEmpty ? value.replaceAll(',', '') : '0';
      }
    });

    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      await _updateBudgetOnServer(seq, label, item['amount']!);
      await _initializeBudgetData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('예산 설정'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          _unfocusAllFields();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${_formatCurrency(totalAmount)} 원',
                    style: TextStyle(
                      fontSize: 28.0,
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey.shade300),
                SizedBox(height: 16),
                Column(
                  children: budgetItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return Dismissible(
                      key: Key(item['seq']?.toString() ?? 'default_key_$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        final seqString = item['seq'] as String?;
                        if (seqString != null) {
                          final seq = int.tryParse(seqString) ?? 0;
                          _onDismissed(seq);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${item['label']} 항목이 삭제되었습니다.')),
                          );
                        } else {
                          print('seq is null for item: $item');
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 1.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _labelControllers[item['label']!],
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: TextStyle(fontSize: 20),
                                onFieldSubmitted: (newValue) {
                                  setState(() {
                                    item['label'] = newValue;
                                  });
                                  _updateBudgetOnServer(item['seq']!, newValue, item['amount']!);
                                },
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: item['label'] != null && _controllers.containsKey(item['label']!)
                                          ? _controllers[item['label']!]
                                          : TextEditingController(),
                                      onChanged: (value) {
                                        if (item['seq'] != null && item['label'] != null) {
                                          _onAmountChanged(value, item['seq']!, item['label']!, item);
                                        } else {
                                          print('Error: item[seq] or item[label] is null');
                                        }
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '0',
                                        hintStyle: TextStyle(color: Colors.grey),
                                      ),
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text('원', style: TextStyle(fontSize: 20)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showAddItemDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: Text('추가하기'),
                  ),
                ),
              ],
            ),
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
          title: Text(
            '예산 항목 추가',
            style: TextStyle(color: Colors.black),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: '항목명을 입력하세요',
              hintStyle: TextStyle(color: Colors.black),
            ),
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
              child: Text(
                '취소',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                '추가',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () async {
                String newItemLabel = controller.text.trim();
                if (newItemLabel.isNotEmpty) {
                  setState(() {
                    budgetItems.add({'label': newItemLabel, 'amount': '0'});
                    _controllers[newItemLabel] = TextEditingController();
                    _labelControllers[newItemLabel] = TextEditingController(text: newItemLabel);
                    _focusNodes[newItemLabel] = FocusNode();
                  });

                  await _saveBudgetToServer(newItemLabel);
                }
                _initializeBudgetData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


}