import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FindAccountScreen(),
    );
  }
}

class FindAccountScreen extends StatefulWidget {
  @override
  _FindAccountScreenState createState() => _FindAccountScreenState();
}

class _FindAccountScreenState extends State<FindAccountScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('아이디 / 비밀번호 찾기'),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(text: '아이디 찾기'),
              Tab(text: '비밀번호 찾기'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFindIdTab(),
                _buildFindPasswordTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFindIdTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: '휴대폰번호 입력',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: 140, // Set the width you want
              child: ElevatedButton(
                onPressed: () {
                  // 인증번호 전송 동작
                },
                child: Text('인증번호 전송'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  side: BorderSide(color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: '확인',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: 140, // Set the same width as above
              child: ElevatedButton(
                onPressed: () {
                  // 확인 동작
                },
                child: Text('확인'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  side: BorderSide(color: Colors.orange),
                ),
              ),
            ),
          ],
        ),

      ],
    );
  }

  Widget _buildFindPasswordTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: '휴대폰번호 입력',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: 140, // Set the width you want
              child: ElevatedButton(
                onPressed: () {
                  // 인증번호 전송 동작
                },
                child: Text('인증번호 전송'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  side: BorderSide(color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: '확인',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 10),
            SizedBox(
              width: 140, // Set the same width as above
              child: ElevatedButton(
                onPressed: () {
                  // 확인 동작
                },
                child: Text('확인'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  side: BorderSide(color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
