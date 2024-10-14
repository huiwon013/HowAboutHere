import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String email = "";
  String password = "";
  String confirmPassword = "";
  String name = "";
  String userNickname = "";

  bool isRegistered = false;
  bool showErrorMessage = false;

  void _register() async {
    setState(() {
      showErrorMessage = true;
    });

    try {
      // 필수 입력값 체크
      if (email.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty ||
          name.isEmpty ||
          userNickname.isEmpty) {
        print("정보를 입력해주세요.");
        setState(() {
          isRegistered = false;
        });
        return;
      }

      // 비밀번호 확인
      if (password != confirmPassword) {
        print("비밀번호와 비밀번호 확인이 일치하지 않습니다.");
        return;
      }

      // 사용자에게 이메일 인증 메일 전송
      await _sendEmailVerification();
      setState(() {
        isRegistered = true; // 회원가입 성공
      });
    } catch (e) {
      print("회원가입 실패: $e");
      setState(() {
        isRegistered = false; // 회원가입 실패
      });
    }
  }

  Future<void> _sendEmailVerification() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Firestore에 사용자 정보 저장
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'userNickname': userNickname,
        });

        // 사용자에게 이메일 인증 메일 전송
        await user.sendEmailVerification();
        print('이메일 인증 메일이 전송되었습니다. 이메일을 확인해주세요.');
      }
    } catch (e) {
      print('이메일 인증 메일 전송 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.blue[50], // 연한 파란색
      ),
      // 배경색을 연한 파란색으로 변경
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 80.0),
                Text('회원가입',
                    style: TextStyle(fontSize: 27.0, fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: 23.0),
                Container(
                  width: 320,
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // 이메일 입력
                      _buildTextField("이메일", Icons.email_outlined, (value) {
                        email = value;
                      }),
                      // 비밀번호 입력
                      _buildTextField("비밀번호", Icons.lock_outline, (value) {
                        password = value;
                      }, obscureText: true),
                      // 비밀번호 확인 입력
                      _buildTextField("비밀번호 확인", Icons.lock_outline, (value) {
                        confirmPassword = value;
                      }, obscureText: true),
                      // 이름 입력
                      _buildTextField("이름", Icons.person_outline, (value) {
                        name = value;
                      }),
                      // 닉네임 입력
                      _buildTextField("닉네임", Icons.account_circle, (value) {
                        userNickname = value;
                      }),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                // 버튼 색상도 연한 파란색으로 변경
                Container(
                  width: 310,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      _register();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // 연한 파란색
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2, // 그림자 추가
                    ),
                    child: Text(
                      '가입하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                if (showErrorMessage && !isRegistered && email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty && name.isNotEmpty && userNickname.isNotEmpty)
                  SizedBox(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.brown, fontSize: 17),
                        children: [
                          TextSpan(
                            text: ' 가입이 완료되었습니다.\n',
                          ),
                          TextSpan(
                            text: '이메일을 확인하고 로그인 페이지로 이동하기',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!isRegistered && showErrorMessage && (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || name.isEmpty || userNickname.isNotEmpty))
                  SizedBox(
                    child: Text(
                      '정보를 입력하세요.',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TextField 생성 메소드
  Widget _buildTextField(String label, IconData icon, Function(String) onChanged, {bool obscureText = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              labelText: label,
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: Colors.grey[400]),
            ),
            style: TextStyle(color: Colors.black),
            obscureText: obscureText,
            onChanged: onChanged,
          ),
          Container(
            height: 0.8,
            width: double.infinity,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
