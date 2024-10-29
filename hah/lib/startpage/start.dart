import 'package:flutter/material.dart';
import 'package:hah/appbar/appbar.dart';
import 'package:hah/mainpage/home.dart';
import 'package:hah/startpage/find_Register.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'kakaologin.dart';
import 'main_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register.dart';

abstract class Start {
  Future<bool> login();
  Future<bool> logout();
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final MainViewModel _viewModel = MainViewModel(kakaologin());
  bool _isLoggingIn = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final double buttonWidth = 210;
  final double buttonHeight = 55;

  void _handleLogin() async {
    setState(() {
      _isLoggingIn = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppBarWithBottomNav()),
      );
    } catch (e) {
      print('Firebase 로그인 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: 이메일과 비밀번호를 확인해주세요.')),
      );
    }

    setState(() {
      _isLoggingIn = false;
    });
  }

  void _handleKakaoLogin() async {
    bool success = await _viewModel.login();
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카카오 로그인 실패')),
      );
    }
  }

  void _handleSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }

  void _handleForgotPassword() {
    // 비밀번호 찾기 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FindRegister()), // 하단 페이지로 이동
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('로그인'),
        backgroundColor: Colors.blue[50],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: '아이디',
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: '비밀번호',
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoggingIn ? null : _handleLogin,
                    child: Text('로그인', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: Size(buttonWidth, buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 5,
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: _isLoggingIn ? null : _handleKakaoLogin,
                    child: Container(
                      height: 48,
                      child: ShadowedImage(
                        image: AssetImage('lib/startpage/kakao_login.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _isLoggingIn ? null : _handleSignUp,
                  child: Text(
                    '회원가입',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 8), // 버튼 사이의 간격
                Text('|', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                SizedBox(width: 8), // 버튼 사이의 간격
                TextButton(
                  onPressed: _isLoggingIn ? null : _handleForgotPassword,
                  child: Text(
                    '비밀번호 찾기',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShadowedImage extends StatelessWidget {
  final ImageProvider image;

  ShadowedImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6.0,
            spreadRadius: 1.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Image(image: image),
    );
  }
}
