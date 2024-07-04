import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isScheduleNotificationOn = true;
  bool isMarketingNotificationOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림 설정'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('서비스 알림', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: Text('일정 알림'),
            subtitle: Text('다가오는 일정 알림'),
            value: isScheduleNotificationOn,
            onChanged: (bool value) {
              setState(() {
                isScheduleNotificationOn = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('마케팅 알림'),
            subtitle: Text('마케팅 정보 수신 동의'),
            value: isMarketingNotificationOn,
            onChanged: (bool value) {
              setState(() {
                isMarketingNotificationOn = value;
              });
            },
          ),
          Divider(),
          Text('서비스 알림', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: Text('일정 알림'),
            subtitle: Text('다가오는 일정 알림'),
            value: isScheduleNotificationOn,
            onChanged: (bool value) {
              setState(() {
                isScheduleNotificationOn = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('마케팅 알림'),
            subtitle: Text('마케팅 정보 수신 동의'),
            value: isMarketingNotificationOn,
            onChanged: (bool value) {
              setState(() {
                isMarketingNotificationOn = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
