import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:http/http.dart' as http;

import '../../config/ApiConstants.dart';
import '../main/home_screen.dart';

class PairingCodePage extends StatefulWidget {
  final String id;  // 카카오톡 ID를 받을 필드 추가

  PairingCodePage({required this.id});  // 생성자에 파라미터 추가

  @override
  _PairingCodePageState createState() => _PairingCodePageState();
}

class _PairingCodePageState extends State<PairingCodePage> {
  String pairingCode = '';
  String enteredPairingCode = '';
  late StompClient stompClient;  // STOMP 클라이언트
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('카카오톡 ID: ${widget.id}');
    _initializePairing();  // 페어링 코드 생성과 WebSocket 연결 처리
  }

  void _initializePairing() async {
    await _setPairingCode();  // 페어링 코드를 먼저 설정 (비동기)
    _connectToWebSocket();    // 페어링 코드 설정 후 WebSocket 연결
  }

  Future<void> _setPairingCode() async {
    pairingCode = await _generateRandomCode();  // 비동기 함수로 랜덤 코드 설정
    setState(() {});  // 상태를 갱신하여 UI 업데이트
  }

  Future<String> _generateRandomCode() async {
    final random = Random();

    while (true) {
      int code = random.nextInt(900000) + 100000;
      String codeString = code.toString();

      print("Generated Code: $codeString");

      // 서버에 페어링 코드 확인 요청
      final response = await http.get(Uri.parse('${ApiConstants.isExistPairingCode}?code=$codeString'));

      if (response.statusCode == 200) {
        print("Server Response: ${response.body}");

        // 서버로부터 받은 응답이 "ok"일 경우 코드를 반환
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['code'] == 'OK') {
          return codeString;
        }
      }

      // "ok"가 아닐 경우 새로운 코드를 생성하여 다시 시도
      print("Code $codeString is not valid, retrying...");
    }
  }

  // WebSocket 연결 함수
  void _connectToWebSocket() {
    stompClient = StompClient(
      config: StompConfig(
        url: ApiConstants.webSocketUrl,
        onConnect: (StompFrame frame) {
          print('WebSocket 연결 성공');
          _sendPairingRequest(pairingCode); // 페어링 요청 전송

          // 서버에서 클라이언트에게 메시지 수신 구독
          stompClient.subscribe(
            destination: '/sub', // 서버에서 보내는 메시지의 경로
            callback: (frame) {
              String? message = frame.body;

              // 메시지가 "FAIL"로 시작하는 경우
              if (message != null && message.startsWith("FAIL")) {
                // 초대코드가 잘못되었음을 알리는 alert
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('ERROR'),
                      content: Text('초대코드가 잘못되었습니다. \n 확인 후 다시 입력해주세요.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // 다이얼로그 닫기
                          },
                          child: Text('확인'),
                        ),
                      ],
                    );
                  },
                );
              }

              // 메시지가 "COMPLETE"로 시작하는 경우
              else if (message != null && message.startsWith("COMPLETE")) {
                // WeddingHomePage로 리다이렉트
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WeddingHomePage()),
                );
              }

              // 그 외 메시지 처리 (필요한 경우)
              else {
                print('서버에서 받은 메시지: $message');
              }
            },
          );
        },
        onWebSocketError: (dynamic error) => print('WebSocket 에러: $error'),
      ),
    );

    stompClient.activate(); // STOMP 클라이언트 활성화
  }

  // 페어링 요청 보내기 함수
  void _sendPairingRequest(String pairingCode) {
    final pairingRequest = {
      'pairingCode': pairingCode,
      'email': widget.id,
    };
    print('페어링 요청 전송: $pairingRequest');
    stompClient.send(
      destination: '/app/requestPairing', // 서버의 STOMP 경로
      body: jsonEncode(pairingRequest), // 요청 본문
    );
  }

  // 페어링 완료 요청 보내기 함수
  void _sendPairingComplete(String pairingCode) {
    //내 코드면 안되게 막기. 두개 폰 테스트 전에
    final pairingResponse = {
      'pairingCode': pairingCode,
      'email': widget.id,
    };
    print('페어링 완료 요청 전송: $pairingResponse');

    stompClient.send(
      destination: '/app/pairingComplete', // 페어링 완료 경로
      body: jsonEncode(pairingResponse),
    );
  }

  // 페어링 요청 다이얼로그 표시
  void _showPairingRequestDialog(String pairingCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('페어링 요청'),
        content: Text('페어링 요청이 도착했습니다!'),
        actions: [
          TextButton(
            onPressed: () {
              _sendPairingComplete(pairingCode);
              Navigator.of(context).pop();
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  // 페어링 완료 다이얼로그 표시
  void _showPairingCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('페어링 완료'),
        content: Text('상대방과 페어링이 완료되었습니다!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('초대 코드 입력'),
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
                  labelText: '전달받은 초대코드 입력',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  enteredPairingCode = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (enteredPairingCode.isNotEmpty) {
                    _sendPairingComplete(enteredPairingCode);
                  } else {
                    print('초대 코드를 입력해주세요');
                  }
                },
                child: Text('연결하기'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
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
    stompClient.deactivate(); // STOMP 클라이언트 비활성화
    super.dispose();
  }
}
