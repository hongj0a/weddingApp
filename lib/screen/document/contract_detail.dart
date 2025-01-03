import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import '../../themes/theme.dart';

class ThousandsSeparatorFormatter extends TextInputFormatter {
  final _formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final intValue = int.tryParse(newText);
    final formattedText = _formatter.format(intValue);
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class ContractDetail extends StatefulWidget {
  final String? seq;
  final Map<String, String?>? contractInfo;
  final File? imageFile;

  ContractDetail({ this.seq,  this.contractInfo,  this.imageFile});

  @override
  _ContractDetailState createState() => _ContractDetailState();
}

class _ContractDetailState extends State<ContractDetail> {
  late TextEditingController _contractNameController;
  late TextEditingController _contractAmountController;
  late TextEditingController _totalAmountController;
  late TextEditingController _companyNameController;
  late TextEditingController _eventDateController;
  late TextEditingController _eventTimeController;
  ApiService apiService = ApiService();

  String? imageUrlWithFullPath;

  @override
  void initState() {
    print('widget.seq.....########### ${widget.seq}');

    super.initState();

    _contractNameController = TextEditingController();
    _contractAmountController = TextEditingController();
    _totalAmountController = TextEditingController();
    _companyNameController = TextEditingController();
    _eventDateController = TextEditingController();
    _eventTimeController = TextEditingController();

    if (widget.seq != null) {
      _fetchContractDetails();
    } else if (widget.contractInfo != null) {
      _initializeFromContractInfo(widget.contractInfo!);
    }
  }

  void _initializeFromContractInfo(Map<String, String?> info) {
    _contractNameController.text = info["ContractName"] ?? '';
    _contractAmountController.text = _formatNumberWithCommas(info["ContractAmount"] ?? '');
    _totalAmountController.text = _formatNumberWithCommas(info["TotalAmount"] ?? '');
    _companyNameController.text = info["CompanyName"] ?? '';
    _eventDateController.text = info["EventDate"] ?? '';
    _eventTimeController.text = info["EventTime"] ?? '';
  }

  Future<void> _fetchContractDetails() async {

    if (widget.seq == null) {
      return;
    } else {
      try{
        final response = await apiService.get(
          ApiConstants.getContractDetail,
          queryParameters: {'seq': widget.seq}
        );

        if (response.statusCode == 200) {
          final data = response.data;
          setState(() {
            _contractNameController.text = data['data']['name'];
            _contractAmountController.text = _formatNumberWithCommas(data['data']['contractAmount'].toString() ?? '');
            _totalAmountController.text = _formatNumberWithCommas(data['data']['totalAmount'].toString() ?? '');
            _companyNameController.text = data['data']['companyName'] ?? '';
            _eventDateController.text = data['data']['eventDate'] ?? '';
            _eventTimeController.text = data['data']['eventTime'] ?? '';
            imageUrlWithFullPath = data['data']['image'] ?? '';
            print('imageUrl.... $imageUrlWithFullPath}');
          });
        } else {
          print('response...message... ${response.data}');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('계약서 정보를 불러올 수 없습니다.')));
        }
      }catch(e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("에러 발생: $e")));
      }
    }
  }

  @override
  void dispose() {
    _contractNameController.dispose();
    _contractAmountController.dispose();
    _totalAmountController.dispose();
    _companyNameController.dispose();
    _eventDateController.dispose();
    _eventTimeController.dispose();
    super.dispose();
  }

  String _formatNumberWithCommas(String number) {
    if (number.isEmpty) return '';
    final formatter = NumberFormat('#,###');
    return formatter.format(int.tryParse(number.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0);
  }

  Future<void> _saveContractDetails() async {
    String contractName = _contractNameController.text;
    String contractAmount = _contractAmountController.text.replaceAll(',', '');
    String totalAmount = _totalAmountController.text.replaceAll(',', '');
    String companyName = _companyNameController.text;
    String eventDate = _eventDateController.text;
    String eventTime = _eventTimeController.text;

    if (contractName.isEmpty || contractAmount.isEmpty || totalAmount.isEmpty || companyName.isEmpty || eventDate.isEmpty || eventTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('모든 항목을 입력해 주세요.')));
      return;
    }

    if (!widget.imageFile!.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미지가 없습니다.')));
      return;
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      Uri predictUrl = Uri.parse(ApiConstants.predict); // 서버 URL로 변경

      var predictResponse = await http.post (
        predictUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'contract_name': contractName}),
      );

      if (predictResponse.statusCode == 200) {
        var predictData = jsonDecode(predictResponse.body);
        String predictedCategory = predictData['predicted_category'];

        bool? isCorrect = await _showConfirmationDialog(predictedCategory);

        if (isCorrect == true) {
          await _sendContractData(
            accessToken,
            contractName,
            contractAmount,
            totalAmount,
            companyName,
            eventDate,
            eventTime,
            predictedCategory,
          );
        } else {
          Map<String, dynamic>? result = await _showCategoryCorrectionDialog();
          if (result != null) {
            String? correctedCategory = result['category'];
            int? correctedIndex = result['index'];
            await _sendCategoryFeedback(
              accessToken,
              contractName,
              false,
              correctedIndex!,
            );

            await _sendContractData(
              accessToken,
              contractName,
              contractAmount,
              totalAmount,
              companyName,
              eventDate,
              eventTime,
              correctedCategory!,
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('예측 요청 실패: ${predictResponse.statusCode}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    }
  }

  Future<bool?> _showConfirmationDialog(String predictedCategory) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('추천 카테고리'),
          content: Text('예측된 카테고리: $predictedCategory\n이 카테고리가 맞습니까?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '아니요',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                '예',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendContractData(
      String? accessToken,
      String contractName,
      String contractAmount,
      String totalAmount,
      String companyName,
      String eventDate,
      String eventTime,
      String categoryName,
      ) async {
    Uri url = Uri.parse(ApiConstants.setContract);
    var request = http.MultipartRequest('POST', url);

    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    request.fields['name'] = contractName;
    request.fields['contractAmount'] = contractAmount;
    request.fields['totalAmount'] = totalAmount;
    request.fields['companyName'] = companyName;
    request.fields['eventDate'] = eventDate;
    request.fields['eventTime'] = eventTime;
    request.fields['categoryName'] = categoryName;

    var imageFile = await http.MultipartFile.fromPath(
      'image',
      widget.imageFile!.path,
      filename: path.basename(widget.imageFile!.path),
    );
    request.files.add(imageFile);

    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장되었습니다.')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('서버 오류: ${response.statusCode}')));
    }
  }

  Future<void> _sendCategoryFeedback(String? accessToken, String contractName, bool isCorrect, int correctedIndex) async {
    Uri feedbackUrl = Uri.parse(ApiConstants.predict);
    var response = await http.post (
      feedbackUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contract_name': contractName,
        'feedback': isCorrect,
        'true_category': correctedIndex,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('피드백이 성공적으로 전송되었습니다.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('피드백 전송 실패: ${response.statusCode}')));
    }
  }

  /*Future<String?> _showCategoryCorrectionDialog() async {
    List<String> categories = await _fetchCategories();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? selectedCategory;
        return AlertDialog(
          title: Text('카테고리 선택'),
          content: DropdownButtonFormField<String>(
            value: selectedCategory,
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              selectedCategory = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop(selectedCategory);
              },
            ),
          ],
        );
      },
    );
  }*/

  Future<Map<String, dynamic>?> _showCategoryCorrectionDialog() async {
    List<String> categories = await _fetchCategories();
    String? selectedCategory;
    int? selectedIndex;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('카테고리 선택'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          content: DropdownButtonFormField<String>(
            value: selectedCategory,
            hint: Text('선택하세요', style: TextStyle(color: Colors.grey)),
            dropdownColor: Colors.white,
            items: categories.asMap().entries.map((entry) {
              int index = entry.key;
              String category = entry.value;

              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              selectedCategory = value;
              selectedIndex = categories.indexOf(value!);
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: Text('취소'),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'category': selectedCategory,
                  'index': selectedIndex,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }


  Future<List<String>> _fetchCategories() async {
    var response = await apiService.get(
      ApiConstants.getCategories
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      final categoryList = jsonResponse['data']['categoryList'];
      return List<String>.from(categoryList.map((item) => item['name'] as String));
    } else {
      throw Exception('카테고리 목록을 가져오는데 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_eventDateController.text.isNotEmpty) {
      try {
        initialDate = DateFormat("yyyy-MM-dd").parse(_eventDateController.text);
      } catch (e) {
        initialDate = DateTime.now();
      }
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryColor,
            colorScheme: ColorScheme.light(primary: AppColors.primaryColor),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
            ),
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: Colors.black),
              bodyLarge: TextStyle(color: Colors.black),
              labelLarge: TextStyle(color: Colors.black),
            ),
          ),
          child: child ?? Container(),
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _eventDateController.text = DateFormat("yyyy-MM-dd").format(pickedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != TimeOfDay.now()) {
      final now = DateTime.now();
      final DateTime dateTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

      final String formattedTime = DateFormat('HH:mm').format(dateTime);

      _eventTimeController.text = formattedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('계약서 상세'),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        actions: [
          if (widget.seq == null)
          TextButton(
            onPressed: _saveContractDetails,
            child: Text(
              "저장",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.seq == null)
              RichText(
                text: TextSpan(
                  children: [
                    WidgetSpan(
                      child: Icon(
                        Icons.info,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: ' 추출된 텍스트는 등록된 사진을 기반으로 자동 인식된 결과입니다.\n'
                          '      잘못 인식된 부분이 있다면 수정 후 저장해 주세요.\n',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Builder(
                  builder: (context) {
                    if (widget.imageFile != null) {
                      return Image.file(widget.imageFile!);
                    }
                    if (imageUrlWithFullPath != null && imageUrlWithFullPath!.isNotEmpty) {
                      return Image.network(
                        imageUrlWithFullPath!,
                        errorBuilder: (context, error, stackTrace) {
                          print("이미지 로드 실패: $error");
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error, color: Colors.red),
                              Text("이미지를 불러오지 못했습니다."),
                            ],
                          );
                        },
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image_not_supported, color: Colors.grey),
                        Text("이미지가 없습니다."),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(height: 25),
              _buildTextField("계약서 이름", _contractNameController),
              _buildAmountField("계약금", _contractAmountController),
              _buildAmountField("총 금액", _totalAmountController),
              _buildTextField("회사명", _companyNameController),
              _buildDateField("행사 날짜", _eventDateController),
              _buildTimeField("행사 시간", _eventTimeController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primaryColor,
              width: 2.0,
            ),
          ),
        ),
        enabled: widget.seq == null,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: widget.seq == null ? () => _selectDate(context) : null,
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.primaryColor,
                  width: 2.0,
                ),
              ),
            ),
            enabled: widget.seq == null,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primaryColor,
              width: 2.0,
            ),
          ),
        ),
        enabled: widget.seq == null,
        style: TextStyle(
          color: Colors.black,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorFormatter(),
        ],
        onChanged: (text) {
          String rawValue = text.replaceAll(',', '');
        },
        keyboardType: TextInputType.numberWithOptions(decimal: false),
      ),
    );
  }

  Widget _buildTimeField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: widget.seq == null ? () => _selectTime(context) : null,
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.primaryColor,
                  width: 2.0,
                ),
              ),
            ),
            enabled: widget.seq == null,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

}
