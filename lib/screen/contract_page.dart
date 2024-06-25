import 'package:flutter/material.dart';

class ContractPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contract Page'),
      ),
      body: Center(
        child: Text(
          'This is the Contract page',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
    );
  }
}
