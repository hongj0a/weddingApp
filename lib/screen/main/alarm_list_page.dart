import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/main/setting.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/ApiConstants.dart';

class Alarm {
  final String title;
  final bool readYn;
  final String content;

  Alarm({required this.title, required this.readYn, required this.content});

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      title: json['title'], // API의 title에 해당하는 필드
      readYn: json['readYn'],
      content: json['content'],// API의 readYn에 해당하는 필드
    );
  }
}

class AlarmListPage extends StatelessWidget {

  Future<List<Alarm>> fetchAlarms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('accessToken');

    final response = await http.get(
      Uri.parse(ApiConstants.getAlarm),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData = json.decode(response.body);
      if (decodedData.containsKey('data') && decodedData['data']['alarms'] != null) {
        final alarms = decodedData['data']['alarms'] as List<dynamic>;

        return alarms.map((alarmData) => Alarm.fromJson(alarmData)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load alarms');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('알림',style: TextStyle(fontFamily: 'PretendardVariable')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Alarm>>(
        future: fetchAlarms(), // API 호출
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 로딩 중
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final alarms = snapshot.data!;
            return ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return ListTile(
                  dense: true,
                  leading: Image.asset(
                    'asset/img/heart_logo.png',
                    height: 20,
                    width: 20,
                  ),
                  title: Text(
                    alarm.title,
                    style: TextStyle(
                      fontFamily: 'PretendardVariable',fontWeight: alarm.readYn ? FontWeight.normal : FontWeight.bold, fontSize: 15
                    ),
                  ),
                  subtitle: Text(
                    alarm.content,
                    style: TextStyle(
                        fontFamily: 'PretendardVariable',fontWeight: alarm.readYn ? FontWeight.normal : FontWeight.bold, fontSize: 20
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No alarms available')); // 알림이 없을 때
          }
        },
      ),
    );
  }
}