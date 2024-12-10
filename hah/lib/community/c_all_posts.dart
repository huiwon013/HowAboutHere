import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hah/community/c_create_post.dart';

import '../mainpage/m_detail_post.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late Stream<QuerySnapshot> _postStream;

  @override
  void initState() {
    super.initState();
    _postStream = FirebaseFirestore.instance
        .collection('communityPosts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 댓글 추가 함수
  Future<void> _addComment(DocumentSnapshot post, String comment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('communityPosts').doc(post.id).update({
        'comments': FieldValue.arrayUnion([
          {
            'nickname': user.displayName ?? '알 수 없음',
            'comment': comment,
            'timestamp': FieldValue.serverTimestamp(),
          }
        ]),
      });
    } catch (e) {
      print('댓글 추가 실패: $e');
    }
  }

  // 게시물 클릭 시 게시물 상세 페이지로 이동
  void _navigateToPostDetailPage(BuildContext context, DocumentSnapshot post) {
    final data = post.data() as Map<String, dynamic>;
    final title = data['title'] ?? '제목 없음';
    final location = data['location'] ?? '위치 없음';
    final content = data['content'] ?? '내용 없음';
    final username = data['nickname'] ?? '알 수 없음';
    final date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final imageUrls = List<String>.from(data['imageUrls'] ?? []);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(
          title: title,
          content: content,
          location: location,
          username: username,
          date: date,
          imageUrls: imageUrls,
          postId: post.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 100,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 30, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CMCreatePostPage()),
              );
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "검색어를 입력하세요.",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 12.0),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                '커뮤니티',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const Divider(
            thickness: 1,
            color: Colors.black,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _postStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('오류가 발생했습니다.'));
                }

                final posts = snapshot.data?.docs ?? [];

                if (posts.isEmpty) {
                  return const Center(child: Text('게시물이 없습니다.'));
                }

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final data = post.data() as Map<String, dynamic>;
                    final title = data['title'] ?? '제목 없음';
                    final location = data['location'] ?? '위치 없음';
                    final content = data['content'] ?? '내용 없음';
                    final images = List<String>.from(data['imageUrls'] ?? []);
                    final comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);

                    TextEditingController commentController = TextEditingController();

                    return GestureDetector(
                      onTap: () {
                        _navigateToPostDetailPage(context, post);
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        elevation: 5, // 그림자 추가
                        color: Colors.lightBlue[50], // 연한 파랑색 배경
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, size: 40, color: Colors.grey),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['nickname'] ?? '알 수 없음',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          data['timestamp'] != null
                                              ? (data['timestamp'] as Timestamp)
                                              .toDate()
                                              .toString()
                                              : '시간 정보 없음',
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(location, style: TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Text(content),
                                ],
                              ),
                            ),
                            if (images.isNotEmpty)
                              SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: images.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Image.network(
                                        images[index],
                                        fit: BoxFit.cover,
                                        width: 150,
                                        height: 100,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: commentController,
                                decoration: InputDecoration(
                                  hintText: '댓글을 입력하세요.',
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.send),
                                    onPressed: () {
                                      _addComment(post, commentController.text);
                                      commentController.clear();
                                    },
                                  ),
                                ),
                              ),
                            ),
                            ...comments.map((comment) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person, size: 30, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['nickname'],
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(comment['comment']),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
