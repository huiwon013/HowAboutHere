import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth 사용

class CMCreatePostPage extends StatelessWidget {
  CMCreatePostPage({super.key});

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<String> _getUserNickname(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot['nickname'] ?? '닉네임 없음';
      } else {
        return '알 수 없음';
      }
    } catch (e) {
      print('Error getting user nickname: $e');
      return '알 수 없음';
    }
  }

  Future<void> _savePost() async {
    if (_titleController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _contentController.text.isEmpty) {
      return; // 데이터가 비어 있으면 저장하지 않음
    }

    try {
      // FirebaseAuth를 사용하여 현재 로그인한 사용자의 uid를 가져옵니다.
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // uid를 사용하여 닉네임을 가져옵니다.
        String nickname = await _getUserNickname(user.uid);

        // 게시물 저장
        await FirebaseFirestore.instance.collection('communityPosts').add({
          'title': _titleController.text,
          'location': _locationController.text,
          'content': _contentController.text,
          'nickname': nickname, // 닉네임 추가
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user.uid, // 사용자 ID 추가 (필요한 경우)
        });

        print('게시물 저장 성공');
      } else {
        print('사용자가 로그인되지 않았습니다.');
      }
    } catch (e) {
      print('Error saving post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('test 커뮤니티 글 작성'), // 앱바 제목
        backgroundColor: Colors.white, // 앱바 배경색
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 패딩 추가
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            // 제목 입력 필드
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
              ),
            ),
            const SizedBox(height: 16.0), // 간격
            // 장소 입력 필드
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: '장소',
              ),
            ),
            const SizedBox(height: 16.0), // 간격
            // 사진 버튼
            ElevatedButton(
              onPressed: () {
                // 사진 선택 동작 추가
              },
              child: const Icon(Icons.camera_alt),
            ),
            const SizedBox(height: 16.0), // 간격
            // 글 작성 필드
            Container(
              height: 300, // 글 작성 필드의 고정 높이
              child: SingleChildScrollView(
                child: TextField(
                  controller: _contentController,
                  maxLines: null, // 무한대로 줄 수 늘리기
                  decoration: const InputDecoration(
                    hintText: '내용을 입력하세요',
                    border: InputBorder.none, // 테두리 없애기
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0), // 구분선과 완료 버튼 간격
            // 구분선
            Container(
              height: 1.0, // 구분선의 두께
              color: Colors.grey, // 구분선 색상
            ),
            const SizedBox(height: 8.0), // 구분선과 완료 버튼 간격
          ],
        ),
      ),
      // 완료 버튼
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          await _savePost();
          Navigator.pop(context); // 저장 후 이전 화면으로 이동
        },
        child: const Text('완료'), // 텍스트 버튼으로 변경
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // 버튼 배경색
        ),
      ),
    );
  }
}
