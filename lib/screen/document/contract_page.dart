import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/document/document_upload.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../config/ApiConstants.dart';

class ContractPage extends StatefulWidget {
  @override
  _ContractPageState createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  List<Map<String, String>> contracts = [];

  @override
  void initState() {
    super.initState();
    getContracts(); // API 호출하여 contracts 업데이트
  }

  Future<void> getContracts() async {

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      var url = Uri.parse(ApiConstants.getContract);

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        }
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']['contracts']; // 서버의 데이터 형식에 맞게 수정
        setState(() {
          contracts = [
            for (var item in data)
              {
                'seq': item['seq'].toString(),
                'title': item['name'],
                'subtitle': item['companyName'],
              }
          ];
        });
      } else {
        // 에러 처리 (예: 토스트 메시지 표시)
        print('Failed to load contracts');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteContract(String seq) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');
      var url = Uri.parse('${ApiConstants.delContract}?seq=$seq');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        print('Contract deleted successfully');
      } else {
        print('Failed to delete contract');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          return _buildContractItem(context, contracts[index], index);
        },
      ),
      floatingActionButton: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(30.0),
        child: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DocumentUploadPage()),
            );
          },
          child: Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildContractItem(BuildContext context, Map<String, String> contract, int index) {
    return Dismissible(
      key: Key(contract['seq']!),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                "삭제 확인",
                style: TextStyle(color: Colors.black), // 제목 글씨 검정색
              ),
              content: Text(
                "${contract['title']}를 삭제하시겠습니까?",
                style: TextStyle(color: Colors.black), // 내용 글씨 검정색
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    "취소",
                    style: TextStyle(color: Colors.black), // 버튼 글씨 검정색
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    "삭제",
                    style: TextStyle(color: Colors.black), // 버튼 글씨 검정색
                  ),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async{
        String seq = contract['seq']!;
        await deleteContract(seq);
        setState(() {
          contracts.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${contract['title']}, 삭제 되었습니다.')),
        );
      },
      background: Container(
        color: Color.fromRGBO(250, 15, 156, 1.0),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Icon(Icons.description),
          title: Text(contract['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Row(
            children: [
              Icon(Icons.location_on, size: 16.0, color: Color.fromRGBO(250, 15, 156, 1.0)),
              SizedBox(width: 4.0),
              Text(contract['subtitle']!),
            ],
          ),
        ),
      ),
    );
  }
}
