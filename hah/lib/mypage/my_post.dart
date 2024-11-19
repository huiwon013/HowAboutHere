import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPostPage extends StatefulWidget {
  @override
  _MyPostPageState createState() => _MyPostPageState();
}

class _MyPostPageState extends State<MyPostPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> _userPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }

  Future<void> _fetchUserPosts() async {
    if (_currentUser == null) return;

    try {
      // Firestore에서 현재 사용자의 UID를 기반으로 게시글 가져오기
      QuerySnapshot querySnapshot = await _firestore
          .collection('posts')
          .where('uid', isEqualTo: _currentUser!.uid) // uid 기준으로 필터링
          .orderBy('createdAt', descending: true) // 작성 시간을 기준으로 정렬 (옵션)
          .get();

      setState(() {
        _userPosts = querySnapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('작성한 글'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userPosts.isEmpty
          ? Center(child: Text('작성한 글이 없습니다.'))
          : ListView.builder(
        itemCount: _userPosts.length,
        itemBuilder: (context, index) {
          final post = _userPosts[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(
                post['title'] ?? '제목 없음',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                post['content'] ?? '내용 없음',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                // TODO: 글 상세 페이지로 이동하도록 구현
              },
            ),
          );
        },
      ),
    );
  }
}
