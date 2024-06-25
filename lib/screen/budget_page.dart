import 'package:flutter/material.dart';

class BudgetPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Page'),
      ),
      body: Center(
        child: Text(
          'This is the budget page',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
