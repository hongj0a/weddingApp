import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
      ),
      body: Center(
        child: Text(
          'This is the My page',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
