// add_item_page.dart
import 'package:flutter/material.dart';

class AddBudgetPage extends StatefulWidget {
  @override
  _AddBudgetPageState createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends State<AddBudgetPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비용 입력'),
        actions: [
          TextButton(
            onPressed: () {
              // Implement delete functionality if needed
            },
            child: Text(
              '저장',
              //style: TextStyle(color: Colors.),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                //labelText: '청첩장 제작비',
              ),
            ),
            SizedBox(height: 16.0),

            SizedBox(height: 16.0),
            ListTile(
              title: Text('세부비용'),
              trailing: Text('날짜 선택'),
              onTap: () {
                // Implement date picker if needed
              },
            ),
            ListTile(
              title: Text('신랑 지출'),
              trailing: Text('메모를 남겨보세요(최대 50자)'),
              onTap: () {
                // Implement memo input if needed
              },
            ),
            ListTile(
              title: Text('신부 지출'),
              trailing: Text('메모를 남겨보세요(최대 50자)'),
              onTap: () {
                // Implement memo input if needed
              },
            ),
          ],
        ),
      ),
    );
  }
}
