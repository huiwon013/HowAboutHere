import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PostDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String location;
  final String username;
  final DateTime date;
  final List<String> imageUrls;
  final String postId;

  PostDetailPage({
    required this.title,
    required this.content,
    required this.location,
    required this.username,
    required this.date,
    required this.imageUrls,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('게시물 상세'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
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
                    SizedBox(height: 16),
                    Divider(),
                    Text(
                      '댓글',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    CommentSection(postId: postId),
                  ],
                ),
              ),
            ),
          ),
          CommentInput(postId: postId),
        ],
      ),
    );
  }
}

class CommentSection extends StatelessWidget {
  final String postId;

  CommentSection({required this.postId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('comments')
          .doc(postId)
          .collection('post_comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var comments = snapshot.data!.docs;
        if (comments.isEmpty) {
          return Text('댓글이 없습니다.');
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            var comment = comments[index];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(comment['userId']).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return ListTile(title: Text('Loading...'));
                }
                var userNickname = userSnapshot.data!['userNickname'] ?? 'Unknown User';
                var time = DateFormat('yyyy-MM-dd HH:mm').format(comment['timestamp'].toDate());
                return ListTile(
                  title: Text(comment['content']),
                  subtitle: Text('$userNickname - $time'),
                );
              },
            );
          },
        );
      },
    );
  }
}

class CommentInput extends StatefulWidget {
  final String postId;

  CommentInput({required this.postId});

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _commentController = TextEditingController();
  User? _currentUser;
  String? _currentUserNickname;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _currentUserNickname = userDoc.data()!['userNickname'];
        });
      }
    }
  }

  void _submitComment() {
    if (_commentController.text.isNotEmpty && _currentUser != null && _currentUserNickname != null) {
      FirebaseFirestore.instance
          .collection('comments')
          .doc(widget.postId) // postId에 해당하는 문서
          .collection('post_comments') // 댓글을 개별 문서로 저장
          .add({
        'userId': _currentUser!.uid,
        'content': _commentController.text,
        'timestamp': Timestamp.now(),
      })
          .then((_) {
        _commentController.clear();
      })
          .catchError((error) {
        print('Error adding comment: $error');
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: '댓글 작성',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _submitComment,
          ),
        ],
      ),
    );
  }
}
