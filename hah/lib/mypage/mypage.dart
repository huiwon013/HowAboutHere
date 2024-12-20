import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 패키지 추가
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth 패키지 추가
import 'package:hah/mypage/save_post.dart';
import '../appbar/appbar.dart';
import '../startpage/find_Register.dart';
import '../startpage/start.dart';
import 'delete_account.dart';
import 'my_post.dart'; // MyPostPage 추가

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String userNickname = 'Loading...'; // 초기값 설정
  String userEmail = ''; // 사용자 이메일 초기값 설정

  @override
  void initState() {
    super.initState();
    _fetchUserDetails(); // 사용자 정보를 가져오는 함수 호출
  }

  Future<void> _fetchUserDetails() async {
    // Firebase Firestore에서 현재 사용자 닉네임과 이메일을 가져오는 로직
    try {
      User? user = FirebaseAuth.instance.currentUser; // 현재 로그인한 사용자
      if (user != null) {
        String uid = user.uid; // 사용자 UID 가져오기
        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (snapshot.exists) {
          setState(() {
            // 'name'과 'email' 필드에서 값을 가져옴
            userNickname = snapshot['userNickname'] ?? '닉네임 없음'; // 'name' 필드로 수정
            userEmail = snapshot['email'] ?? '이메일 없음'; // 'email' 필드로 수정
          });
        } else {
          setState(() {
            userNickname = '닉네임 없음'; // 문서가 존재하지 않을 경우
            userEmail = '이메일 없음'; // 이메일도 설정
          });
        }
      } else {
        setState(() {
          userNickname = '사용자 정보 없음'; // 로그인하지 않은 경우
          userEmail = '이메일 없음'; // 이메일도 설정
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
      setState(() {
        userNickname = '로딩 실패'; // 로딩 실패 메시지 설정
        userEmail = '이메일 없음'; // 이메일도 설정
      });
    }
  }

  Future<void> _updateNickname(String newNickname) async {
    User? user = FirebaseAuth.instance.currentUser; // 현재 로그인한 사용자
    if (user != null) {
      try {
        String uid = user.uid; // 사용자 UID 가져오기
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'userNickname': newNickname, // 닉네임 업데이트
        });
        setState(() {
          userNickname = newNickname; // UI 업데이트
        });
      } catch (e) {
        print('닉네임 업데이트 실패: $e');
      }
    }
  }

  void _showEditNicknameDialog(BuildContext context) {
    TextEditingController nicknameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('닉네임 변경'),
          content: TextField(
            controller: nicknameController,
            decoration: InputDecoration(hintText: '새 닉네임을 입력하세요.'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () {
                if (nicknameController.text.isNotEmpty) {
                  _updateNickname(nicknameController.text); // 닉네임 업데이트 함수 호출
                }
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('마이페이지'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              leading: const CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    userNickname, // 사용자 닉네임으로 변경
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showEditNicknameDialog(context); // 닉네임 수정 다이얼로그 호출
                    },
                    child: Text(
                      '프로필 수정',
                      style: TextStyle(
                        color: Colors.blue, // 원하는 색상으로 변경 가능
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                userEmail, // 사용자 이메일로 변경
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            Divider(),
            // 작성한 글, 좋아요, 북마크, 내가 쓴 댓글 항목 추가
            ListTile(
              leading: Icon(Icons.article),
              title: Text('작성한 글'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPostPage()), // MyPostPage로 이동
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.comment),
              title: Text('내가 쓴 댓글'),
              onTap: () {
                // TODO: 내가 쓴 댓글 기능 구현
              },
            ),
            SizedBox(height: 20.0),
            Text(
              '계정 항목',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('비밀번호 변경'),
              onTap: () {
                // 비밀번호 변경 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FindRegister()), // FindRegister로 이동
                );
              },
            ),
            InkWell(
              onTap: () {
                _showLogoutDialog(context);
              },
              child: ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                // 회원 탈퇴 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteAccountPage()), // DeleteAccountPage로 이동
                );
              },
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text(
                  '회원 탈퇴',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그아웃 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('아니요'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
            TextButton(
              child: Text('예'),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => StartPage()), // 첫 페이지로 이동
                      (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
