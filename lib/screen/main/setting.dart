import 'package:flutter/material.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';
import '../../themes/theme.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isScheduleNotificationOn = false;
  bool isBudgetNotificationOn = false;
  bool isMarketingAgreementOn = false;
  bool isAwesomeMessagesOn = false;
  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchNotificationSettings();
  }

  Future<void> updateNotificationSetting(String key, bool value) async {
    var response = await apiService.post(
      ApiConstants.updateYnSetting,
      data: {
        "key": key,
        "value": value.toString(),
      },
    );

    if (response.statusCode == 200) {
      print('설정이 성공적으로 업데이트되었습니다.');
    } else {
      print('설정 업데이트 실패: ${response.statusCode}');
      print('reason... : ${response.data}');
    }
  }


  Future<void> _fetchNotificationSettings() async {

    try {
      var response = await apiService.get(
        ApiConstants.getYnList,
      );

      if (response.statusCode == 200) {
        var jsonResponse = response.data;
        var data = jsonResponse['data'];

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
                  activeColor: AppColors.primaryColor,
                  onChanged: (bool value) {
                    setState(() {
                      isScheduleNotificationOn = value;
                    });
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
                  activeColor: AppColors.primaryColor,
                  onChanged: (bool value) {
                    setState(() {
                      isBudgetNotificationOn = value;
                    });
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
                  activeColor: AppColors.primaryColor,
                  onChanged: (bool value) {
                    setState(() {
                      isMarketingAgreementOn = value;
                    });
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
                  '우월에서 보내는 소식',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isAwesomeMessagesOn,
                  activeColor: AppColors.primaryColor,
                  onChanged: (bool value) {
                    setState(() {
                      isAwesomeMessagesOn = value;
                    });
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
