import 'package:flutter/material.dart';
import 'package:hah/appbar/appbar.dart';
import 'package:hah/mainpage/home.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth 인스턴스 생성

  // 사용자 입력을 위한 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 로그인 버튼 크기 조정 변수
  final double buttonWidth = 210; // 버튼의 너비
  final double buttonHeight = 55;  // 버튼의 높이

  void _handleLogin() async {
    setState(() {
      _isLoggingIn = true; // 로그인 중임을 표시
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // 로그인 성공 시 HomeScreen으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AppBarWithBottomNav()), // app.dart(하단바)
      );
    } catch (e) {
      print('Firebase 로그인 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: 이메일과 비밀번호를 확인해주세요.')),
      );
    }

    setState(() {
      _isLoggingIn = false; // 로그인 완료 후 상태 복원
    });
  }

  // 카카오 로그인 처리 메소드
  void _handleKakaoLogin() async {
    bool success = await _viewModel.login();
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()), // 카카오 로그인 성공 시 HomeScreen으로 이동
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카카오 로그인 실패')),
      );
    }
  }

  // 회원가입 페이지로 이동하는 메소드
  void _handleSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()), // RegisterPage로 이동
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      appBar: AppBar(
        title: Text('로그인'),
        backgroundColor: Colors.blue[50], // 카카오톡 색상으로 설정
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // 좌우 여백 추가
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이디 입력 필드 (인스타그램 스타일)
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: '아이디',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 20), // 입력 필드와 다음 필드 사이 간격 추가
              // 비밀번호 입력 필드 (인스타그램 스타일)
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                obscureText: true, // 비밀번호 숨기기
              ),
              SizedBox(height: 40), // 입력 필드와 버튼 사이 간격 추가
              // 로그인 버튼
              ElevatedButton(
                onPressed: _isLoggingIn ? null : _handleLogin, // 로그인 처리
                child: Text('로그인', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // 배경색을 검은색으로 설정
                  minimumSize: Size(buttonWidth, buttonHeight), // 버튼 크기
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // 모서리 둥글게
                  ),
                  elevation: 5, // 그림자 추가
                ),
              ),
              SizedBox(height: 20), // 버튼과 카카오 로그인 이미지 간격
              // 카카오 로그인 이미지 (카카오 로그인 기능)
              GestureDetector(
                onTap: _isLoggingIn ? null : _handleKakaoLogin, // 카카오 로그인 처리
                child: Container(
                  height: 48,
                  child: ShadowedImage(
                    image: AssetImage('lib/startpage/kakao_login.png'), // 카카오 로그인 버튼 이미지
                  ),
                ),
              ),
              SizedBox(height: 40), // 이미지와 회원가입 버튼 사이 간격 추가
              // 회원가입 버튼
              TextButton(
                onPressed: _isLoggingIn ? null : _handleSignUp,
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    color: Colors.grey[700], // 진한 회색으로 설정
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 그림자가 있는 이미지 위젯
class ShadowedImage extends StatelessWidget {
  final ImageProvider image;

  ShadowedImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // 그림자 색상
            blurRadius: 6.0, // 흐림 반경
            spreadRadius: 1.0, // 퍼짐 반경
            offset: Offset(0, 3), // 그림자 위치
          ),
        ],
      ),
      child: Image(image: image), // 이미지 표시
    );
  }
}
