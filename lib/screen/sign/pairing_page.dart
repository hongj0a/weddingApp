import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_wedding/screen/sign/login_page.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:http/http.dart' as http;
import '../../config/ApiConstants.dart';
import '../../themes/theme.dart';
import '../main/home_screen.dart';

class PairingCodePage extends StatefulWidget {
  final String id;

  PairingCodePage({required this.id});

  @override
  _PairingCodePageState createState() => _PairingCodePageState();
}

class _PairingCodePageState extends State<PairingCodePage> {
  String pairingCode = '';
  String enteredPairingCode = '';
  late StompClient stompClient;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePairing();
  }

  void _initializePairing() async {
    await _setPairingCode();
    _connectToWebSocket();
  }

  Future<void> _setPairingCode() async {
    pairingCode = await _generateRandomCode();
    setState(() {});
  }

  Future<String> _generateRandomCode() async {
    final random = Random();

    while (true) {
      int code = random.nextInt(900000) + 100000;
      String codeString = code.toString();

      print("Generated Code: $codeString");

      final response = await http.get(Uri.parse('${ApiConstants.isExistPairingCode}?code=$codeString'));

      if (response.statusCode == 200) {
        print("Server Response: ${response.body}");

        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['code'] == 'OK') {
          return codeString;
        }
      }
      print("Code $codeString is not valid, retrying...");
    }
  }

  void _connectToWebSocket() {
    stompClient = StompClient(
      config: StompConfig(
        url: ApiConstants.webSocketUrl,
        onConnect: (StompFrame frame) {
          _sendPairingRequest(pairingCode);

          stompClient.subscribe(
            destination: '/sub',
            callback: (frame) {
              String? message = frame.body;

              if (message != null && message.startsWith("FAIL")) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: Text('ERROR', style: TextStyle(color: Colors.black)),
                      content: Text('초대코드가 잘못되었어요. \n 확인 후 다시 입력해주세요.', style: TextStyle(color: Colors.black)),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('확인', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    );
                  },
                );
              } else if (message != null && message.startsWith("COMPLETE")) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WeddingHomePage()),
                );
              } else {
                print('서버에서 받은 메시지: $message');
              }
            },
          );
        },
        onWebSocketError: (dynamic error) => print('WebSocket 에러: $error, ${ApiConstants.webSocketUrl}'),
      ),
    );

    stompClient.activate();
  }

  void _sendPairingRequest(String pairingCode) {
    final pairingRequest = {
      'pairingCode': pairingCode,
      'email': widget.id,
    };
    print('페어링 요청 전송: $pairingRequest');
    stompClient.send(
      destination: '/app/requestPairing',
      body: jsonEncode(pairingRequest),
    );
  }

  void _sendPairingComplete(String pairingCode) {
    final pairingResponse = {
      'pairingCode': pairingCode,
      'email': widget.id,
    };
    print('페어링 완료 요청 전송: $pairingResponse');

    stompClient.send(
      destination: '/app/pairingComplete',
      body: jsonEncode(pairingResponse),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('초대 코드 입력'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text(
                '서로의 초대코드를 입력하여 연결해 주세요.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('내 초대코드'),
              Text(
                pairingCode,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: '또는 전달받은 초대코드 입력',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primaryColor),
                  ),
                ),
                onChanged: (value) {
                  enteredPairingCode = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (enteredPairingCode.isNotEmpty) {
                    if (enteredPairingCode == pairingCode) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            title: Text('확인 요청', style: TextStyle(color: Colors.black)),
                            content: Text(
                              '자기 자신과 페어링은 할 수 없어요. \n상대방의 페어링 코드를 입력해주세요.',
                              style: TextStyle(color: Colors.black),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('확인', style: TextStyle(color: Colors.black)),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      _sendPairingComplete(enteredPairingCode);
                    }
                  } else {
                    print('초대 코드를 입력해주세요');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text('확인 요청', style: TextStyle(color: Colors.black)),
                          content: Text(
                            '초대 코드를 입력해주세요.',
                            style: TextStyle(color: Colors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('확인', style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text(
                  '연결하기',
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey),
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
              SizedBox(height: 30),
              Text(
                '초대 코드를 입력하면 파트너와 웨딩 예산 계획을 공유하고 관리할 수 있습니다.\n원활한 서비스 이용을 위해 페어링 등록이 필요합니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              SizedBox(height: 50),
              TextButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();

                  await prefs.remove('accessToken');
                  await prefs.remove('refreshToken');

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text(
                  '돌아가기',
                  style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    stompClient.deactivate();
    super.dispose();
  }
}
