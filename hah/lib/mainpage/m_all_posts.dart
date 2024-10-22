import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllPostsPage extends StatelessWidget {
  final String city; // 선택한 도시명

  AllPostsPage({required this.city}); // 생성자에서 도시명을 받아옴

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$city 게시물'), // 선택된 도시명 표시
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts') // Firestore의 'posts' 컬렉션
            .where('region', isEqualTo: city) // 선택된 도시와 일치하는 게시물 필터링
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 로딩 중일 때 표시
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('게시물이 없습니다.')); // 게시물이 없을 때 표시
          }

          // 게시물 목록 표시
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var post = snapshot.data!.docs[index];
              var username = post['userNickname'] ?? '사용자 없음'; // 사용자 이름
              var date = post['date']?.toDate() ?? DateTime.now(); // 날짜
              var title = post['title'] ?? '제목 없음'; // 게시물 제목
              var content = post['content'] ?? '내용 없음'; // 게시물 내용
              var location = post['location'] ?? '위치 없음'; // 게시물 위치

              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(username, style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text(
                          '${date.year}-${date.month}-${date.day}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(location, style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                subtitle: Text(content, maxLines: 2, overflow: TextOverflow.ellipsis), // 게시물 내용 일부 표시
                onTap: () {
                  // 게시물 상세 보기 기능 추가 가능
                },
              );
            },
          );
        },
      ),
    );
  }
}
