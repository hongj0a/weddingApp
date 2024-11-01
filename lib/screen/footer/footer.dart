import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('이용약관', style: TextStyle(color: Colors.grey)),
              SizedBox(width: 10),
              Text('개인정보 처리방침', style: TextStyle(color: Colors.grey)),
              SizedBox(width: 10),
              Text('입점•제휴문의', style: TextStyle(color: Colors.grey)),
              SizedBox(width: 10),
              Text('광고문의', style: TextStyle(color: Colors.grey)),
            ],
          ),
          SizedBox(height: 10),
          Text('(주)버짓인사이트 대표 홍진영 사업자 정보 확인 >',
              style: TextStyle(color: Colors.grey)),
          SizedBox(height: 10),
          Text('서울 은평구 진흥로 153', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 10),
          Text('사업자등록번호 : 111-22-33333', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 10),
          Text('통신판매업신고 : 제2013-서울강남-02403호 호스팅 서비스사업자 : AWS',
              style: TextStyle(color: Colors.grey)),
          SizedBox(height: 10),
          Text('E-mail: support@ourwallet.co.kr', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 10),
          Text('고객센터 : 1544-1234 (평일 09~18시, 점심시간 12~13시, 주말/공휴일 휴무)',
              style: TextStyle(color: Colors.grey)),
          SizedBox(height: 10),
          Text('(주)버짓인사이트 우월 사이트의 사용자정보/계약정보/콘텐츠/UI 등에 대한 무단복제, 전송, 배포, 스크래핑 등의 행위는 저작권법, 콘텐츠 산업 진흥법 등 관련법령에 의하여 엄격히 금지됩니다.',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
