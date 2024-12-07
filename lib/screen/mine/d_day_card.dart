import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/mine/d_day_management.dart';

import '../../config/ApiConstants.dart';

class DDayCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;
  final String afterFlag;
  final String day;
  final VoidCallback onRefresh; // onTap 콜백 추가

  const DDayCardWidget({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.afterFlag,
    required this.day,
    required this.onRefresh, // onTap을 매개변수로 받음
    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    String imageUrl = image;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DDayManagementPage()),
        ).then((_) {
          onRefresh();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            // 왼쪽에 배경 이미지로 쓰이는 영역
            Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                shape: BoxShape.circle, // 동그란 모양
                image: DecorationImage(
                  image: NetworkImage(imageUrl), // 프로필 이미지로 설정
                  fit: BoxFit.cover, // 이미지가 동그란 영역을 채우도록 설정
                ),
              ),
            ),
            // 오른쪽에 텍스트 내용
            Expanded( // 여기서 Expanded로 감싸기
              child: SingleChildScrollView( // Column을 감싸서 스크롤 가능하게 하기
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    Text(
                      '$subtitle, $day일 ${afterFlag == "true" ? "지났어요" : "남았어요"}.',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                    /*Text(
                      date,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Pretendard',
                      ),
                    ),*/
                    // 필요시 추가 내용
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
