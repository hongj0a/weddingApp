import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/main/setting.dart';
import '../../config/ApiConstants.dart';
import '../../interceptor/api_service.dart';

class Alarm {
  final String title;
  final bool readYn;
  final String content;

  Alarm({required this.title, required this.readYn, required this.content});

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      title: json['title'],
      readYn: json['readYn'],
      content: json['content'],
    );
  }
}

class AlarmListPage extends StatelessWidget {
  ApiService apiService = ApiService();
  Future<List<Alarm>> fetchAlarms() async {
    final response = await apiService.get(
      ApiConstants.getAlarm,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> decodedData = response.data;
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
        title: Text('알림',style: TextStyle( )),
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
        future: fetchAlarms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
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
                    'asset/img/mini_logo.png',
                    height: 25,
                    width: 25,
                  ),
                  title: Text(
                    alarm.title,
                    style: TextStyle(
                       fontWeight: alarm.readYn ? FontWeight.normal : FontWeight.bold, fontSize: 15, fontFamily: 'Pretendard'
                    ),
                  ),
                  subtitle: Text(
                    alarm.content,
                    style: TextStyle(
                         fontWeight: alarm.readYn ? FontWeight.normal : FontWeight.bold, fontSize: 20, fontFamily: 'Pretendard'
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No alarms available'));
          }
        },
      ),
    );
  }
}