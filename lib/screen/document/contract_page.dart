import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/document/document_upload.dart';

class ContractPage extends StatefulWidget {
  @override
  _ContractPageState createState() => _ContractPageState();
}

class _ContractPageState extends State<ContractPage> {
  List<Map<String, String>> contracts = [
    {'title': '웨딩홀 계약서', 'subtitle': '로얄 파크 컨벤션'},
    {'title': '신혼여행 계약서', 'subtitle': '허니문 리조트'},
    {'title': '혼주 한복 계약서', 'subtitle': '예향 한복'},
    {'title': '예복 계약서', 'subtitle': '까사비토'},
  ];

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DocumentUploadPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildContractItem(BuildContext context, Map<String, String> contract, int index) {
    return Dismissible(
      key: Key(contract['title']!),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("삭제 확인"),
              content: Text("${contract['title']}를 삭제하시겠습니까?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("취소"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text("삭제"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        setState(() {
          contracts.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${contract['title']} 삭제됨')),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 3.0,
        margin: EdgeInsets.symmetric(vertical: 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          leading: Icon(Icons.description),
          title: Text(contract['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Row(
            children: [
              Icon(Icons.location_on, size: 16.0, color: Colors.red),
              SizedBox(width: 4.0),
              Text(contract['subtitle']!),
            ],
          ),
        ),
      ),
    );
  }
}
