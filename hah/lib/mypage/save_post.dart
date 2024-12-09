import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('저장된 게시물')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('communityPosts')
            .where('saved', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('오류가 발생했습니다.'));
          }

          final posts = snapshot.data?.docs ?? [];

          if (posts.isEmpty) {
            return const Center(child: Text('저장된 게시물이 없습니다.'));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title']),
                subtitle: Text(data['content']),
              );
            },
          );
        },
      ),
    );
  }
}
