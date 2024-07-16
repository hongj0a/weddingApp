import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/main/setting.dart';

class AlarmListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림'),
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
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.asset(
              'asset/img/ring.png',
              height: 30,
              width: 30,
            ),
            title: Text('{본식당일}이 D-100일 앞으로 다가왔어요!'),
            subtitle: Text('D-100 체크리스트를 확인해보세요.'),
          );
        },
      ),
    );
  }
}
