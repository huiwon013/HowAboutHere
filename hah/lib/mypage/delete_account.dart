import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 추가
import '../startpage/start.dart';

class DeleteAccountPage extends StatefulWidget {
  @override
  _DeleteAccountPageState createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordInvalid = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100.0, left: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.delete,
                  size: 30,
                  color: Colors.black,
                ),
                SizedBox(width: 10),
                Text(
                  '탈퇴하기',
                  style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '회원정보에 등록한 비밀번호를 입력해주세요.\n올바른 비밀번호 입력시, 탈퇴가 완료됩니다.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: '비밀번호',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ),
                if (isPasswordInvalid)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    String password = passwordController.text.trim();
                    _deleteAccount(password);
                  },
                  child: Text(
                    '탈퇴하기',
                    style: TextStyle(
                      color: Colors.black, // 버튼 텍스트 색상
                      fontSize: 15,
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[50]!),
                    minimumSize: MaterialStateProperty.all(Size(300, 50)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    elevation: MaterialStateProperty.all<double>(5.0), // 그림자 추가
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );

        // Re-authenticate the user
        await user.reauthenticateWithCredential(credential);

        // Delete user posts from Firestore
        await _deleteUserPosts(user.uid);

        // Delete the user from Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

        // Delete the user from Firebase Authentication
        await user.delete();

        // Navigate to start page
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => StartPage()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      setState(() {
        isPasswordInvalid = true;
        errorMessage = '비밀번호가 올바르지 않습니다.';
      });
    }
  }

  Future<void> _deleteUserPosts(String userId) async {
    try {
      // Firestore에서 사용자의 모든 게시물 가져오기
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: userId)  // 사용자의 uid 기준으로 게시물을 검색
          .get();

      // 각 게시물을 삭제
      for (var doc in postsSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("게시물 삭제 중 오류 발생: $e");
    }
  }
}
