import 'package:flutter/material.dart';

class FaqDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('올바른 앱 사용방법'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              '부적절한 의도와 목적의 서비스 이용',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            buildTermItem('1. 잘못된 방법으로 서비스의 제공을 방해하거나 당근이 안내하는 방법 이외의 다른 방법을 사용하여 당근 서비스에 접근하는 행위'),
            buildTermItem('2. 다른 이용자의 정보를 무단으로 수집, 이용하거나 다른 사람들에게 제공하는 행위'),
            buildTermItem('3. 서비스를 영리나 홍보 목적적으로 이용하는 행위'),
            buildTermItem('4. 음란 정보나 저작권 침해 정보 등 공서양속 및 법령에 위반되는 내용의 정보를 발송하거나 게시하는 행위'),
            buildTermItem('5. 당근의 동의 없이 당근 서비스 또는 이에 포함된 소프트웨어의 일부를 복사, 수정, 배포, 판매, 양도, 대여, 담보제공하거나 타인에게 그 이용을 허락하는 행위'),
            buildTermItem('6. 소프트웨어를 역설계하거나 소스 코드의 추출을 시도하는 등 당근 서비스를 복제, 분해 또는 모방하거나 기타 변형하는 행위'),
            buildTermItem('7. 관련 법령, 당근의 모든 약관 또는 운영정책을 준수하지 않는 행위'),
          ],
        ),
      ),
    );
  }

  Widget buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16.0, height: 1.5),
      ),
    );
  }
}
