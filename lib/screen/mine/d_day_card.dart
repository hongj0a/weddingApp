import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/mine/d_day_management.dart';

import '../../config/ApiConstants.dart';

class DDayCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String image;
  final VoidCallback onRefresh; // onTap 콜백 추가

  const DDayCardWidget({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.image,
    required this.onRefresh, // onTap을 매개변수로 받음
    Key? key,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    String imageUrl = '${ApiConstants.localImagePath}/$image';
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
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl), // 배경 이미지 추가
            fit: BoxFit.cover,  // 이미지가 컨테이너 전체를 덮도록 설정
          ),
        ),
        margin: EdgeInsets.all(0.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'SejongGeulggot'),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'SejongGeulggot'),
                ),
                SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'SejongGeulggot'),
                ),
              ],
            ),
            SizedBox(width: 140),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
