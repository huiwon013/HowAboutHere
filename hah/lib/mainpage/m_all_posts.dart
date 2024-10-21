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
            .where('location', isEqualTo: city) // 선택된 도시와 일치하는 게시물 필터링
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
              return ListTile(
                title: Text(post['title'] ?? '제목 없음'), // 게시물 제목 표시
                subtitle: Text(post['content'] ?? '내용 없음'), // 게시물 내용 일부 표시
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
