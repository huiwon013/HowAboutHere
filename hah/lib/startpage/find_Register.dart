import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FindRegister(),
    );
  }
}

class FindRegister extends StatefulWidget {
  @override
  _FindRegisterState createState() => _FindRegisterState();
}

class _FindRegisterState extends State<FindRegister> {
  final TextEditingController emailController = TextEditingController();
  final RegExp emailRegExp = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );
  bool isEmailInvalid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.blue[50],
      ),
      body: Container(
        color: Colors.blue[50], // 배경색 변경
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100.0, left: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 30,
                    color: Colors.black,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '비밀번호 찾기',
                    style: TextStyle(fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
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
                    '회원정보에 등록한 이메일을 입력해주세요.\n등록한 이메일로 비밀번호 재설정 메일이 발송됩니다.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5.0,
                            spreadRadius: 1.0,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: '이메일',
                          border: InputBorder.none, // 테두리 제거
                          contentPadding: EdgeInsets.all(16.0), // 패딩 추가
                        ),
                        onChanged: (value) {
                          setState(() {
                            isEmailInvalid = !isEmailValid(value);
                          });
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isEmailInvalid,
                    child: Text(
                      '올바른 이메일 형식이 아닙니다.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      String email = emailController.text.trim();
                      if (isEmailValid(email)) {
                        // 올바른 이메일인 경우에만 이메일 전송
                        sendPasswordResetEmail(email);
                      }
                    },
                    child: Text(
                      '이메일 전송',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.white), // 버튼 색상 변경
                      minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
                      shadowColor: MaterialStateProperty.all<Color>(Colors.black.withOpacity(0.1)), // 그림자 색상
                      elevation: MaterialStateProperty.all<double>(5), // 그림자 높이
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isEmailValid(String email) {
    return emailRegExp.hasMatch(email);
  }

  void sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // 비밀번호 재설정 이메일이 성공적으로 전송됨
      print('이메일 전송 성공');
      // 추가적인 UI 작업 또는 네비게이션 등을 수행할 수 있음
    } catch (e) {
      // 이메일 전송 실패
      print('이메일 전송 실패: $e');
      // 에러 메시지를 사용자에게 표시할 수 있음
    }
  }
}
