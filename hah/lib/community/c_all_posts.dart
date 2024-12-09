import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int selectedTabIndex = 0;
  late Stream<QuerySnapshot> _postStream;

  @override
  void initState() {
    super.initState();
    _postStream = FirebaseFirestore.instance
        .collection('communityPosts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Like 버튼 클릭 시
  void _toggleLike(DocumentSnapshot post) async {
    final isLiked = post['isLiked'] ?? false;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final freshSnapshot = await transaction.get(post.reference);
      // 좋아요 상태를 반전시켜 저장
      transaction.update(post.reference, {'isLiked': !isLiked});
    });

    setState(() {}); // 상태 변경 후 UI 갱신
  }

  // Save 버튼 클릭 시
  void _toggleSave(DocumentSnapshot post) async {
    final isSaved = post['saved'] ?? false;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final freshSnapshot = await transaction.get(post.reference);
      // 저장 상태를 반전시켜 저장
      transaction.update(post.reference, {'saved': !isSaved});
    });

    setState(() {}); // 상태 변경 후 UI 갱신
  }

  Future<String> _getUserNickname(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (userSnapshot.exists) {
        return userSnapshot['nickname'] ?? '알 수 없음';
      } else {
        return '알 수 없음';
      }
    } catch (e) {
      return '알 수 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 100,
        actions: [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTab('전체', 0),
              _buildTab('인기글', 1),
              _buildTab('국내', 2),
              _buildTab('해외', 3),
            ],
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
                    final uid = data['uid'] ?? '';

                    return FutureBuilder<String>(
                      future: _getUserNickname(uid),
                      builder: (context, nicknameSnapshot) {
                        if (nicknameSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final nickname = nicknameSnapshot.data ?? '알 수 없음';

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 사용자 정보와 업로드 시간
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
                                            nickname,
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
                              // 게시물 내용
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
                              // 좋아요, 저장, 댓글 버튼
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
                            ],
                          ),
                        );
                      },
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

  Widget _buildTab(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: selectedTabIndex == index ? Colors.blue : Colors.transparent, width: 2)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selectedTabIndex == index ? Colors.blue : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
