import 'package:flutter/material.dart';

class PostDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String location;
  final String username;
  final DateTime date;

  PostDetailPage({
    required this.title,
    required this.content,
    required this.location,
    required this.username,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 상세'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.account_circle, size: 25, color: Colors.grey),
                SizedBox(width: 4),
                Text(username, style: TextStyle(fontSize: 20, color: Colors.grey)), // 사용자 닉네임
                Spacer(), // 닉네임과 날짜 사이의 간격을 자동으로 조절
                Text(
                  '${date.year}-${date.month}-${date.day}', // timestamp를 Date로 변환
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              title, //제목
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, size: 20, color: Colors.grey), // 지역 아이콘
                SizedBox(width: 4), // 아이콘과 텍스트 사이의 간격
                Text(location, style: TextStyle(fontSize: 16, color: Colors.grey)), // 위치 텍스트
              ],
            ),
            SizedBox(height: 16),
            Text(content, style: TextStyle(fontSize: 18),), // 내용
          ],
        ),
      ),
    );
  }
}
