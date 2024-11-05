import 'package:flutter/material.dart';

class PostDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String location;
  final String username;
  final DateTime date;
  final List<String> imageUrls;

  PostDetailPage({
    required this.title,
    required this.content,
    required this.location,
    required this.username,
    required this.date,
    required this.imageUrls,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시물 상세'),
      ),
      body: SingleChildScrollView( // 스크롤 가능하게 만들기
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.account_circle, size: 25, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(username, style: TextStyle(fontSize: 20, color: Colors.grey)),
                  Spacer(),
                  Text(
                    '${date.year}-${date.month}-${date.day}',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(location, style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
              SizedBox(height: 16),
              if (imageUrls.isNotEmpty)
                Column(
                  children: imageUrls.map((url) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.0), // 이미지 사이 간격
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity, // 전체 너비 사용
                        height: 200, // 원하는 높이로 설정
                      ),
                    );
                  }).toList(),
                ),
              SizedBox(height: 16),
              Text(content, style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
