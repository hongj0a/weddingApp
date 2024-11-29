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

// 세자리마다 콤마를 추가하는 Formatter
class ThousandsSeparatorFormatter extends TextInputFormatter {
  final _formatter = NumberFormat('#,###');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // 입력 값에서 숫자만 남기고 콤마 추가
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }
    // 숫자로 변환 후 콤마 추가
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
  String imageUrl = '${ApiConstants.localImagePath}/';

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
      // seq가 있을 경우 서버에서 데이터를 가져옴
      _fetchContractDetails();
    } else if (widget.contractInfo != null) {
      // contractInfo가 있으면 초기화
      _initializeFromContractInfo(widget.contractInfo!);
    }
  }

  // contractInfo 초기화
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
      return; // seq가 null이면 아무 것도 하지 않음
    } else {
      try{
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? accessToken = prefs.getString('accessToken');

        final response = await apiService.get(
          ApiConstants.getContractDetail,
          queryParameters: {'seq': widget.seq}
        );

        if (response.statusCode == 200) {
          // 데이터가 성공적으로 받아졌을 때 컨트롤러에 초기화
          final data = response.data;
          setState(() {

            _contractNameController.text = data['data']['name'];
            _contractAmountController.text = _formatNumberWithCommas(data['data']['contractAmount'].toString() ?? '');
            _totalAmountController.text = _formatNumberWithCommas(data['data']['totalAmount'].toString() ?? '');
            _companyNameController.text = data['data']['companyName'] ?? '';
            _eventDateController.text = data['data']['eventDate'] ?? '';
            _eventTimeController.text = data['data']['eventTime'] ?? '';
            imageUrlWithFullPath = imageUrl + (data['data']['image'] ?? '');
            print('imageUrl.... $imageUrlWithFullPath}');// 이미지 URL이 null일 경우 빈 문자열 처리
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

  // 숫자에 세자리마다 콤마 추가
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
      // 1. 예측 요청
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

        // 2. 예측 카테고리 확인
        bool? isCorrect = await _showConfirmationDialog(predictedCategory);

        if (isCorrect == true) {
          // 3. 예측 결과가 올바르다고 확인 -> 계약 정보 저장
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
          // 4. 예측 결과가 틀림 -> 카테고리 수정 다이얼로그 표시
          Map<String, dynamic>? result = await _showCategoryCorrectionDialog();
          if (result != null) {
            String? correctedCategory = result['category'];
            int? correctedIndex = result['index'];
            // 수정된 카테고리와 예측 결과가 틀렸다는 피드백 전송
            await _sendCategoryFeedback(
              accessToken,        // 액세스 토큰
              contractName,       // 계약 이름
              false,              // 예측이 틀렸다는 값
              correctedIndex!,  // 수정된 카테고리
            );

            // 5. 카테고리 수정 후 계약서 내용도 저장
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
// 사용자에게 예측 결과를 확인하는 다이얼로그를 표시
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
            borderRadius: BorderRadius.circular(4), // 직각 모서리 (둥근 부분을 4로 설정)
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '아니요',
                style: TextStyle(
                  color: Colors.black, // 텍스트 색상
                  fontWeight: FontWeight.bold, // 텍스트 두께
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false); // 틀렸다고 답변
              },
            ),
            SizedBox(width: 8), // 버튼 간 간격
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 맞다고 답변
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor, // 버튼 배경색
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // 직각 모서리
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), // 버튼 내부 패딩
              ),
              child: Text(
                '예',
                style: TextStyle(
                  color: Colors.white, // 텍스트 색상
                  fontWeight: FontWeight.bold, // 텍스트 두께
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// 계약 정보 저장 요청
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

// 예측 결과 피드백 전송
  Future<void> _sendCategoryFeedback(String? accessToken, String contractName, bool isCorrect, int correctedIndex) async {
    Uri feedbackUrl = Uri.parse(ApiConstants.predict);
    var response = await http.post (
      feedbackUrl,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contract_name': contractName,    // 계약 이름 웨딩홀 계약서
        'feedback': isCorrect,           // 예측이 맞았는지 여부
        'true_category': correctedIndex, // 실제 맞는 카테고리
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
            borderRadius: BorderRadius.circular(4), // 직각 모서리
          ),
          content: DropdownButtonFormField<String>(
            value: selectedCategory,
            hint: Text('선택하세요', style: TextStyle(color: Colors.grey)),
            dropdownColor: Colors.white, // 드롭다운 배경색을 흰색으로 설정// 힌트 텍스트
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
                Navigator.of(context).pop(null); // 취소 버튼
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // 텍스트 색상
              ),
              child: Text('취소'),
            ),
            SizedBox(width: 8), // 버튼 간 간격
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'category': selectedCategory,
                  'index': selectedIndex,
                }); // 수정된 카테고리와 인덱스를 반환
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor, // 버튼 배경색
                foregroundColor: Colors.white, // 텍스트 색상
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // 직각 모서리
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



// 서버에서 카테고리 데이터 가져오기
  Future<List<String>> _fetchCategories() async {
    var response = await apiService.get(
      ApiConstants.getCategories
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      final categoryList = jsonResponse['data']['categoryList'];
      // name 키로부터 리스트 생성
      return List<String>.from(categoryList.map((item) => item['name'] as String));
    } else {
      throw Exception('카테고리 목록을 가져오는데 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }

  // 날짜 선택기 표시 함수
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_eventDateController.text.isNotEmpty) {
      try {
        initialDate = DateFormat("yyyy-MM-dd").parse(_eventDateController.text);
      } catch (e) {
        // 날짜 포맷이 잘못되었으면 현재 날짜로 초기화
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
            primaryColor: AppColors.primaryColor, // 선택된 색상
            colorScheme: ColorScheme.light(primary: AppColors.primaryColor), // 주요 색상
            dialogBackgroundColor: Colors.white, // 배경 색상
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // 버튼 텍스트 색상 (primary 대신 foregroundColor 사용)
              ),
            ),
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: Colors.black), // 일반 텍스트 색상 (bodyText1 대신 bodyMedium 사용)
              bodyLarge: TextStyle(color: Colors.black), // 일반 텍스트 색상 (bodyText2 대신 bodyLarge 사용)
              labelLarge: TextStyle(color: Colors.black), // 버튼 텍스트 색상 (button 대신 labelLarge 사용)
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
      initialTime: TimeOfDay.now(),  // 기본 시간은 현재 시간
    );

    if (picked != null && picked != TimeOfDay.now()) {
      final now = DateTime.now();
      final DateTime dateTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

      // 24-hour 형식으로 시간 포맷
      final String formattedTime = DateFormat('HH:mm').format(dateTime);

      // 텍스트 필드에 포맷된 시간 설정
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
            onPressed: _saveContractDetails,  // 저장 버튼 클릭 시 저장 함수 호출
            child: Text(
              "저장",
              style: TextStyle(color: Colors.black),  // 텍스트 색상 설정
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
                    // 파일이 존재하면 로컬 이미지 사용
                    if (widget.imageFile != null) {
                      return Image.file(widget.imageFile!);
                    }
                    // URL이 유효하면 네트워크 이미지 사용
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
                    // 둘 다 없는 경우 기본 메시지 출력
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
              color: AppColors.primaryColor, // 활성화된 TextField의 테두리 색상
              width: 2.0,
            ),
          ),
        ),
        enabled: widget.seq == null,
        style: TextStyle(
          color: Colors.black, // 텍스트 색상 항상 검정색으로 설정
        ),
      ),
    );
  }

  // 날짜 필드를 만드는 함수
  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: widget.seq == null ? () => _selectDate(context) : null,  // 날짜 선택기 띄우기
        child: AbsorbPointer(  // 텍스트 필드를 클릭할 때 키보드가 뜨지 않도록
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
              color: Colors.black, // 텍스트 색상 항상 검정색으로 설정
            ),
          ),
        ),
      ),
    );
  }

  // 금액 관련 텍스트 필드를 만드는 함수
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
              color: AppColors.primaryColor, // 활성화된 TextField의 테두리 색상
              width: 2.0,
            ),
          ),
        ),
        enabled: widget.seq == null,
        style: TextStyle(
          color: Colors.black, // 텍스트 색상 항상 검정색으로 설정
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,  // 숫자만 입력 가능
          ThousandsSeparatorFormatter(),  // 세자리마다 콤마 추가
        ],
        onChanged: (text) {
          // 콤마 없이 숫자만 서버로 전달
          String rawValue = text.replaceAll(',', '');
          // 여기서 서버로 rawValue를 전송하면 됩니다
        },
        keyboardType: TextInputType.numberWithOptions(decimal: false),  // 소수점 없이 숫자만 입력
      ),
    );
  }

  // 행사 시간 입력받는 필드 구현
  Widget _buildTimeField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: widget.seq == null ? () => _selectTime(context) : null,  // seq가 null일 때만 시간 선택기 실행
        child: AbsorbPointer(  // 텍스트 필드를 클릭할 때 키보드가 뜨지 않도록
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
            enabled: widget.seq == null,  // seq가 null일 때만 수정 가능
            style: TextStyle(
              color: Colors.black, // 텍스트 색상 항상 검정색으로 설정
            ),
          ),
        ),
      ),
    );
  }

}
