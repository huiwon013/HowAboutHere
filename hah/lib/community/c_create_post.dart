import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // 파일 시스템 사용
import 'package:firebase_storage/firebase_storage.dart';

class CMCreatePostPage extends StatefulWidget {
  CMCreatePostPage({super.key});

  @override
  _CMCreatePostPageState createState() => _CMCreatePostPageState();
}

class _CMCreatePostPageState extends State<CMCreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image; // 선택된 이미지를 저장할 변수

  Future<String> _getUserNickname(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      // userNickname 필드에서 닉네임을 가져옵니다
      String userNickname = userSnapshot['userNickname'] ?? '닉네임 없음';
      return userNickname;
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

        // 게시물 저장 데이터 준비
        final postData = {
          'title': _titleController.text,
          'location': _locationController.text,
          'content': _contentController.text,
          'nickname': nickname, // 닉네임 추가
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user.uid,
        };

        // 이미지가 선택되었으면, Firebase Storage에 업로드
        if (_image != null) {
          final imageUrl = await _uploadImageToFirebase(_image!);

          postData['imageUrl'] = imageUrl; // 업로드한 이미지 URL 추가
        }

        // Firebase에 게시물 저장
        await FirebaseFirestore.instance.collection('communityPosts').add(postData);

        print('게시물 저장 성공');
      } else {
        print('사용자가 로그인되지 않았습니다.');
      }
    } catch (e) {
      print('Error saving post: $e');
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    try {
      // Firebase Storage에 이미지를 업로드하는 로직
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('posts/images/$fileName');
      UploadTask uploadTask = storageRef.putFile(image);

      // 업로드 완료 후 이미지 URL 반환
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl; // 업로드된 이미지 URL 반환
    } catch (e) {
      print('Error uploading image: $e');
      return ''; // 오류 발생 시 빈 문자열 반환
    }
  }

  // 사진 선택 함수
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 선택한 이미지 저장
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('test 커뮤니티 글 작성'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: '장소',
              ),
            ),
            const SizedBox(height: 16.0),
            // 사진 선택 버튼
            ElevatedButton(
              onPressed: _pickImage,
              child: const Icon(Icons.camera_alt),
            ),
            const SizedBox(height: 16.0),
            // 선택한 이미지 표시
            if (_image != null)
              Image.file(
                _image!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16.0),
            Container(
              height: 300,
              child: SingleChildScrollView(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: '내용을 입력하세요',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              height: 1.0,
              color: Colors.grey,
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
      // 완료 버튼
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          await _savePost();
          Navigator.pop(context); // 저장 후 이전 화면으로 이동
        },
        child: const Text('완료'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
