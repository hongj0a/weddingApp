import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/ApiConstants.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isScheduleNotificationOn = false;
  bool isBudgetNotificationOn = false;
  bool isMarketingAgreementOn = false;
  bool isAwesomeMessagesOn = false;

  @override
  void initState() {
    super.initState();
    _fetchNotificationSettings();
  }

  Future<void> updateNotificationSetting(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    var url = Uri.parse(ApiConstants.updateYnSetting); // 업데이트할 API 엔드포인트
    var response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "key": key, // 문자열 "key"로 수정
        "value": value.toString(), // boolean 값을 문자열로 변환
      }),
    );

    if (response.statusCode == 200) {
      print('설정이 성공적으로 업데이트되었습니다.');
    } else {
      print('설정 업데이트 실패: ${response.statusCode}');
      print('reason... : ${response.body}');
    }
  }


  Future<void> _fetchNotificationSettings() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    try {
      var url = Uri.parse(ApiConstants.getYnList);

      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json', // JSON 형식의 데이터 전송
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        var data = jsonResponse['data']; // 'data' 부분을 따로 분리

        print('data ....... $data');
        print('data.scheduleYn ..... ${data['scheduleYn']}');
        print('data.marketingYn ..... ${data['marketingYn']}');

        setState(() {
          isScheduleNotificationOn = data['scheduleYn'] ?? false;
          isBudgetNotificationOn = data['budgetYn'] ?? false;
          isMarketingAgreementOn = data['marketingYn'] ?? false;
          isAwesomeMessagesOn = data['systemYn'] ?? false;
        });

        print('isMarketing..... $isMarketingAgreementOn');
        print('isScheduleNotificationOn..... $isScheduleNotificationOn');
      } else {
        // 에러 처리
        throw Exception('Failed to load notification settings');
      }
    } catch (e) {
      print('Error fetching settings: $e');
      // 기본값을 사용할 수 있음
      setState(() {
        isScheduleNotificationOn = false;
        isBudgetNotificationOn = false;
        isMarketingAgreementOn = false;
        isAwesomeMessagesOn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('알림 설정', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('서비스 알림', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '일정 알림',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isScheduleNotificationOn,
                  activeColor: Color.fromRGBO(250, 15, 156, 1.0),
                  onChanged: (bool value) {
                    setState(() {
                      isScheduleNotificationOn = value;
                    });
                    // 서버에 상태 변경 요청
                    updateNotificationSetting('scheduleYn', value);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '예산 알림',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isBudgetNotificationOn,
                  activeColor: Color.fromRGBO(250, 15, 156, 1.0),
                  onChanged: (bool value) {
                    setState(() {
                      isBudgetNotificationOn = value;
                    });
                    // 서버에 상태 변경 요청
                    updateNotificationSetting('budgetYn', value);
                  },
                ),
              ),
            ],
          ),
          Divider(thickness: 2, height: 32),
          SizedBox(height: 16),
          Text('혜택, 이벤트 및 기타 알림', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '마케팅 수신 동의',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isMarketingAgreementOn,
                  activeColor: Color.fromRGBO(250, 15, 156, 1.0),
                  onChanged: (bool value) {
                    setState(() {
                      isMarketingAgreementOn = value;
                    });
                    // 서버에 상태 변경 요청
                    updateNotificationSetting('marketingYn', value);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '엘리트웨딩에서 보내는 소식',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isAwesomeMessagesOn,
                  activeColor: Color.fromRGBO(250, 15, 156, 1.0),
                  onChanged: (bool value) {
                    setState(() {
                      isAwesomeMessagesOn = value;
                    });
                    // 서버에 상태 변경 요청
                    updateNotificationSetting('systemYn', value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
