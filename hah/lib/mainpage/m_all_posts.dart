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
              var date = post['timestamp']?.toDate() ?? DateTime.now(); // 날짜
              var title = post['title'] ?? '제목 없음'; // 게시물 제목
              var content = post['content'] ?? '내용 없음'; // 게시물 내용
              var location = post['location'] ?? '위치 없음'; // 게시물 위치

              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.account_circle, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(username, style: TextStyle(fontSize: 14, color: Colors.grey)), // 사용자 닉네임
                        Spacer(), // 닉네임과 날짜 사이의 간격을 자동으로 조절
                        Text(
                          '${date.year}-${date.month}-${date.day}',
                          style: TextStyle(fontSize: 12, color: Colors.grey), // timestamp를 Date로 변환
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title, //제목
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey), // 지역 아이콘
                        SizedBox(width: 4), // 아이콘과 텍스트 사이의 간격
                        Text(location, style: TextStyle(fontSize: 12, color: Colors.grey)), // 위치 텍스트
                      ],
                    ),
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
