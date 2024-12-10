import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'c_create_post.dart';

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

  // 좋아요 버튼 클릭 시
  void _toggleLike(DocumentSnapshot post) async {
    final isLiked = post['isLiked'] ?? false;
    final currentLikes = post['likes'] ?? 0;

    try {
      // Firestore에서 해당 게시물의 좋아요 상태를 반전시켜 저장
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final freshSnapshot = await transaction.get(post.reference);
        transaction.update(post.reference, {
          'isLiked': !isLiked,
          'likes': isLiked ? currentLikes - 1 : currentLikes + 1,
        });
      });

      setState(() {}); // UI 갱신
    } catch (e) {
      print('좋아요 처리 오류: $e');
    }
  }

  // 저장 버튼 클릭 시
  void _toggleSave(DocumentSnapshot post) async {
    final isSaved = post['saved'] ?? false;

    try {
      // Firestore에서 해당 게시물의 저장 상태를 반전시켜 저장
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final freshSnapshot = await transaction.get(post.reference);
        transaction.update(post.reference, {'saved': !isSaved});
      });

      setState(() {}); // UI 갱신
    } catch (e) {
      print('저장 처리 오류: $e');
    }
  }

  // 댓글 추가 함수
  Future<void> _addComment(DocumentSnapshot post, String comment) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // 로그인된 사용자가 없으면 댓글을 추가하지 않음

    try {
      // 댓글을 Firestore에 추가
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

  // 플러스 버튼 클릭 시 게시물 작성 페이지로 이동
  void _navigateToCreatePostPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CMCreatePostPage()),
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
              _navigateToCreatePostPage(context); // 플러스 버튼 클릭 시 페이지 이동
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
                    final likes = data['likes'] ?? 0;
                    final isLiked = data['isLiked'] ?? false;
                    final isSaved = data['saved'] ?? false;
                    final images = List<String>.from(data['imageUrls'] ?? []); // 이미지 목록
                    final comments = List<Map<String, dynamic>>.from(data['comments'] ?? []); // 댓글 목록

                    TextEditingController commentController = TextEditingController();

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundImage: AssetImage('assets/user_avatar.png'),
                                  radius: 20,
                                ),
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
                            Container(
                              height: 200,
                              child: PageView.builder(
                                itemCount: images.length,
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    images[index],
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                                        color: isSaved ? Colors.black : Colors.grey,
                                      ),
                                      onPressed: () => _toggleSave(post),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        color: isLiked ? Colors.red : Colors.grey,
                                      ),
                                      onPressed: () => _toggleLike(post),
                                    ),
                                    Text('$likes'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var comment in comments)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text('${comment['nickname']} : ${comment['comment']}'),
                                  ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: commentController,
                                        decoration: const InputDecoration(
                                          hintText: '댓글을 입력하세요...',
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.send),
                                      onPressed: () async {
                                        final comment = commentController.text.trim();
                                        if (comment.isNotEmpty) {
                                          // 댓글 추가
                                          await _addComment(post, comment);
                                          commentController.clear();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
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
