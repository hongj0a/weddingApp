import 'package:flutter/material.dart';
import 'package:smart_wedding/screen/d_day_management.dart';

import 'd_day_management.dart';

class DDayCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String imagePath;

  const DDayCardWidget({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.imagePath,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DDayManagementPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.lime[100],
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(width: 180),
            Container(
              width: 80,
              height: 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    top: 7.0,
                    child: ClipOval(
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
